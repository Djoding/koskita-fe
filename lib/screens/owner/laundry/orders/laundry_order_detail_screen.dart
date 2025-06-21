// lib/screens/owner/laundry/orders/laundry_order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class LaundryOrderDetailScreen extends StatefulWidget {
  const LaundryOrderDetailScreen({super.key});

  @override
  State<LaundryOrderDetailScreen> createState() => _LaundryOrderDetailScreenState();
}

class _LaundryOrderDetailScreenState extends State<LaundryOrderDetailScreen> {
  String? orderId;
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    orderId = arguments['pesanan_id'];
    orderData = arguments['order_data']; // Optional cached data
    
    if (orderData != null) {
      setState(() {
        isLoading = false;
      });
    } else {
      _loadOrderDetail();
    }
  }

  Future<void> _loadOrderDetail() async {
    if (orderId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await LaundryService.getLaundryOrderById(orderId!);

      if (response['status']) {
        setState(() {
          orderData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat detail pesanan';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    if (orderId == null) return;

    try {
      final response = await LaundryService.updateLaundryOrderStatus(
        orderId!,
        {'status': newStatus},
      );

      if (response['status']) {
        Get.snackbar(
          'Berhasil',
          'Status pesanan berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Update local data
        if (orderData != null) {
          setState(() {
            orderData!['status'] = newStatus;
          });
        }
        
        // Return true to indicate changes
        Get.back(result: true);
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal memperbarui status',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Detail Pesanan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (orderData == null) {
      return const Center(
        child: Text('Data pesanan tidak ditemukan'),
      );
    }

    // Display order detail here
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header, customer info, items, etc.
          Text(
            'Order #${orderData!['pesanan_id']}',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          // Add more detail content here...
        ],
      ),
    );
  }
}