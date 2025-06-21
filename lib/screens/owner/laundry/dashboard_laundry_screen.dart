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

      // PERBAIKAN: Gunakan endpoint baru untuk mendapatkan semua pesanan
      final allOrdersResponse = await LaundryService.getAllLaundryOrders();

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
        if (allOrdersResponse['status']) {
          final allOrders = allOrdersResponse['data'] as List;

          // Filter orders berdasarkan kost_id (karena getAllLaundryOrders mengembalikan semua pesanan)
          final kostOrders =
              allOrders.where((order) {
                final laundry = order['laundry'] as Map<String, dynamic>?;
                return laundry?['kost_id']?.toString() ==
                    kostData!['kost_id'].toString();
              }).toList();

          // Calculate stats berdasarkan orders yang sudah difilter
          final pendingOrders =
              kostOrders.where((order) => order['status'] == 'PENDING').length;
          final processingOrders =
              kostOrders
                  .where((order) => order['status'] == 'PROCESSING')
                  .length;
          final completedOrders =
              kostOrders
                  .where((order) => order['status'] == 'COMPLETED')
                  .length;

          stats = {
            'total_laundries': laundries.length,
            'total_orders': kostOrders.length,
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
              const SizedBox(height: 32),
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
                        'Daftar Laundry',
                        'Kelola penyedia layanan laundry',
                        Icons.local_laundry_service_outlined,
                        Colors.blue,
                        () => Get.to(
                          () => const LaundryListScreen(),
                          arguments: kostData,
                        ),
                      ),
                      _buildMenuCard(
                        'Pesanan Masuk',
                        'Kelola pesanan dari penghuni',
                        Icons.inbox_outlined,
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    String subtitle,
    IconData icon,
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
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
