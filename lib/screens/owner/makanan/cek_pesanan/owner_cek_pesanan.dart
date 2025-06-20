// lib/screens/owner/makanan/cek_pesanan/owner_cek_pesanan.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/models/catering_model.dart';
import 'package:kosan_euy/routes/app_pages.dart';
import 'package:kosan_euy/services/catering_menu_service.dart'; // Import service
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To get user ID

class OwnerCekPesanan extends StatefulWidget {
  // Pass kostData for context, if needed. Assuming it's passed via Get.arguments
  final Map<String, dynamic>? kostData;

  const OwnerCekPesanan({super.key, this.kostData});

  @override
  State<OwnerCekPesanan> createState() => _OwnerCekPesananState();
}

class _OwnerCekPesananState extends State<OwnerCekPesanan> {
  List<Map<String, dynamic>> _orders = []; // Raw map from backend
  bool _isLoadingOrders = true;
  String _errorMessage = '';
  String? _pengelolaId;
  String? _cateringId; // Filter orders by catering ID

  @override
  void initState() {
    super.initState();
    _initializeOrdersData();
  }

  Future<void> _getPengelolaId() async {
    final prefs =
        await Get.find<SharedPreferences>(); // Get SharedPreferences instance
    final token = prefs.getString('accessToken');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _pengelolaId = decodedToken["userId"];
    }
  }

  Future<void> _initializeOrdersData() async {
    await _getPengelolaId();

    if (widget.kostData == null) {
      setState(() {
        _errorMessage = 'Kost data is missing. Cannot fetch catering orders.';
        _isLoadingOrders = false;
      });
      return;
    }

    // First, get the catering service associated with this kost
    try {
      final response = await CateringMenuService.getCateringsByKost(
        widget.kostData!['kost_id'],
      );
      if (response['status'] && (response['data'] as List).isNotEmpty) {
        final List<Catering> caterings = response['data'];
        _cateringId =
            caterings
                .first
                .cateringId; // Assuming one catering per kost for simplicity

        await _fetchCateringOrders(); // Then fetch orders for this catering
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'No catering service found for this kost.';
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching catering service: $e';
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> _fetchCateringOrders() async {
    if (_pengelolaId == null || _cateringId == null) {
      setState(() {
        _errorMessage = 'Pengelola ID or Catering ID is not available.';
        _isLoadingOrders = false;
      });
      return;
    }

    setState(() {
      _isLoadingOrders = true;
      _errorMessage = '';
    });

    try {
      final response = await CateringMenuService.getCateringOrders(
        pengelolaId: _pengelolaId!,
        cateringId: _cateringId, // Filter by cateringId
        // You can add other filters like status, startDate, endDate here
      );
      if (response['status']) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Failed to load catering orders.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error fetching orders: $e';
      });
    } finally {
      setState(() {
        _isLoadingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Tombol back
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
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Pesanan Masuk',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // You might want to filter orders by month or show current month only
              // For simplicity, let's just show all fetched orders.
              const Text(
                'Daftar Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_orders.length} item',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),
              _isLoadingOrders
                  ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _errorMessage.isNotEmpty
                  ? Expanded(
                    child: Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  : Expanded(
                    child:
                        _orders.isEmpty
                            ? const Center(
                              child: Text(
                                'Tidak ada pesanan masuk.',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return OrderCard(
                                  order: order,
                                  pengelolaId: _pengelolaId!,
                                );
                              },
                            ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String pengelolaId; // Pass pengelolaId to detail screen

  const OrderCard({super.key, required this.order, required this.pengelolaId});

  @override
  Widget build(BuildContext context) {
    // Safely parse created_at for display
    final DateTime createdAt = DateTime.parse(order['created_at']);
    final String formattedDate =
        '${createdAt.day} ${getMonthName(createdAt.month)} ${createdAt.year}';

    // Get user full name, default to 'Unknown User'
    final String userName =
        order['user']?['full_name'] ?? 'Pengguna Tidak Dikenal';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            formattedDate,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.black,
          size: 28,
        ),
        onTap: () {
          Get.toNamed(
            Routes.cateringOrderDetail,
            arguments: {
              'orderId': order['pesanan_id'],
              'pengelolaId': pengelolaId, // Pass pengelolaId
            },
          );
        },
      ),
    );
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }
}
