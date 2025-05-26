import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PesananDetail {
  final String noReferensi;
  final DateTime tanggalMasuk;
  final DateTime jamPemesanan;
  final DateTime tanggalKeluar;
  final String namaKamar;
  final String gambarKamarAsset;
  final double totalBiaya;

  PesananDetail({
    required this.noReferensi,
    required this.tanggalMasuk,
    required this.jamPemesanan,
    required this.tanggalKeluar,
    required this.namaKamar,
    required this.gambarKamarAsset,
    required this.totalBiaya,
  });
}

class NotificationReservasiDetail extends StatefulWidget {
  final String detailNotifikasiId;
  const NotificationReservasiDetail({super.key, this.detailNotifikasiId = ''});

  @override
  State<NotificationReservasiDetail> createState() =>
      _NotificationReservasiDetailState();
}

class _NotificationReservasiDetailState
    extends State<NotificationReservasiDetail> {
  bool _isLoading = true;
  PesananDetail? _detailPesanan;

  late DateFormat _dateFormatLong;
  late DateFormat _timeFormat;
  late NumberFormat _currencyFormat;

  @override
  void initState() {
    super.initState();
    _initializeFormattersAndFetchData();
  }

  Future<void> _initializeFormattersAndFetchData() async {
    await initializeDateFormatting('id_ID', null);

    _dateFormatLong = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    _timeFormat = DateFormat('HH.mm', 'id_ID');
    _currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    _fetchAndProcessData();
  }

  Future<void> _fetchAndProcessData() async {
    await Future.delayed(const Duration(seconds: 1));

    _detailPesanan = PesananDetail(
      noReferensi: '12345',
      tanggalMasuk: DateTime(2024, 12, 10),
      jamPemesanan: DateTime(2024, 12, 10, 10, 0),
      tanggalKeluar: DateTime(2025, 12, 10),
      namaKamar: 'Kamar No 10',
      gambarKamarAsset: 'assets/home.png',
      totalBiaya: 12000000,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : _buildContentLoaded(),
      ),
    );
  }

  Widget _buildContentLoaded() {
    if (_detailPesanan == null) {
      return Center(
        child: Text(
          'Gagal memuat detail pesanan.',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      // Tambahkan SingleChildScrollView agar bisa di-scroll jika konten panjang
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 24.0,
        right: 24.0,
        bottom: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Pesanan', // Judul Halaman
                  textAlign: TextAlign.center, // Tengahkan judul
                  style: GoogleFonts.poppins(
                    fontSize: 22, // Ukuran font judul
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 44 + 16,
              ), // Placeholder untuk menyeimbangkan tombol kembali
            ],
          ),
          const SizedBox(height: 35),

          Text(
            'Informasi Pemesan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('No Referensi', _detailPesanan!.noReferensi),
                _buildInfoRow(
                  'Tanggal Masuk',
                  _dateFormatLong.format(_detailPesanan!.tanggalMasuk),
                ),
                _buildInfoRow(
                  'Jam Pemesanan',
                  '${_timeFormat.format(_detailPesanan!.jamPemesanan)} WIB',
                ),
                _buildInfoRow(
                  'Tanggal Keluar',
                  _dateFormatLong.format(_detailPesanan!.tanggalKeluar),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // --- Daftar Pesanan ---
          Text(
            'Daftar Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFCFE8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withAlpha((0.5 * 255).toInt()),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _detailPesanan!.namaKamar,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 15),
                Image.asset(
                  _detailPesanan!.gambarKamarAsset,
                  height: 120, // Sesuaikan tinggi gambar
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Colors.white.withAlpha((0.8 * 255).toInt()),
                  thickness: 1,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_detailPesanan!.totalBiaya),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
