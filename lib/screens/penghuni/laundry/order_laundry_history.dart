import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/services/history_order_service.dart';
import 'package:intl/intl.dart';

class LaundryOrderHistoryScreen extends StatefulWidget {
  final String reservasiId;

  const LaundryOrderHistoryScreen({super.key, required this.reservasiId});

  @override
  State<LaundryOrderHistoryScreen> createState() =>
      _LaundryOrderHistoryScreenState();
}

class _LaundryOrderHistoryScreenState extends State<LaundryOrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _allLaundryOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final OrderHistoryService _orderHistoryService = OrderHistoryService();
  List<Map<String, dynamic>> get _pendingLaundryOrders =>
      _allLaundryOrders.where((order) => order['status'] == 'PENDING').toList();

  List<Map<String, dynamic>> get _processedLaundryOrders =>
      _allLaundryOrders.where((order) => order['status'] == 'PROSES').toList();

  List<Map<String, dynamic>> get _acceptedLaundryOrders =>
      _allLaundryOrders
          .where((order) => order['status'] == 'DITERIMA')
          .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _orderHistoryService.getReservationDetail(
        widget.reservasiId,
      );
      if (result['status'] == true && result['data'] != null) {
        final Map<String, dynamic> reservationData =
            result['data'] as Map<String, dynamic>;
        final List<dynamic>? laundryOrdersRaw =
            reservationData['pesanan_laundry'];

        setState(() {
          if (laundryOrdersRaw != null) {
            _allLaundryOrders = laundryOrdersRaw.cast<Map<String, dynamic>>();
          } else {
            _allLaundryOrders = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              result['message'] ?? 'Gagal memuat riwayat pesanan laundry.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading laundry order history: $e");
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF89B3DE), Color(0xFF6B9EDD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildTitle(),
              _buildTabBar(),
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : _errorMessage != null
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error: $_errorMessage',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadOrderHistory, // Coba lagi
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                        : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOrderList(_pendingLaundryOrders, 'Pending'),
                            _buildOrderList(
                              _processedLaundryOrders,
                              'Diproses',
                            ),
                            _buildOrderList(_acceptedLaundryOrders, 'Diterima'),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Text(
        'Riwayat Pesanan Laundry',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 3.0,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        labelColor: const Color(0xFF4A99BD),
        unselectedLabelColor: Colors.white.withOpacity(0.8),
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Diproses'),
          Tab(text: 'Diterima'),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, String statusName) {
    if (orders.isEmpty) {
      return _buildEmptyState('Tidak ada pesanan $statusName.');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _LaundryOrderHistoryCard(order: orders[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LaundryOrderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _LaundryOrderHistoryCard({required this.order});

  String _formatPrice(dynamic price) {
    if (price == null) return 'Rp 0';
    double p;
    if (price is String) {
      p = double.tryParse(price) ?? 0.0;
    } else if (price is num) {
      p = price.toDouble();
    } else {
      p = 0.0;
    }
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(p.round());
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${DateFormat('dd MMMM y', 'id_ID').format(date)} WIB';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    switch (order['status']) {
      case 'DITERIMA':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'PROSES':
        statusColor = const Color(0xFF4A99BD);
        statusBgColor = const Color(0xFF4A99BD).withOpacity(0.2);
        break;
      case 'PENDING':
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange.withOpacity(0.2);
        break;
      default:
        statusColor = Colors.grey[700]!;
        statusBgColor = Colors.grey.withOpacity(0.2);
    }

    final List<dynamic> detailPesananLaundry =
        order['detail_pesanan_laundry'] ?? [];

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order['pesanan_id']?.substring(0, 8) ?? 'N/A'}...',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 0.8, color: Colors.grey),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Antar:',
              value: _formatDateTime(order['tanggal_antar'] as String?),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.check_circle_outline,
              label: 'Estimasi Selesai:',
              value: _formatDateTime(order['estimasi_selesai'] as String?),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.local_laundry_service,
              label: 'Layanan:',
              value: detailPesananLaundry
                  .map((detail) {
                    final String namaLayanan =
                        detail['layanan']?['nama_layanan'] ?? 'Layanan';
                    final String satuan =
                        detail['layanan']?['satuan'] ?? 'unit';
                    final int jumlahSatuan =
                        detail['jumlah_satuan'] as int? ?? 0;
                    return '$jumlahSatuan $satuan $namaLayanan';
                  })
                  .join(', '),
            ),
            const SizedBox(height: 8),
            ...detailPesananLaundry.map((item) {
              final String itemName =
                  item['layanan']?['nama_layanan'] ?? 'Layanan';
              final int itemQuantity = item['jumlah_satuan'] as int? ?? 0;
              final dynamic itemPrice = item['harga_per_satuan'];
              final double subtotal =
                  itemQuantity *
                  (double.tryParse(itemPrice?.toString() ?? '') ?? 0.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$itemQuantity x $itemName',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatPrice(subtotal),
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 16, thickness: 0.8, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Estimasi:',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatPrice(order['total_estimasi']),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4D9DAB),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'], // Status dari API
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 14),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
