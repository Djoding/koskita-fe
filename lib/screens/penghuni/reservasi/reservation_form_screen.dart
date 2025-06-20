import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_penghuni.dart';

class InitialReservationFormScreen extends StatefulWidget {
  final Map<String, dynamic> kostDetailData;
  final String currentKostId;

  const InitialReservationFormScreen({
    super.key,
    required this.kostDetailData,
    required this.currentKostId,
  });

  @override
  State<InitialReservationFormScreen> createState() =>
      _InitialReservationFormScreenState();
}

class _InitialReservationFormScreenState
    extends State<InitialReservationFormScreen> {
  final TextEditingController dateController = TextEditingController();
  int? _selectedDurasiBulan;
  bool _isLoadingSubmit = false;

  @override
  void initState() {
    super.initState();
    _selectedDurasiBulan = 1; // Durasi default 1 bulan
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  String _cleanImageUrl(String rawUrl) {
    if (rawUrl.startsWith('http://localhost:3000http')) {
      return rawUrl.substring('http://localhost:3000'.length);
    }
    return rawUrl;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    try {
      final numPrice = num.parse(price.toString());
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(numPrice);
    } catch (e) {
      return price.toString();
    }
  }

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
            'Form Pemesanan Kamar',
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

  Widget _buildKosanDetailsCard(
    String image,
    String nama,
    String alamat,
    String formattedMonthlyPrice,
  ) {
    final bool isAsset = image.startsWith('assets/');
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
              child:
                  isAsset
                      ? Image.asset(
                        image,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildErrorImagePlaceholder(height: 180),
                      )
                      : Image.network(
                        image,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: const Color(0xFF119DB1),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildErrorImagePlaceholder(height: 180),
                      ),
            ),
            const SizedBox(height: 20),
            Text(
              nama,
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
                    alamat,
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
              icon: Icons.attach_money,
              label: 'Harga Per Bulan:',
              value: formattedMonthlyPrice,
              valueColor: const Color(0xFF4D9DAB),
              valueWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.meeting_room,
              label: 'Kamar Tersedia:',
              value:
                  '${widget.kostDetailData['available_rooms'] ?? 'N/A'} dari ${widget.kostDetailData['total_kamar'] ?? 'N/A'}',
              valueColor: Colors.green[700],
              valueWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImagePlaceholder({double? height}) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image,
        size: (height ?? 180) / 3,
        color: Colors.grey[400],
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

  Widget _buildDatePickerField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white, // Warna teks label
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.poppins(color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A99BD),
                width: 2.0,
              ),
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4A99BD),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black87,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A99BD),
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              setState(() {
                controller.text = DateFormat(
                  "d MMMM y",
                  "id_ID",
                ).format(pickedDate);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDurasiDropdown() {
    final List<int> durations = [1, 3, 6, 12];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Durasi Sewa (Bulan)",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2.0,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
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
                          _selectedDurasiBulan = months;
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
                              _selectedDurasiBulan == months
                                  ? const Color(0xFFE0BFFF)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              _selectedDurasiBulan == months
                                  ? Border.all(
                                    color: const Color(0xFF119DB1),
                                    width: 1.5,
                                  )
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            '$months Bulan',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color:
                                  _selectedDurasiBulan == months
                                      ? Colors.black87
                                      : Colors.white,
                              fontWeight:
                                  _selectedDurasiBulan == months
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
        ),
      ],
    );
  }

  Widget _buildPriceDetails(
    num hargaFinalPerBulan,
    num biayaTambahan,
    num deposit,
    num durasi,
    num subTotalSewa,
    num totalPembayaran,
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
              'Rincian Pembayaran',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const Divider(height: 25, thickness: 1, color: Colors.grey),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Harga Sewa per Bulan:',
              value: _formatPrice(hargaFinalPerBulan.toInt()),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.timelapse,
              label: 'Durasi Sewa:',
              value: '$durasi Bulan',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.shopping_cart,
              label: 'Subtotal Sewa:',
              value: _formatPrice(subTotalSewa.toInt()),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.add_circle_outline,
              label: 'Biaya Tambahan (sekali):',
              value: _formatPrice(biayaTambahan.toInt()),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.account_balance_wallet,
              label: 'Deposit (sekali):',
              value: _formatPrice(deposit.toInt()),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.black54),
            _buildDetailRow(
              icon: Icons.paid,
              label: 'TOTAL PEMBAYARAN:',
              value: _formatPrice(totalPembayaran.toInt()),
              valueColor: const Color(0xFF4D9DAB),
              valueWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitReservationButton(int totalAmount) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed:
              _isLoadingSubmit
                  ? null
                  : () async {
                    if (dateController.text.isEmpty ||
                        _selectedDurasiBulan == null) {
                      Get.snackbar(
                        'Error',
                        'Harap lengkapi tanggal masuk dan durasi sewa.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    setState(() {
                      _isLoadingSubmit = true;
                    });

                    try {
                      final String? qrisImageFromKost =
                          widget.kostDetailData['qris_image'] as String?;
                      final Map<String, dynamic>? rekeningInfoFromKost =
                          widget.kostDetailData['rekening_info']
                              as Map<String, dynamic>?;
                      final String formattedCheckInDate = DateFormat(
                        "yyyy-MM-dd",
                      ).format(
                        DateFormat(
                          "d MMMM y",
                          "id_ID",
                        ).parse(dateController.text),
                      );

                      Get.to(
                        () => MenuPembayaranPenghuni(
                          amount: totalAmount,
                          description:
                              'Pemesanan Kamar Kost ${widget.kostDetailData['nama_kost'] ?? 'N/A'} selama $_selectedDurasiBulan bulan.',
                          qrisImage: qrisImageFromKost,
                          rekeningInfo: rekeningInfoFromKost,
                          durasiBulan: _selectedDurasiBulan,
                          kostId: widget.currentKostId,
                          paymentPurpose: 'create_reservation',
                          tanggalCheckIn: formattedCheckInDate,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoadingSubmit = false;
                      });
                    }
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
          child:
              _isLoadingSubmit
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
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

  @override
  Widget build(BuildContext context) {
    final String kostImage =
        widget.kostDetailData['foto_kost'] != null &&
                widget.kostDetailData['foto_kost'].isNotEmpty
            ? _cleanImageUrl(widget.kostDetailData['foto_kost'][0].toString())
            : 'assets/placeholder_image.png';
    final String kostNama =
        widget.kostDetailData['nama_kost'] ?? 'Nama Kost Tidak Tersedia';
    final String kostAlamat =
        widget.kostDetailData['alamat'] ?? 'Alamat Tidak Tersedia';
    final String hargaBulanan = widget.kostDetailData['harga_bulanan'] ?? '0';

    // Hitung rincian pembayaran
    final num hargaFinalPerBulan =
        num.tryParse(widget.kostDetailData['harga_final']?.toString() ?? '0') ??
        0;
    final num biayaTambahan =
        num.tryParse(
          widget.kostDetailData['biaya_tambahan']?.toString() ?? '0',
        ) ??
        0;
    final num deposit =
        num.tryParse(widget.kostDetailData['deposit']?.toString() ?? '0') ?? 0;

    final num durasi = _selectedDurasiBulan ?? 1;
    final num subTotalSewa = hargaFinalPerBulan * durasi;
    final num totalPembayaran = subTotalSewa + biayaTambahan + deposit;

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
                  const SizedBox(height: 25),
                  _buildKosanDetailsCard(
                    kostImage,
                    kostNama,
                    kostAlamat,
                    _formatPrice(hargaBulanan),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Lengkapi Detail Pemesanan'),
                  const SizedBox(height: 20),
                  _buildDatePickerField(
                    context,
                    "Tanggal Masuk",
                    dateController,
                  ),
                  const SizedBox(height: 16),
                  _buildDurasiDropdown(),
                  const SizedBox(height: 25),
                  _buildPriceDetails(
                    hargaFinalPerBulan,
                    biayaTambahan,
                    deposit,
                    durasi,
                    subTotalSewa,
                    totalPembayaran,
                  ),
                  const SizedBox(height: 30),
                  _buildSubmitReservationButton(totalPembayaran.toInt()),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
