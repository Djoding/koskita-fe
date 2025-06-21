// lib/screens/owner/laundry/orders/laundry_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/laundry/orders/laundry_order_detail_screen.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class LaundryOrdersScreen extends StatefulWidget {
  final bool showAll;

  const LaundryOrdersScreen({super.key, this.showAll = false});

  @override
  State<LaundryOrdersScreen> createState() => _LaundryOrdersScreenState();
}

class _LaundryOrdersScreenState extends State<LaundryOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? kostData;
  bool showAll = false;
  int? laundryFilter;
  List<dynamic> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  // Status filters
  final List<String> statusTabs = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Selesai',
    'Dibatalkan',
  ];
  final Map<String, String> statusMapping = {
    'Semua': '',
    'Menunggu': 'PENDING',
    'Diproses': 'PROSES',
    'Selesai': 'DITERIMA',
    'Dibatalkan': 'CANCELLED',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Parse arguments
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    kostData = arguments['kost_data'];
    showAll = arguments['show_all'] ?? widget.showAll;
    laundryFilter = arguments['laundry_filter'];

    _loadOrders();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    if (kostData == null) {
      setState(() {
        errorMessage = 'Data kost tidak ditemukan';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final selectedStatus =
          statusMapping[statusTabs[_tabController.index]] ?? '';

      // PERBAIKAN: Gunakan endpoint baru dengan kost_id
      final response = await LaundryService.getLaundryOrdersByKost(
        kostId: kostData!['kost_id'].toString(),
        status: selectedStatus.isNotEmpty ? selectedStatus : null,
        laundryId: laundryFilter?.toString(),
      );

      if (response['status']) {
        setState(() {
          orders = response['data'] as List? ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat pesanan';
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

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      // PERBAIKAN: Gunakan endpoint baru untuk update status
      final response = await LaundryService.updateLaundryOrderStatus(orderId, {
        'status': newStatus,
      });

      if (response['status']) {
        Get.snackbar(
          'Berhasil',
          'Status pesanan berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _loadOrders(); // Reload data
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

  void _showStatusUpdateDialog(Map<String, dynamic> order) {
    final currentStatus = order['status'] ?? '';
    final availableStatuses = _getAvailableStatuses(currentStatus);

    if (availableStatuses.isEmpty) {
      Get.snackbar(
        'Info',
        'Tidak ada status yang dapat diubah untuk pesanan ini',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah Status Pesanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              availableStatuses.map((status) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _getStatusDisplayName(status),
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                  onTap: () {
                    Get.back();
                    _updateOrderStatus(order['pesanan_id'].toString(), status);
                  },
                );
              }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'PENDING':
        return ['PROSES', 'CANCELLED'];
      case 'PROSES':
        return ['DITERIMA', 'CANCELLED'];
      case 'DITERIMA':
      case 'CANCELLED':
        return [];
      default:
        return ['PROSES', 'CANCELLED'];
    }
  }

  void _goToOrderDetail(Map<String, dynamic> order) {
    Get.to(
      () => const LaundryOrderDetailScreen(),
      arguments: {
        'pesanan_id': order['pesanan_id'].toString(),
        'order_data': order, // Pass cached data
      },
    )?.then((result) {
      // Refresh jika ada perubahan dari detail screen
      if (result == true) {
        _loadOrders();
      }
    });
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
                        showAll ? 'Riwayat Pesanan' : 'Pesanan Masuk',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (kostData != null && !showAll)
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
                      onPressed: _loadOrders,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicator: BoxDecoration(
                  color: const Color(0xFF9EBFED),
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: statusTabs.map((status) => Tab(text: status)).toList(),
              ),
            ),

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
              onPressed: _loadOrders,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan akan muncul di sini ketika ada customer yang memesan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final user = order['user'] as Map<String, dynamic>? ?? {};
    final laundry = order['laundry'] as Map<String, dynamic>? ?? {};
    final items = order['items'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _goToOrderDetail(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['pesanan_id']}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(order['created_at']),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order['status']),
                          size: 14,
                          color: _getStatusColor(order['status']),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusDisplayName(order['status']),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order['status']),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Customer Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['full_name'] ?? 'Customer',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user['email'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Laundry Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_laundry_service,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      laundry['nama_laundry'] ?? 'Laundry',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Order Items Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detail Pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${items.length} item${items.length > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Show max 2 items, then "dan X lainnya"
                    ...items
                        .take(2)
                        .map((item) => _buildOrderItem(item))
                        .toList(),
                    if (items.length > 2) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'dan ${items.length - 2} item lainnya...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total and Actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(order['total_amount'])}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // View Detail Button
                      OutlinedButton(
                        onPressed: () => _goToOrderDetail(order),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF9EBFED)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Detail',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF9EBFED),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Update Status Button
                      if (_canUpdateStatus(order['status'])) ...[
                        ElevatedButton(
                          onPressed: () => _showStatusUpdateDialog(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9EBFED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Update',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Payment Info (if available)
              if (order['payment_proof'] != null &&
                  order['payment_proof'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Bukti pembayaran tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Pickup/Delivery Info (if available)
              if (order['pickup_datetime'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Penjemputan: ${_formatDateTime(order['pickup_datetime'])}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final laundryService =
        item['laundry_service'] as Map<String, dynamic>? ?? {};
    final layanan = laundryService['layanan'] as Map<String, dynamic>? ?? {};

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              layanan['nama_layanan'] ?? 'Layanan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${item['quantity']}${layanan['satuan'] ?? ''}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${_formatCurrency(item['subtotal'])}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PROSES':
        return Colors.blue;
      case 'DITERIMA':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'PROSES':
        return Icons.autorenew;
      case 'DITERIMA':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDisplayName(String? status) {
    switch (status) {
      case 'PENDING':
        return 'Menunggu';
      case 'PROSES':
        return 'Diproses';
      case 'DITERIMA':
        return 'Selesai';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  bool _canUpdateStatus(String? status) {
    return status == 'PENDING' || status == 'PROSES';
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Tidak diketahui';
    try {
      final date = DateTime.parse(dateTime.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Tidak diketahui';
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';

    double value;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    } else if (amount is num) {
      value = amount.toDouble();
    } else {
      return '0';
    }

    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
