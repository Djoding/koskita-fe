import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/services/history_order_service.dart'; 
import 'package:intl/intl.dart'; 

class OrderHistoryScreen extends StatefulWidget {
  final String reservasiId;

  const OrderHistoryScreen({super.key, required this.reservasiId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _allCateringOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  final OrderHistoryService _orderHistoryService = OrderHistoryService();
  List<Map<String, dynamic>> get _pendingOrders =>
      _allCateringOrders
          .where((order) => order['status'] == 'PENDING')
          .toList();

  List<Map<String, dynamic>> get _processedOrders =>
      _allCateringOrders.where((order) => order['status'] == 'PROSES').toList();

  List<Map<String, dynamic>> get _acceptedOrders =>
      _allCateringOrders
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
        final List<dynamic>? cateringOrdersRaw =
            reservationData['pesanan_catering'];

        setState(() {
          if (cateringOrdersRaw != null) {
            _allCateringOrders =
                cateringOrdersRaw
                    .cast<
                      Map<String, dynamic>
                    >();
          } else {
            _allCateringOrders = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat riwayat pesanan.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading order history: $e");
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
                                  onPressed: _loadOrderHistory,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                        : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOrderList(_pendingOrders, 'Pending'),
                            _buildOrderList(
                              _processedOrders,
                              'Diproses',
                            ), // Sesuai status API
                            _buildOrderList(_acceptedOrders, 'Diterima'),
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
        'Riwayat Pesanan Makananmu',
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
        return _OrderHistoryCard(order: orders[index]);
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

class _OrderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderHistoryCard({required this.order});

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

  @override
  Widget build(BuildContext context) {
    // Status dari API adalah PENDING, PROSES, DITERIMA
    Color statusColor;
    Color statusBgColor;
    switch (order['status']) {
      case 'DITERIMA':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'PROSES':
        statusColor = const Color(0xFF4A99BD); // Biru untuk Diproses
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

    // Ambil detail pesanan dari 'detail_pesanan' (untuk catering)
    final List<dynamic> detailPesanan = order['detail_pesanan'] ?? [];

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
            // Loop melalui detail_pesanan
            ...(detailPesanan.map((item) {
              final String itemName =
                  item['menu']?['nama_menu'] ?? 'Item'; // Akses nama_menu dari 'menu'
              final int itemQuantity =
                  item['jumlah_porsi'] as int? ?? 0; // Akses jumlah_porsi
              final dynamic itemPrice =
                  item['harga_satuan']; // Akses harga_satuan

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
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
                      _formatPrice(itemPrice), // Format harga_satuan
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            })),
            const Divider(height: 16, thickness: 0.8, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran:',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatPrice(
                    order['total_harga'],
                  ), 
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
                  order['status'],
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
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
}
