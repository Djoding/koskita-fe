import 'dart:io'; // Import ini untuk menggunakan tipe File
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Tetap perlu untuk memilih gambar
import 'package:kosan_euy/screens/penghuni/dashboard_kos_screen.dart';
import 'package:kosan_euy/screens/penghuni/dashboard_tenant_screen.dart'; // Halaman tujuan setelah selesai
import 'package:kosan_euy/services/reservation_service.dart'; // Import ReservationService

class MenuPembayaranPenghuni extends StatefulWidget {
  final int amount;
  final String description;
  final String? qrisImage;
  final Map<String, dynamic>? rekeningInfo;
  final int? durasiBulan;
  final String? kostId;
  final String? reservasiId;
  final String?
  paymentPurpose; // Tambahkan parameter baru untuk tujuan pembayaran

  const MenuPembayaranPenghuni({
    super.key,
    required this.amount,
    required this.description,
    this.qrisImage,
    this.rekeningInfo,
    this.durasiBulan,
    this.kostId,
    this.reservasiId,
    this.paymentPurpose, // Inisialisasi parameter baru
  });

  @override
  State<MenuPembayaranPenghuni> createState() => _MenuPembayaranPenghuniState();
}

class _MenuPembayaranPenghuniState extends State<MenuPembayaranPenghuni> {
  File?
  _pickedImageFile; // State untuk menyimpan file gambar yang dipilih (tipe File)
  bool _isUploading = false; // State untuk menunjukkan apakah sedang mengunggah
  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker
  final ReservationService _reservationService =
      ReservationService(); // Instance ReservationService

  String?
  _selectedPaymentMethod; // State untuk menyimpan metode pembayaran yang dipilih dari dropdown

  // List metode pembayaran yang tersedia
  List<String> _availablePaymentMethods = [];

  @override
  void initState() {
    super.initState();
    _initializePaymentMethods();
  }

