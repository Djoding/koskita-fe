// lib/screens/owner/laundry/dashboard_laundry_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/laundry/laundry_list_screen.dart';
import 'package:kosan_euy/screens/owner/laundry/orders/laundry_orders_screen.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class DashboardLaundryScreen extends StatefulWidget {
  const DashboardLaundryScreen({super.key});

  @override
  State<DashboardLaundryScreen> createState() => _DashboardLaundryScreenState();
}

class _DashboardLaundryScreenState extends State<DashboardLaundryScreen> {
  Map<String, dynamic>? kostData;
  bool isLoading = true;
  Map<String, dynamic> dashboardStats = {};

  @override
  void initState() {
    super.initState();
    kostData = Get.arguments;
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (kostData == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get laundries data
      final laundriesResponse = await LaundryService.getLaundriesByKost(
        kostData!['kost_id'].toString(),
      );

      // Get orders data menggunakan endpoint yang sudah diperbaiki
      final ordersResponse = await LaundryService.getLaundryOrdersByKost(
        kostId: kostData!['kost_id'].toString(),
      );

      if (laundriesResponse['status']) {
        final laundries = laundriesResponse['data'] as List;

        // Inisialisasi stats
        Map<String, dynamic> stats = {
          'total_laundries': laundries.length,
          'total_orders': 0,
          'pending_orders': 0,
          'processing_orders': 0,
          'completed_orders': 0,
        };

        // Jika berhasil mendapatkan data pesanan
        if (ordersResponse['status']) {
          final orders = ordersResponse['data'] as List;

          // Calculate stats berdasarkan status yang benar
          final pendingOrders =
              orders.where((order) => order['status'] == 'PENDING').length;
          final processingOrders =
              orders.where((order) => order['status'] == 'PROSES').length;
          final completedOrders =
              orders.where((order) => order['status'] == 'DITERIMA').length;

          stats = {
            'total_laundries': laundries.length,
            'total_orders': orders.length,
            'pending_orders': pendingOrders,
            'processing_orders': processingOrders,
            'completed_orders': completedOrders,
          };
        }

        setState(() {
          dashboardStats = stats;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        Get.snackbar(
          'Error',
          laundriesResponse['message'] ?? 'Gagal memuat data laundry',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard: $e',
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
                  Column(
                    children: [
                      Text(
                        'Manajemen Laundry',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (kostData != null)
                        Text(
                          kostData!['nama_kost'] ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: _loadDashboardData,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else ...[

              // Menu Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        'Daftar Layanan',
                        'Kelola penyedia layanan laundry',
                        'assets/icon_laundry.png',
                        Colors.blue,
                        () => Get.to(
                          () => const LaundryListScreen(),
                          arguments: kostData,
                        ),
                      ),
                      _buildMenuCard(
                        'Pesanan Masuk',
                        'Kelola pesanan dari penghuni',
                        'assets/icon_order.png',
                        Colors.orange,
                        () => Get.to(
                          () => const LaundryOrdersScreen(),
                          arguments: {'kost_data': kostData, 'show_all': true},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    String subtitle,
    String imageAsset, // Ubah dari IconData ke String untuk asset path
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ubah bagian icon untuk menggunakan image asset seperti KostDetailScreen
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imageAsset,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.broken_image,
                        size: 25,
                        color: Colors.grey[500],
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
