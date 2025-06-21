import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_order.dart';
import 'package:intl/intl.dart';

class PemesananLaundryScreen extends StatefulWidget {
  final String reservasiId;
  final String laundryId;
  final List<Map<String, dynamic>> orderItems;
  final double totalAmount;
  final String? qrisImage;
  final Map<String, dynamic>? rekeningInfo;

  const PemesananLaundryScreen({
    super.key,
    required this.reservasiId,
    required this.laundryId,
    required this.orderItems,
    required this.totalAmount,
    this.qrisImage,
    this.rekeningInfo,
  });

  @override
  State<PemesananLaundryScreen> createState() => _PemesananLaundryScreenState();
}

class _PemesananLaundryScreenState extends State<PemesananLaundryScreen> {
  late String _pickupDateFormatted;
  late String _deliveryDateFormatted;

  @override
  void initState() {
    super.initState();
    _calculateAndFormatDates();
  }

  void _calculateAndFormatDates() {
    final DateTime today = DateTime.now();
    final DateTime estimatedDelivery = today.add(const Duration(days: 2));

    _pickupDateFormatted = DateFormat('EEEE, dd MMMM y', 'id_ID').format(today);
    _deliveryDateFormatted = DateFormat(
      'EEEE, dd MMMM y',
      'id_ID',
    ).format(estimatedDelivery);
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price.round());
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Ringkasan Pesanan Anda'),
                  _buildLaundrySummaryCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Estimasi Waktu Layanan'),
                  _buildEstimationInfoCard(),
                  const SizedBox(height: 35),
                  const Divider(
                    color: Colors.white,
                    thickness: 1.2,
                    height: 36,
                    indent: 8,
                    endIndent: 8,
                  ),
                  const SizedBox(height: 25),
                  _buildNextButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Building Methods ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
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
          const SizedBox(width: 16),
          Text(
            'Pemesanan Laundry',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            shadows: [
              Shadow(
                offset: const Offset(0.5, 0.5),
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaundrySummaryCard() {
    final int totalItemCount = widget.orderItems.fold(
      0,
      (sum, item) => sum + (item['jumlah'] as int),
    );
    final String serviceDescription = '$totalItemCount item laundry';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pesanan Laundry',
              style: GoogleFonts.poppins(
                color: Colors.blueGrey[800],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jenis Layanan:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  serviceDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 10),
                Text(
                  'Detail Harga per Layanan:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[800],
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.orderItems.map((item) {
                  final String itemName = item['nama'] ?? 'Layanan';
                  final int itemQuantity = item['jumlah'] as int;
                  final double itemPrice = item['harga'] as double;
                  final double subtotal = itemQuantity * itemPrice;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$itemQuantity x $itemName',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatPrice(subtotal),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 15),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran:',
                  style: GoogleFonts.poppins(
                    color: Colors.blueGrey[900],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatPrice(widget.totalAmount),
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4D9DAB),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimationInfoCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Waktu',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tanggal Penjemputan:',
              value: _pickupDateFormatted,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Waktu Penjemputan:',
              value: 'Jam 09.00 - 22.00 WIB',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.delivery_dining,
              label: 'Estimasi Selesai (2 Hari):',
              value: _deliveryDateFormatted,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.check_circle_outline,
              label: 'Proses Estimasi:',
              value: '2 Hari Kerja',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: SizedBox(
        width: 300,
        height: 58,
        child: ElevatedButton(
          onPressed: () {
            Get.to(
              () => OrderPaymentScreen(
                reservasiId: widget.reservasiId,
                laundryId: widget.laundryId,
                orderItems: widget.orderItems,
                totalAmount: widget.totalAmount,
                qrisImage: widget.qrisImage,
                rekeningInfo: widget.rekeningInfo,
              ),
            );
            // ------------------------------------
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF119DB1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: Text(
            'Lanjutkan Pembayaran',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
