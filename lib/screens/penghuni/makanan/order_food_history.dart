import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _orderHistory = const [
    {
      'orderId': 'ORD001',
      'date': '05 Juni 2024',
      'items': [
        {'name': 'Nasi Goreng Telur', 'qty': 1, 'price': 12000},
        {'name': 'Es Teh Hangat', 'qty': 1, 'price': 4000},
      ],
      'totalPrice': 16000,
      'status': 'Selesai',
    },
    {
      'orderId': 'ORD002',
      'date': '02 Juni 2024',
      'items': [
        {'name': 'Indomie Kuah Spesial', 'qty': 1, 'price': 8000},
        {'name': 'Es Milo', 'qty': 1, 'price': 7000},
      ],
      'totalPrice': 15000,
      'status': 'Selesai',
    },
    {
      'orderId': 'ORD003',
      'date': '30 Mei 2024',
      'items': [
        {'name': 'Nasi Putih', 'qty': 2, 'price': 5000},
        {'name': 'Telur Dadar', 'qty': 1, 'price': 6000},
      ],
      'totalPrice': 16000,
      'status': 'Diterima',
    },
    {
      'orderId': 'ORD004',
      'date': '25 Mei 2024',
      'items': [
        {'name': 'Midog', 'qty': 1, 'price': 5000},
        {'name': 'Es Kopi Good Day', 'qty': 1, 'price': 5000},
      ],
      'totalPrice': 10000,
      'status': 'Pending',
    },
    {
      'orderId': 'ORD005',
      'date': '24 Mei 2024',
      'items': [
        {'name': 'Ayam Geprek', 'qty': 1, 'price': 18000},
      ],
      'totalPrice': 18000,
      'status': 'Pending',
    },
    {
      'orderId': 'ORD006',
      'date': '23 Mei 2024',
      'items': [
        {'name': 'Sate Ayam', 'qty': 1, 'price': 25000},
      ],
      'totalPrice': 25000,
      'status': 'Diterima',
    },
  ];

  List<Map<String, dynamic>> get _pendingOrders =>
      _orderHistory.where((order) => order['status'] == 'Pending').toList();

  List<Map<String, dynamic>> get _acceptedOrders =>
      _orderHistory.where((order) => order['status'] == 'Diterima').toList();

  List<Map<String, dynamic>> get _completedOrders =>
      _orderHistory.where((order) => order['status'] == 'Selesai').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrderList(_pendingOrders, 'pending'),
                    _buildOrderList(_acceptedOrders, 'diterima'),
                    _buildOrderList(_completedOrders, 'selesai'),
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
          Tab(text: 'Diterima'),
          Tab(text: 'Selesai'),
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

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    switch (order['status']) {
      case 'Selesai':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'Diterima':
        statusColor = const Color(0xFF4A99BD); // A shade of blue
        statusBgColor = const Color(0xFF4A99BD).withOpacity(0.2);
        break;
      case 'Pending':
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange.withOpacity(0.2);
        break;
      default:
        statusColor = Colors.grey[700]!;
        statusBgColor = Colors.grey.withOpacity(0.2);
    }

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
                  'Order ID: ${order['orderId']}',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  order['date'],
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 0.8, color: Colors.grey),
            ...(order['items'] as List<Map<String, dynamic>>).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item['qty']}x ${item['name']}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rp ${item['price']}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
                  'Rp ${order['totalPrice']}',
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
