import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:intl/intl.dart'; // For date formatting

// Assuming this is your payment screen
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_Penghuni.dart';

// A simple data model for an active kosan reservation
class ActiveKosan {
  final String image;
  final String nama;
  final String alamat;
  final int monthlyPrice; // Store price as int for calculations
  final DateTime startDate;
  final DateTime endDate;

  ActiveKosan({
    required this.image,
    required this.nama,
    required this.alamat,
    required this.monthlyPrice,
    required this.startDate,
    required this.endDate,
  });

  // Helper to format currency
  String get formattedPrice => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(monthlyPrice);

  // Helper to format date range
  String get formattedDateRange {
    final DateFormat formatter = DateFormat('d MMM yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }
}

class DashboardReservasiScreen extends StatefulWidget {
  // You might pass the activeKosan object here in a real app
  // For this example, we'll use a hardcoded activeKosan.
  const DashboardReservasiScreen({super.key});

  @override
  State<DashboardReservasiScreen> createState() =>
      _ActiveReservationDetailScreenState();
}

class _ActiveReservationDetailScreenState
    extends State<DashboardReservasiScreen> {
  // Hardcoded active kosan data for demonstration
  final ActiveKosan activeKosan = ActiveKosan(
    image: 'assets/kapling40.png',
    nama: 'Kost Kapling40',
    alamat: 'Jalan hj Umayah II, Citereup Bandung',
    monthlyPrice: 1000000, // Example monthly price
    startDate: DateTime(2024, 5, 1),
    endDate: DateTime(2025, 5, 1), // Currently ends in 1 year
  );

  int _selectedExtensionMonths = 1; // Default extension is 1 month

  @override
  Widget build(BuildContext context) {
    // Calculate new end date based on extension
    final newEndDate = DateTime(
      activeKosan.endDate.year,
      activeKosan.endDate.month + _selectedExtensionMonths,
      activeKosan.endDate.day,
    );

    // Calculate total price for extension
    final extensionPrice = activeKosan.monthlyPrice * _selectedExtensionMonths;
    final formattedExtensionPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(extensionPrice);

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ), // Consistent padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildKosanDetailsCard(),
                  const SizedBox(height: 30),
                  _buildExtensionSectionTitle(),
                  const SizedBox(height: 20),
                  _buildExtensionDurationSelector(),
                  const SizedBox(height: 25),
                  _buildExtensionSummaryCard(
                    newEndDate,
                    formattedExtensionPrice,
                  ),
                  const SizedBox(height: 30),
                  _buildExtendButton(extensionPrice),
                  const SizedBox(height: 30), // Bottom padding
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
            'Detail Reservasi Aktif',
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

  Widget _buildKosanDetailsCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                activeKosan.image,
                height: 180, // Larger image
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              activeKosan.nama,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF119DB1),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activeKosan.alamat,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildDetailRow(
              icon: Icons.calendar_month,
              label: 'Periode Sewa Saat Ini:',
              value: activeKosan.formattedDateRange,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Harga Per Bulan:',
              value: activeKosan.formattedPrice,
              valueColor: const Color(0xFF4D9DAB),
              valueWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
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

  Widget _buildExtensionSectionTitle() {
    return _buildSectionTitle('Perpanjang Pemesanan');
  }

  Widget _buildExtensionDurationSelector() {
    final List<int> durations = [1, 3, 6, 12]; // in months
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Semi-transparent container
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            durations.map((months) {
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    setState(() {
                      _selectedExtensionMonths = months;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _selectedExtensionMonths == months
                              ? const Color(
                                0xFFE0BFFF,
                              ) // Accent color for selected
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          _selectedExtensionMonths == months
                              ? Border.all(
                                color: const Color(0xFF119DB1),
                                width: 1.5,
                              ) // Accent border
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '$months Bulan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color:
                              _selectedExtensionMonths == months
                                  ? Colors.black87
                                  : Colors.white,
                          fontWeight:
                              _selectedExtensionMonths == months
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildExtensionSummaryCard(
    DateTime newEndDate,
    String formattedExtensionPrice,
  ) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Perpanjangan',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const Divider(height: 25, thickness: 1, color: Colors.grey),
            _buildDetailRow(
              icon: Icons.date_range,
              label: 'Periode Perpanjangan:',
              value: '$_selectedExtensionMonths Bulan',
              valueColor: Colors.black87,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Tanggal Berakhir Baru:',
              value: DateFormat('d MMM yyyy').format(newEndDate),
              valueColor: Colors.black87,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.money,
              label: 'Biaya Perpanjangan:',
              value: formattedExtensionPrice,
              valueColor: const Color(0xFF4D9DAB),
              valueWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtendButton(int currentExtensionPrice) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () {
            // In a real app, you would pass the calculated extensionPrice and newEndDate
            // to the payment screen. For now, it navigates to a dummy payment screen.
            // Get.to(
            //   () => MenuPembayaranPenghuni(
            //     // Example of passing data (adjust MenuPembayaranPenghuni to receive this)
            //     amount: currentExtensionPrice,
            //     description:
            //         'Perpanjangan Kost ${activeKosan.nama} selama $_selectedExtensionMonths bulan',
            //   ),
            // );
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
            'Bayar Perpanjangan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for consistent detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight valueWeight = FontWeight.normal,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Text(
          '$label ',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: valueColor ?? Colors.black87,
              fontSize: 15,
              fontWeight: valueWeight,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
