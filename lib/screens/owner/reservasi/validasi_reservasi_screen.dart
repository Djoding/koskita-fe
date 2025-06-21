// lib/screens/owner/reservasi/validasi_reservasi_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/services/reservasi_management_service.dart';
import 'package:kosan_euy/screens/owner/reservasi/detail_validasi_reservasi_screen.dart';

class ValidasiReservasiScreen extends StatefulWidget {
  const ValidasiReservasiScreen({super.key});

  @override
  State<ValidasiReservasiScreen> createState() =>
      _ValidasiReservasiScreenState();
}

class _ValidasiReservasiScreenState extends State<ValidasiReservasiScreen> {
  Map<String, dynamic>? kostData;
  Map<String, dynamic>? reservasiData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Get kost data from arguments
    kostData = Get.arguments;
    if (kostData != null) {
      _fetchReservasi();
    } else {
      setState(() {
        errorMessage = 'Data kost tidak ditemukan';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchReservasi() async {
    if (kostData == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await ReservasiManagementService.getReservasiByKost(
        kostData!['kost_id'],
      );

      if (response['status']) {
        setState(() {
          reservasiData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load reservations';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF86B0DD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Reservasi ${kostData?['nama_kost'] ?? 'Kost'}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Memuat data reservasi...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            else if (errorMessage.isNotEmpty)
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
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchReservasi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF86B0DD),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchReservasi,
                  child: _buildReservasiContent(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservasiContent() {
    if (reservasiData == null) {
      return const Center(
        child: Text(
          'Data reservasi tidak tersedia',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Kost info
    final kostInfo = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.home, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reservasiData!['nama_kost'] ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatusCount(
                'Total Kamar',
                reservasiData!['total_kamar'] ?? 0,
                Colors.blue,
              ),
              _StatusCount(
                'Terisi',
                reservasiData!['total_occupied_rooms'] ?? 0,
                Colors.orange,
              ),
              _StatusCount(
                'Tersedia',
                reservasiData!['available_rooms'] ?? 0,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );

    return ListView(
      children: [
        kostInfo,
        _buildReservationSection(
          'Menunggu Validasi',
          reservasiData!['reservations']['pending_upcoming'] ?? [],
          Colors.orange,
        ),
        _buildReservationSection(
          'Penghuni Aktif',
          reservasiData!['reservations']['active'] ?? [],
          Colors.green,
        ),
        _buildReservationSection(
          'Riwayat',
          reservasiData!['reservations']['history'] ?? [],
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildReservationSection(
    String title,
    List<dynamic> reservations,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(width: 4, height: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  '$title (${reservations.length})',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (reservations.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Tidak ada data reservasi',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...reservations.map(
              (reservation) => _buildReservationCard(reservation),
            ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    final bool isPending = reservation['status_reservasi'] == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () => DetailValidasiReservasiScreen(
              reservasi: reservation,
              kostData: kostData!,
            ),
          )?.then((_) => _fetchReservasi()); // Refresh after returning
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF86B0DD).withOpacity(0.2),
                    child: Text(
                      (reservation['user']['full_name'] ?? 'U')[0]
                          .toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF86B0DD),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation['user']['full_name'] ?? '',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          reservation['user']['email'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(
                    reservation['status_reservasi'],
                    reservation['status_penghunian'],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Periode
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${reservation['tanggal_check_in']} - ${reservation['tanggal_keluar'] ?? 'Belum ditentukan'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Total harga
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Rp ${_formatCurrency(reservation['total_harga'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  if (isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Perlu Validasi',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? statusReservasi, String? statusPenghunian) {
    Color color;
    String text;

    if (statusReservasi == 'PENDING') {
      color = Colors.orange;
      text = 'Pending';
    } else if (statusReservasi == 'APPROVED') {
      if (statusPenghunian == 'AKTIF') {
        color = Colors.green;
        text = 'Aktif';
      } else if (statusPenghunian == 'KELUAR') {
        color = Colors.grey;
        text = 'Keluar';
      } else {
        color = Colors.blue;
        text = 'Disetujui';
      }
    } else if (statusReservasi == 'REJECTED') {
      color = Colors.red;
      text = 'Ditolak';
    } else {
      color = Colors.grey;
      text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
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

class _StatusCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCount(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
