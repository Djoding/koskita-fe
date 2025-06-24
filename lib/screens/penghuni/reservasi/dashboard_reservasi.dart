import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_penghuni.dart';
import 'package:kosan_euy/services/reservation_service.dart';

class DashboardReservasiScreen extends StatefulWidget {
  const DashboardReservasiScreen({super.key});

  @override
  State<DashboardReservasiScreen> createState() =>
      _DashboardReservasiScreenState();
}

class _DashboardReservasiScreenState extends State<DashboardReservasiScreen> {
  final ReservationService _reservationService = ReservationService();

  Map<String, dynamic>? _reservationDetail;
  String? _reservasiId;

  bool _isLoading = true;
  String? _errorMessage;

  int _selectedExtensionMonths = 1;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['reservasiId'] != null) {
      _reservasiId = args['reservasiId'] as String;
      _fetchReservationDetail(_reservasiId!);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID Reservasi tidak ditemukan.';
      });
    }
  }

  Future<void> _fetchReservationDetail(String reservasiId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _reservationService.getReservationDetailById(
        reservasiId,
      );
      if (result['status'] == true && result['data'] != null) {
        setState(() {
          _reservationDetail = Map<String, dynamic>.from(result['data']);
        });
      } else {
        setState(() {
          _errorMessage =
              result['message'] ?? 'Gagal mengambil detail reservasi.';
        });
      }
    } catch (e) {
      debugPrint("Error fetching reservation detail: $e");
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
      return 'N/A';
    }
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF89B3DE), Color(0xFF6B9EDD)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_errorMessage != null || _reservationDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Detail Reservasi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          backgroundColor: const Color(0xFF89B3DE),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF89B3DE), Color(0xFF6B9EDD)],
            ),
          ),
          child: Center(
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
                    onPressed: () {
                      if (_reservasiId != null) {
                        _fetchReservationDetail(_reservasiId!);
                      } else {
                        Get.back();
                      }
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final Map<String, dynamic> kostData = _reservationDetail!['kost'] ?? {};
    final String kostImage =
        kostData['foto_kost'] != null && kostData['foto_kost'].isNotEmpty
            ? _cleanImageUrl(kostData['foto_kost'][0].toString())
            : 'assets/placeholder_image.png';
    final String kostNama = kostData['nama_kost'] ?? 'Nama Kost Tidak Tersedia';
    final String kostAlamat = kostData['alamat'] ?? 'Alamat Tidak Tersedia';
    final String hargaBulanan = kostData['harga_bulanan'] ?? '0';
    final String tanggalCheckIn = _formatDate(
      _reservationDetail!['tanggal_check_in'],
    );
    final String tanggalKeluar = _formatDate(
      _reservationDetail!['tanggal_keluar'],
    );

    final int monthlyPriceValue = int.tryParse(hargaBulanan) ?? 0;
    final int extensionPrice = monthlyPriceValue * _selectedExtensionMonths;
    final String formattedExtensionPrice = _formatPrice(extensionPrice);

    final DateTime currentEndDate = DateTime.parse(
      _reservationDetail!['tanggal_keluar'] ?? DateTime.now().toIso8601String(),
    );
    final newEndDate = DateTime(
      currentEndDate.year,
      currentEndDate.month + _selectedExtensionMonths,
      currentEndDate.day,
    );
    final String? qrisImageFromKost = kostData['qris_image'] as String?;
    final Map<String, dynamic>? rekeningInfoFromKost =
        kostData['rekening_info'] as Map<String, dynamic>?;

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
                    '$tanggalCheckIn - $tanggalKeluar',
                  ),
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
                  _buildExtendButton(
                    currentExtensionPrice: extensionPrice,
                    qrisImage: qrisImageFromKost,
                    rekeningInfo: rekeningInfoFromKost,
                    durasiBulan: _selectedExtensionMonths,
                    kostId: kostData['kost_id'] as String?,
                    reservasiId: _reservationDetail!['reservasi_id'] as String?,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _cleanImageUrl(String rawUrl) {
    if (rawUrl.startsWith('http://kost-kita.my.idhttp')) {
      return rawUrl.substring('http://kost-kita.my.id'.length);
    }
    return rawUrl;
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

  Widget _buildKosanDetailsCard(
    String image,
    String nama,
    String alamat,
    String formattedMonthlyPrice,
    String formattedDateRange,
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
              icon: Icons.calendar_month,
              label: 'Periode Sewa Saat Ini:',
              value: formattedDateRange,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Harga Per Bulan:',
              value: formattedMonthlyPrice,
              valueColor: const Color(0xFF4D9DAB),
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
        size: (height ?? 180) / 3, // Ukuran ikon sesuai tinggi
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

  Widget _buildExtensionSectionTitle() {
    return _buildSectionTitle('Perpanjang Pemesanan');
  }

  Widget _buildExtensionDurationSelector() {
    final List<int> durations = [1, 3, 6, 12];
    return Container(
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
                              ? const Color(0xFFE0BFFF)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          _selectedExtensionMonths == months
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
              value: DateFormat('d MMMM y').format(newEndDate),
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

  Widget _buildExtendButton({
    required int currentExtensionPrice,
    String? qrisImage,
    Map<String, dynamic>? rekeningInfo,
    int? durasiBulan,
    String? kostId,
    String? reservasiId,
  }) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () {
            if (_reservationDetail == null) {
              Get.snackbar(
                'Error',
                'Detail reservasi belum dimuat. Mohon coba lagi.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            Get.to(
              () => MenuPembayaranPenghuni(
                amount: currentExtensionPrice,
                description:
                    'Perpanjangan Kost ${(_reservationDetail!['kost']?['nama_kost'] ?? 'N/A')} selama $durasiBulan bulan',
                qrisImage: qrisImage,
                rekeningInfo: rekeningInfo,
                durasiBulan: durasiBulan,
                kostId: kostId,
                reservasiId: reservasiId,
                paymentPurpose: 'extend_reservation',
              ),
            );
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
