import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kosan_euy/services/reservation_service.dart';

class ReservationDetailScreen extends StatefulWidget {
  final String reservasiId;

  const ReservationDetailScreen({super.key, required this.reservasiId});

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final ReservationService _reservationService = ReservationService();
  Map<String, dynamic>? _reservationDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReservationDetail();
  }

  Future<void> _fetchReservationDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _reservationService.getReservationDetailById(
        widget.reservasiId,
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
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
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

  String _cleanImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return 'assets/placeholder_image.png';
    String cleaned = rawUrl;
    if (cleaned.startsWith('https://kost-kita.my.idhttp')) {
      cleaned = cleaned.substring('https://kost-kita.my.id'.length);
    }
    if (cleaned.startsWith('/uploads/')) {
      cleaned = 'https://kost-kita.my.id$cleaned';
    }
    return cleaned;
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
          Expanded(
            child: Text(
              'Detail Reservasi',
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    FontWeight valueWeight = FontWeight.normal,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: valueColor ?? Colors.black87,
                fontWeight: valueWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const Divider(height: 25, thickness: 1, color: Colors.grey),
            ...children,
          ],
        ),
      ),
    );
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
            'Error',
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
                    onPressed: _fetchReservationDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final reservationData = _reservationDetail!;
    final kostData = reservationData['kost'] ?? {};
    final userData = reservationData['user'] ?? {};
    final pengelolaData = kostData['pengelola'] ?? {};
    final validatorData = reservationData['validator'] ?? {};

    final String kostImage =
        kostData['foto_kost'] != null && kostData['foto_kost'].isNotEmpty
            ? _cleanImageUrl(kostData['foto_kost'][0].toString())
            : 'assets/placeholder_image.png';

    final String statusReservasi = reservationData['status_reservasi'] ?? 'N/A';
    final String tanggalCheckIn = _formatDate(
      reservationData['tanggal_check_in'],
    );
    final String tanggalKeluar = _formatDate(reservationData['tanggal_keluar']);
    final String durasiBulan =
        reservationData['durasi_bulan']?.toString() ?? 'N/A';
    final String totalHarga = _formatPrice(reservationData['total_harga']);
    final String depositAmount = _formatPrice(
      reservationData['deposit_amount'],
    );
    final String metodeBayar = reservationData['metode_bayar'] ?? 'N/A';
    final String? catatan = reservationData['catatan'];
    final String? rejectionReason = reservationData['rejection_reason'];
    final String buktiBayarUrl = _cleanImageUrl(reservationData['bukti_bayar']);
    final String validatedAt = _formatDate(reservationData['validated_at']);
    final String createdAt = _formatDate(reservationData['created_at']);

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

                  // Detail Kost Card
                  _buildSectionCard(
                    title: 'Informasi Kost',
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          kostImage,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildErrorImagePlaceholder(size: 180),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        kostData['nama_kost'] ?? 'N/A',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        label: 'Alamat',
                        value: kostData['alamat'] ?? 'N/A',
                        icon: Icons.location_on,
                      ),
                      _buildDetailRow(
                        label: 'Tipe Kost',
                        value: kostData['tipe_kost'] ?? 'N/A',
                        icon: Icons.meeting_room,
                      ),
                      _buildDetailRow(
                        label: 'Harga Bulanan',
                        value: _formatPrice(kostData['harga_bulanan']),
                        icon: Icons.attach_money,
                      ),
                      _buildDetailRow(
                        label: 'Biaya Tambahan',
                        value: _formatPrice(kostData['biaya_tambahan']),
                        icon: Icons.attach_money,
                      ),
                      _buildDetailRow(
                        label: 'Deposit',
                        value: _formatPrice(kostData['deposit']),
                        icon: Icons.wallet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Detail Reservasi Card
                  _buildSectionCard(
                    title: 'Detail Reservasi',
                    children: [
                      _buildDetailRow(
                        label: 'Status',
                        value: statusReservasi,
                        valueColor:
                            statusReservasi == 'APPROVED'
                                ? Colors.green
                                : (statusReservasi == 'REJECTED'
                                    ? Colors.red
                                    : Colors.orange),
                        valueWeight: FontWeight.bold,
                        icon: Icons.info_outline,
                      ),
                      const Divider(
                        height: 15,
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      _buildDetailRow(
                        label: 'ID Reservasi',
                        value: reservationData['reservasi_id'] ?? 'N/A',
                        icon: Icons.vpn_key,
                      ),
                      _buildDetailRow(
                        label: 'Check-in',
                        value: tanggalCheckIn,
                        icon: Icons.login,
                      ),
                      _buildDetailRow(
                        label: 'Check-out',
                        value: tanggalKeluar,
                        icon: Icons.logout,
                      ),
                      _buildDetailRow(
                        label: 'Durasi',
                        value: '$durasiBulan Bulan',
                        icon: Icons.timelapse,
                      ),
                      _buildDetailRow(
                        label: 'Metode Bayar',
                        value: metodeBayar,
                        icon: Icons.payment,
                      ),
                      _buildDetailRow(
                        label: 'Total Harga',
                        value: totalHarga,
                        valueColor: const Color(0xFF4D9DAB),
                        valueWeight: FontWeight.bold,
                        icon: Icons.money,
                      ),
                      _buildDetailRow(
                        label: 'Jumlah Deposit',
                        value: depositAmount,
                        icon: Icons.account_balance_wallet,
                      ),
                      if (catatan != null && catatan.isNotEmpty)
                        _buildDetailRow(
                          label: 'Catatan',
                          value: catatan,
                          icon: Icons.note,
                        ),
                      if (rejectionReason != null && rejectionReason.isNotEmpty)
                        _buildDetailRow(
                          label: 'Alasan Tolak',
                          value: rejectionReason,
                          valueColor: Colors.red,
                          icon: Icons.cancel,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bukti Pembayaran Card
                  _buildSectionCard(
                    title: 'Bukti Pembayaran',
                    children: [
                      Center(
                        child: Column(
                          children: [
                            if (buktiBayarUrl !=
                                'assets/placeholder_image.png') // Only show if valid URL
                              Image.network(
                                buktiBayarUrl,
                                height: 200,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        _buildErrorImagePlaceholder(size: 200),
                              )
                            else
                              _buildErrorImagePlaceholder(
                                size: 200,
                              ), // Show placeholder if URL is invalid/empty
                            const SizedBox(height: 10),
                            Text(
                              'Diunggah pada: $createdAt',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Informasi Pengguna & Pengelola Card
                  _buildSectionCard(
                    title: 'Informasi Pihak',
                    children: [
                      Text(
                        'Penghuni:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      _buildDetailRow(
                        label: 'Nama',
                        value: userData['full_name'] ?? 'N/A',
                        icon: Icons.person,
                      ),
                      _buildDetailRow(
                        label: 'Email',
                        value: userData['email'] ?? 'N/A',
                        icon: Icons.email,
                      ),
                      _buildDetailRow(
                        label: 'Telepon',
                        value: userData['phone'] ?? 'N/A',
                        icon: Icons.phone,
                      ),
                      const Divider(
                        height: 25,
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      Text(
                        'Pengelola:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      _buildDetailRow(
                        label: 'Nama',
                        value: pengelolaData['full_name'] ?? 'N/A',
                        icon: Icons.person_outline,
                      ),
                      _buildDetailRow(
                        label: 'Email',
                        value: pengelolaData['email'] ?? 'N/A',
                        icon: Icons.email,
                      ),
                      _buildDetailRow(
                        label: 'Telepon',
                        value: pengelolaData['phone'] ?? 'N/A',
                        icon: Icons.phone,
                      ),
                      if (validatorData['full_name'] != null &&
                          validatorData['full_name'].isNotEmpty) ...[
                        const Divider(
                          height: 25,
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                        Text(
                          'Divalidasi Oleh:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        _buildDetailRow(
                          label: 'Nama Validator',
                          value: validatorData['full_name'] ?? 'N/A',
                          icon: Icons.verified_user,
                        ),
                        _buildDetailRow(
                          label: 'Email Validator',
                          value: validatorData['email'] ?? 'N/A',
                          icon: Icons.email,
                        ),
                        _buildDetailRow(
                          label: 'Waktu Validasi',
                          value: validatedAt,
                          icon: Icons.access_time,
                        ),
                      ],
                    ],
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

  Widget _buildErrorImagePlaceholder({double size = 200}) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(Icons.broken_image, size: size / 2.5, color: Colors.grey),
    );
  }
}
