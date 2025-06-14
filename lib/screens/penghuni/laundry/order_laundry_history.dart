import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LaundryOrderHistoryScreen extends StatefulWidget {
  const LaundryOrderHistoryScreen({super.key});

  @override
  State<LaundryOrderHistoryScreen> createState() =>
      _LaundryOrderHistoryScreenState();
}

class _LaundryOrderHistoryScreenState extends State<LaundryOrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _laundryOrderHistory = const [
    {
      'orderId': 'LAUNDRY001',
      'datePlaced': '08 Juni 2024',
      'pickupDate': '09 Juni 2024',
      'pickupTime': '10.00 WIB',
      'deliveryDate': '11 Juni 2024',
      'deliveryTime': '15.00 WIB',
      'items': '3 Kg (Cuci & Gosok)',
      'totalPrice': 18000,
      'status': 'Selesai',
    },
    {
      'orderId': 'LAUNDRY002',
      'datePlaced': '05 Juni 2024',
      'pickupDate': '06 Juni 2024',
      'pickupTime': '09.00 WIB',
      'deliveryDate': '08 Juni 2024',
      'deliveryTime': '14.00 WIB',
      'items': '5 Kg (Cuci & Gosok), 1 Sprei',
      'totalPrice': 45000,
      'status': 'Diproses',
    },
    {
      'orderId': 'LAUNDRY003',
      'datePlaced': '01 Juni 2024',
      'pickupDate': '02 Juni 2024',
      'pickupTime': '11.00 WIB',
      'deliveryDate': '04 Juni 2024',
      'deliveryTime': '17.00 WIB',
      'items': '10 Kg (Cuci & Gosok)',
      'totalPrice': 60000,
      'status': 'Pending', // Changed status for 'Pending' tab example
    },
    {
      'orderId': 'LAUNDRY004',
      'datePlaced': '30 Mei 2024',
      'pickupDate': '31 Mei 2024',
      'pickupTime': '13.00 WIB',
      'deliveryDate': '02 Juni 2024',
      'deliveryTime': '16.00 WIB',
      'items': '2 Kg (Cuci Kering)',
      'totalPrice': 12000,
      'status': 'Diproses',
    },
    {
      'orderId': 'LAUNDRY005',
      'datePlaced': '28 Mei 2024',
      'pickupDate': '29 Mei 2024',
      'pickupTime': '08.00 WIB',
      'deliveryDate': '30 Mei 2024',
      'deliveryTime': '10.00 WIB',
      'items': '4 Kg (Setrika Saja)',
      'totalPrice': 20000,
      'status': 'Selesai',
    },
  ];

  List<Map<String, dynamic>> get _pendingLaundryOrders =>
      _laundryOrderHistory
          .where((order) => order['status'] == 'Pending')
          .toList();

  List<Map<String, dynamic>> get _processedLaundryOrders =>
      _laundryOrderHistory
          .where((order) => order['status'] == 'Diproses')
          .toList();

  List<Map<String, dynamic>> get _completedLaundryOrders =>
      _laundryOrderHistory
          .where((order) => order['status'] == 'Selesai')
          .toList();

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
                    _buildOrderList(_pendingLaundryOrders, 'pending'),
                    _buildOrderList(_processedLaundryOrders, 'diproses'),
                    _buildOrderList(_completedLaundryOrders, 'selesai'),
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
              Icons.local_laundry_service,
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

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    switch (order['status']) {
      case 'Selesai':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'Diproses':
        statusColor = const Color(
          0xFF4A99BD,
        ); // Adjusted to blue for 'Diproses'
        statusBgColor = const Color(0xFF4A99BD).withOpacity(0.2);
        break;
      case 'Pending': // Assuming a 'Pending' status
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange.withOpacity(0.2);
        break;
      case 'Dibatalkan': // Added 'Dibatalkan' status for completeness
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red.withOpacity(0.2);
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
                  order['datePlaced'],
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 16, thickness: 0.8, color: Colors.grey),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Penjemputan:',
              value: '${order['pickupDate']} (${order['pickupTime']})',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.delivery_dining,
              label: 'Pengembalian:',
              value: '${order['deliveryDate']} (${order['deliveryTime']})',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.local_laundry_service,
              label: 'Layanan:',
              value: order['items'],
            ),
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
                    fontWeight: FontWeight.w700, // Make status text bolder
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
