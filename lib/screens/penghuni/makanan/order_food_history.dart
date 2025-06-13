import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  // Mock data for Order History
  // In a real application, this data would come from a database or API
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
      'totalPrice': 16000, // Corrected total for 2 Nasi Putih
      'status': 'Dibatalkan',
    },
    {
      'orderId': 'ORD004',
      'date': '25 Mei 2024',
      'items': [
        {'name': 'Midog', 'qty': 1, 'price': 5000},
        {'name': 'Es Kopi Good Day', 'qty': 1, 'price': 5000},
      ],
      'totalPrice': 10000,
      'status': 'Selesai',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF89B3DE), // Lighter blue
              Color(0xFF6B9EDD), // Deeper blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildTitle(),
              Expanded(
                child:
                    _orderHistory.isEmpty
                        ? _buildEmptyState(
                          'Belum ada riwayat pemesanan makanan.',
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: _orderHistory.length,
                          itemBuilder: (context, index) {
                            return _OrderHistoryCard(
                              order: _orderHistory[index],
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

  // --- UI Building Methods ---

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
          // You can add more icons here if needed, e.g., filter, search
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
            ), // History icon
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

// --- Order History Card Widget ---
class _OrderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    // Determine status color
    Color statusColor;
    Color statusBgColor;
    switch (order['status']) {
      case 'Selesai':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green.withOpacity(0.2);
        break;
      case 'Dibatalkan':
        statusColor = Colors.red[800]!;
        statusBgColor = Colors.red.withOpacity(0.2);
        break;
      case 'Diproses': // Example of another status
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
      margin: const EdgeInsets.only(bottom: 15), // Spacing between cards
      color: Colors.white, // White card background
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
            const Divider(
              height: 16,
              thickness: 1,
              color: Colors.grey,
            ), // Divider for clarity
            // List of ordered items
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
            const Divider(height: 16, thickness: 1, color: Colors.grey),
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
                    color: const Color(0xFF4D9DAB), // Accent color
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
