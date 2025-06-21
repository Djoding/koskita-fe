// lib/screens/owner/reservasi/detail_validasi_reservasi_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/services/reservasi_management_service.dart';
import 'package:kosan_euy/widgets/success_screen.dart';

class DetailValidasiReservasiScreen extends StatefulWidget {
  final Map<String, dynamic> reservasi;
  final Map<String, dynamic> kostData;

  const DetailValidasiReservasiScreen({
    super.key,
    required this.reservasi,
    required this.kostData,
  });

  @override
  State<DetailValidasiReservasiScreen> createState() =>
      _DetailValidasiReservasiScreenState();
}

class _DetailValidasiReservasiScreenState
    extends State<DetailValidasiReservasiScreen> {
  Map<String, dynamic>? detailReservasi;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDetailReservasi();
  }

  Future<void> _fetchDetailReservasi() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      print(
        'Fetching detail for reservasi_id: ${widget.reservasi['reservasi_id']}',
      ); // Debug log

      final response = await ReservasiManagementService.getReservasiDetail(
        widget.reservasi['reservasi_id'],
      );

      if (response['status']) {
        setState(() {
          detailReservasi = response['data'];
          isLoading = false;
        });
        print('Detail reservasi loaded successfully'); // Debug log
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load detail';
          isLoading = false;
        });
        print('Failed to load detail: ${response['message']}'); // Debug log
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
      print('Error fetching detail: $e'); // Debug log
    }
  }

  Future<void> _updateStatus(String status, {String? rejectionReason}) async {
    // Show loading dialog
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              status == 'APPROVED'
                  ? 'Menyetujui reservasi...'
                  : 'Menolak reservasi...',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await ReservasiManagementService.updateReservasiStatus(
        widget.reservasi['reservasi_id'],
        status: status,
        rejectionReason: rejectionReason,
      );

      Get.back(); // Close loading dialog

      if (response['status']) {
        Get.back(); // Back to list
        Get.snackbar(
          'Sukses',
          status == 'APPROVED'
              ? 'Reservasi berhasil disetujui'
              : 'Reservasi berhasil ditolak',
          backgroundColor: status == 'APPROVED' ? Colors.green : Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal mengupdate status reservasi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF86B0DD),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Memuat detail reservasi...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF86B0DD),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchDetailReservasi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF86B0DD),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use detailReservasi if available, otherwise use original reservasi data
    final reservationData = detailReservasi ?? widget.reservasi;

    return Scaffold(
      backgroundColor: const Color(0xFF86B0DD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUserInfo(reservationData),
              const SizedBox(height: 16),
              _buildReservationInfo(reservationData),
              const SizedBox(height: 16),
              _buildPaymentInfo(reservationData),
              const SizedBox(height: 32),
              if (widget.reservasi['status_reservasi'] == 'PENDING')
                _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          const Spacer(),
          Text(
            'Detail Reservasi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44), // Placeholder for symmetry
        ],
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> reservationData) {
    final user = reservationData['user'] ?? widget.reservasi['user'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Pemesan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF86B0DD).withOpacity(0.2),
                    child: Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF86B0DD),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow('Nama Lengkap', user['full_name'] ?? ''),
                        _InfoRow('Email', user['email'] ?? ''),
                        if (user['phone'] != null)
                          _InfoRow('No. Telepon', user['phone']),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationInfo(Map<String, dynamic> reservationData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Reservasi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow('Kost', widget.kostData['nama_kost'] ?? ''),
              _InfoRow(
                'Tanggal Check-in',
                reservationData['tanggal_check_in'] ?? '',
              ),
              _InfoRow(
                'Tanggal Check-out',
                reservationData['tanggal_keluar'] ?? 'Belum ditentukan',
              ),
              _InfoRow(
                'Durasi Sewa',
                '${reservationData['durasi_bulan'] ?? 0} bulan',
              ),
              _InfoRow(
                'Total Biaya',
                'Rp ${_formatCurrency(reservationData['total_harga'])}',
              ),
              if (reservationData['deposit_amount'] != null)
                _InfoRow(
                  'Deposit',
                  'Rp ${_formatCurrency(reservationData['deposit_amount'])}',
                ),
              if (reservationData['catatan'] != null &&
                  reservationData['catatan'].toString().isNotEmpty)
                _InfoRow('Catatan', reservationData['catatan']),
              if (reservationData['rejection_reason'] != null &&
                  reservationData['rejection_reason'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alasan Penolakan:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.red[800],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservationData['rejection_reason'],
                        style: GoogleFonts.poppins(
                          color: Colors.red[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(Map<String, dynamic> reservationData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Pembayaran',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                'Metode Pembayaran',
                reservationData['metode_bayar'] ?? '',
              ),
              const SizedBox(height: 12),
              Text(
                'Bukti Pembayaran',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (reservationData['bukti_bayar'] != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      reservationData['bukti_bayar'],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text('Gagal memuat gambar'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Bukti pembayaran tidak tersedia'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showRejectDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Tolak',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showApproveDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Setujui',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Konfirmasi Persetujuan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin menyetujui reservasi dari ${widget.reservasi['user']['full_name']}?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus('APPROVED');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Setujui',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Tolak Reservasi',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berikan alasan penolakan:',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan alasan penolakan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateStatus(
                    'REJECTED',
                    rejectionReason: reasonController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Tolak',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';

    double value;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    } else if (amount is num) {
      value = amount.toDouble();
    } else {
      return '0';
    }

    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