  void _initializePaymentMethods() {
    if (widget.qrisImage != null && widget.qrisImage!.isNotEmpty) {
      _availablePaymentMethods.add('QRIS');
    }
    if (_isBankInfoAvailable()) {
      _availablePaymentMethods.add('TRANSFER');
    }

    // Set metode pembayaran default jika hanya ada satu atau sesuai preferensi
    if (_availablePaymentMethods.isNotEmpty) {
      _selectedPaymentMethod = _availablePaymentMethods[0];
    } else {
      // Handle case where no payment methods are available (shouldn't happen if amount > 0)
      Get.snackbar(
        'Peringatan',
        'Tidak ada metode pembayaran yang tersedia.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  bool _isBankInfoAvailable() {
    return widget.rekeningInfo != null &&
        widget.rekeningInfo!['bank'] != null &&
        widget.rekeningInfo!['bank'] != 'Tidak Tersedia' &&
        widget.rekeningInfo!['nomor'] != null &&
        widget.rekeningInfo!['nomor'] != 'Tidak Tersedia';
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  String _cleanImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    // Perbaikan: Pastikan URL tidak memiliki duplikasi 'http://localhost:3000'
    String cleaned = rawUrl;
    if (cleaned.startsWith('http://localhost:3000http')) {
      cleaned = cleaned.substring('http://localhost:3000'.length);
    }
    // Perbaikan: Tambahkan base URL jika ini adalah path relatif dari server
    if (cleaned.startsWith('/uploads/')) {
      // Sesuaikan dengan path upload Anda di server
      cleaned = 'http://localhost:3000' + cleaned;
    }
    return cleaned;
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImageFile = File(image.path); // Konversi XFile ke File
      });
    } else {
      Get.snackbar(
        'Peringatan',
        'Pemilihan bukti pembayaran dibatalkan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitPaymentProof() async {
    if (_pickedImageFile == null) {
      Get.snackbar(
        'Error',
        'Tidak ada bukti pembayaran yang dipilih.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      Get.snackbar(
        'Error',
        'Metode pembayaran belum dipilih.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      if (widget.paymentPurpose == 'create_reservation') {
        if (widget.kostId == null || widget.durasiBulan == null) {
          throw Exception(
            'Data kost ID atau durasi bulan tidak lengkap untuk membuat reservasi baru.',
          );
        }

        // final result = await _reservationService.createReservation(
        //   kostId: widget.kostId!,
        //   tanggalCheckIn:
        //       DateTime.now().toIso8601String().split(
        //         'T',
        //       )[0], // Contoh tanggal check-in hari ini
        //   durasiBulan: widget.durasiBulan!,
        //   metodeBayar: _selectedPaymentMethod!,
        //   buktiBayarFile: _pickedImageFile!,
        // );

        // if (result['status'] == true) {
        //   Get.snackbar(
        //     'Sukses!',
        //     result['message'] ??
        //         'Reservasi berhasil dibuat. Menunggu konfirmasi pengelola.',
        //     snackPosition: SnackPosition.TOP,
        //     backgroundColor: Colors.green,
        //     colorText: Colors.white,
        //   );
        //   Get.offAll(() => const DashboardTenantScreen());
        // } else {
        //   Get.snackbar(
        //     'Gagal',
        //     result['message'] ?? 'Gagal membuat reservasi. Mohon coba lagi.',
        //     snackPosition: SnackPosition.TOP,
        //     backgroundColor: Colors.red,
        //     colorText: Colors.white,
        //   );
        // }
      } else if (widget.paymentPurpose == 'extend_reservation') {
        if (widget.reservasiId == null || widget.durasiBulan == null) {
          throw Exception(
            'ID Reservasi atau durasi bulan tidak lengkap untuk perpanjangan.',
          );
        }

        final result = await _reservationService.extendReservation(
          reservasiId: widget.reservasiId!,
          durasiPerpanjanganBulan: widget.durasiBulan!,
          metodeBayar: _selectedPaymentMethod!,
          buktiBayarFile: _pickedImageFile!,
        );

        if (result['status'] == true) {
          Get.snackbar(
            'Sukses!',
            result['message'] ?? 'Perpanjangan reservasi berhasil diproses.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAll(() => const KosScreen());
        } else {
          Get.snackbar(
            'Gagal',
            result['message'] ??
                'Gagal memperpanjang reservasi. Mohon coba lagi.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Tujuan pembayaran tidak valid.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error submitting payment proof: $e");
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mengunggah bukti pembayaran: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isUploading = false; // Nonaktifkan status loading
        _pickedImageFile = null; // Bersihkan gambar yang dipilih
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String bankName = widget.rekeningInfo?['bank'] ?? 'Tidak Tersedia';
    final String accountNumber =
        widget.rekeningInfo?['nomor'] ?? 'Tidak Tersedia';
    final String accountName =
        widget.rekeningInfo?['atas_nama'] ?? 'Tidak Tersedia';

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Text(
              'Pilih Metode Pembayaran\nDibawah Ini...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  _buildDetailPembayaranCard(context),
                  const SizedBox(height: 20),
                  // Dropdown untuk memilih metode pembayaran
                  _buildPaymentMethodDropdown(),
                  const SizedBox(height: 20),
                  // Tampilkan informasi sesuai metode yang dipilih
                  if (_selectedPaymentMethod == 'TRANSFER' &&
                      _isBankInfoAvailable())
                    _buildBankInfoCard(bankName, accountNumber, accountName),
                  if (_selectedPaymentMethod == 'QRIS' &&
                      widget.qrisImage != null &&
                      widget.qrisImage!.isNotEmpty)
                    _buildQrisImage(widget.qrisImage),
                  const SizedBox(height: 20),
                  // Tampilan gambar yang sudah dipilih (jika ada)
                  if (_pickedImageFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Text(
                            'Bukti Pembayaran Terpilih:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Image.file(
                            _pickedImageFile!,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isUploading ? null : _pickImage, // Pilih gambar dulu
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF119DB1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Pilih Bukti Bayar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 0,
              ), // Pindah tombol upload di bawah tombol pilih
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isUploading ||
                              _pickedImageFile ==
                                  null // Aktif jika tidak mengunggah & gambar sudah dipilih
                          ? null
                          : _submitPaymentProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF4CAF50,
                    ), // Warna hijau untuk tombol upload
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 5,
                  ),
                  child:
                      _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Unggah Bukti Bayar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ), // Tambahkan sedikit ruang di bagian bawah
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
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
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 22,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDetailPembayaranCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pembayaran',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.description,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (widget.durasiBulan != null)
              _buildDetailRow(
                label: 'Durasi Sewa',
                value: '${widget.durasiBulan} Bulan',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                valueStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            if (widget.durasiBulan != null) const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
                Text(
                  _formatPrice(widget.amount),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4D9DAB),
                  ),
                ),
              ],
            ),
            if (widget.kostId != null) const SizedBox(height: 10),
            if (widget.kostId != null)
              Text(
                'Kost ID: ${widget.kostId}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            if (widget.reservasiId != null) const SizedBox(height: 5),
            if (widget.reservasiId != null)
              Text(
                'Reservasi ID: ${widget.reservasiId}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    if (_availablePaymentMethods.isEmpty) {
      return const SizedBox.shrink(); // Jangan tampilkan dropdown jika tidak ada pilihan
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Pilih Metode',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items:
                  _availablePaymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoCard(
    String bankName,
    String accountNumber,
    String accountName,
  ) {
    // Kondisi untuk menampilkan card ini sudah ada di _initializePaymentMethods
    // dan _buildPaymentMethodDropdown, jadi di sini cukup pastikan tampilannya
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Transfer Bank',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            _buildDetailRow(
              label: 'Bank',
              value: bankName,
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              valueStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: 'Nomor Rekening',
              value: accountNumber,
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              valueStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: 'Atas Nama',
              value: accountName,
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              valueStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisImage(String? imageUrl) {
    final String cleanedUrl = _cleanImageUrl(imageUrl);
    if (cleanedUrl.isEmpty) {
      return const SizedBox.shrink(); // Sembunyikan jika URL kosong setelah dibersihkan
    }
    // Perbaikan: Asumsikan semua QRIS adalah Network Image karena datang dari server
    // Jika Anda punya QRIS lokal, Anda harus membedakannya.
    final bool isAsset = cleanedUrl.startsWith('assets/');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pembayaran QRIS',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            isAsset
                ? Image.asset(
                  cleanedUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildErrorImagePlaceholder(size: 250),
                )
                : Image.network(
                  cleanedUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 250,
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildErrorImagePlaceholder(size: 250),
                ),
            const SizedBox(height: 10),
            Text(
              'Scan QRIS ini untuk pembayaran',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                valueStyle ??
                GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
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
