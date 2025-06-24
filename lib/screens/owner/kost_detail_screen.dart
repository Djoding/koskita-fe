// lib/screens/owner/kost_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kosan_euy/screens/owner/laundry/dashboard_laundry_screen.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_screen.dart';
import 'package:kosan_euy/screens/owner/reservasi/edit_kos.dart';
import 'package:kosan_euy/screens/owner/reservasi/validasi_reservasi_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/api_service.dart';
import 'package:kosan_euy/services/pengelola_service.dart';
import 'package:kosan_euy/routes/app_pages.dart';

class KostDetailScreen extends StatefulWidget {
  final String kostId;

  const KostDetailScreen({super.key, required this.kostId});

  @override
  State<KostDetailScreen> createState() => _KostDetailScreenState();
}

class _KostDetailScreenState extends State<KostDetailScreen> {
  Map<String, dynamic>? kostData;
  bool isLoading = true;
  String errorMessage = '';
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<String> _fullImageUrls = [];
  String? _fullQrisImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchKostDetail();
  }

  Future<void> _fetchKostDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await PengelolaService.getKostById(widget.kostId);

      print('API Response: $response'); // Debug keseluruhan response

      if (response['status']) {
        setState(() {
          kostData = response['data'];

          // Debug data yang diterima
          print('Raw kostData: $kostData');
          print('Raw foto_kost: ${kostData!['foto_kost']}');
          print('ApiService.baseUrl: ${ApiService.baseUrl}');

          // Process dengan cara yang aman
          final fotoKostList = kostData!['foto_kost'] as List<dynamic>? ?? [];
          print('foto_kost as List: $fotoKostList');

          _fullImageUrls =
              fotoKostList.map((path) {
                String cleanUrl = path.toString();
                print('Original path: $cleanUrl');

                // Bersihkan URL dari duplikasi localhost
                while (cleanUrl.contains(
                  'http://kost-kita.my.idhttp://kost-kita.my.id',
                )) {
                  cleanUrl = cleanUrl.replaceFirst(
                    'http://kost-kita.my.idhttp://kost-kita.my.id',
                    'http://kost-kita.my.id',
                  );
                }

                // Jika dimulai dengan http://kost-kita.my.idhttp, hilangkan yang pertama
                if (cleanUrl.startsWith('http://kost-kita.my.idhttp')) {
                  cleanUrl = cleanUrl.substring(
                    'http://kost-kita.my.id'.length,
                  );
                }

                // Jika sudah berupa URL lengkap (https:// atau http://), gunakan langsung
                if (cleanUrl.startsWith('https://') ||
                    cleanUrl.startsWith('http://')) {
                  print('Final clean URL: $cleanUrl');
                  return cleanUrl;
                }

                // Jika masih berupa path relatif, tambahkan base URL
                if (cleanUrl.startsWith('/')) {
                  cleanUrl = cleanUrl.substring(1);
                }

                final fullUrl = 'http://kost-kita.my.id/$cleanUrl';
                print('Generated URL: $fullUrl');
                return fullUrl;
              }).toList();

          print('Final _fullImageUrls: $_fullImageUrls');

          // Process qris_image dengan logika yang sama
          if (kostData!['qris_image'] != null &&
              kostData!['qris_image'].toString().isNotEmpty) {
            String qrisUrl = kostData!['qris_image'].toString();

            // Bersihkan duplikasi
            while (qrisUrl.contains(
              'http://kost-kita.my.idhttp://kost-kita.my.id',
            )) {
              qrisUrl = qrisUrl.replaceFirst(
                'http://kost-kita.my.idhttp://kost-kita.my.id',
                'http://kost-kita.my.id',
              );
            }

            if (qrisUrl.startsWith('http://kost-kita.my.idhttp')) {
              qrisUrl = qrisUrl.substring('http://kost-kita.my.id'.length);
            }

            _fullQrisImageUrl = qrisUrl;
          } else {
            _fullQrisImageUrl = null;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load kost detail';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _fetchKostDetail: $e');
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Hapus Kost',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kost ini? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteKost();
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteKost() async {
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Menghapus kost...', style: GoogleFonts.poppins()),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await PengelolaService.deleteKost(widget.kostId);

      Get.back(); // Close loading dialog

      if (response['status']) {
        Get.back(); // Back to dashboard
        Get.snackbar(
          'Sukses',
          response['message'] ?? 'Kost berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal menghapus kost',
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Memuat detail kost...',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
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
                        onPressed: _fetchKostDetail,
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

    return Scaffold(
      backgroundColor: const Color(0xFF86B0DD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(),
              _buildKostInfo(),
              _buildFasilitas(),
              _buildPeraturan(),
              _buildServiceMenus(),
              const SizedBox(height: 20),
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
            'Detail Kost',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Placeholder for symmetry (removed old refresh button)
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        SizedBox(
          // Changed Container to SizedBox for explicit sizing
          height: 300,
          width: double.infinity,
          child:
              _fullImageUrls.isNotEmpty
                  ? CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items:
                        _fullImageUrls.map((imageUrl) {
                          return SizedBox(
                            // Changed Container to SizedBox
                            width: double.infinity,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                  )
                  : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, size: 80, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada foto',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),

        // Header overlay
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
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
              Row(
                children: [
                  // Refresh button added here
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh, // Refresh icon
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: _fetchKostDetail, // Call refresh logic
                    ),
                  ),
                  const SizedBox(width: 8), // Spacer between buttons
                  // Edit button with background
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.black,
                        size: 20,
                      ),
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            final result = await Get.to(
                              () => EditKosScreen(kostData: kostData!),
                            );
                            if (result == true) {
                              _fetchKostDetail();
                            }
                            break;
                          case 'delete':
                            _showDeleteConfirmation();
                            break;
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Edit Kost',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Hapus Kost',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ),
                  const SizedBox(width: 8), // Spasi antara kedua button
                  // Settings button with background
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.black,
                        size: 20, // Ubah dari 28 ke 20 untuk konsistensi
                      ),
                      onPressed: () => Get.to(() => SettingScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Image dots indicator
        if (_fullImageUrls.isNotEmpty && _fullImageUrls.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_fullImageUrls.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _carouselController.animateToPage(index);
                  },
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              }),
            ),
          ),

        // Status badge
        Positioned(
          top: 80,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  kostData?['is_approved'] == true
                      ? Colors.green
                      : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              kostData?['is_approved'] == true ? 'Aktif' : 'Pending',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKostInfo() {
    final double? biayaTambahanParsed =
        kostData?['biaya_tambahan'] != null
            ? double.tryParse(kostData!['biaya_tambahan'].toString())
            : null;

    final Map<String, dynamic>? tipeKamar = kostData?['tipe'];
    final String tipeKamarText =
        tipeKamar != null
            ? '${tipeKamar['nama_tipe']} - ${tipeKamar['ukuran'] ?? ''} (${tipeKamar['kapasitas']} orang)'
            : 'Tipe kamar tidak tersedia';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama dan lokasi
          Text(
            kostData?['nama_kost'] ?? 'Nama Kost',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  kostData?['alamat'] ?? 'Alamat tidak tersedia',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Tipe Kamar
          Row(
            children: [
              const Icon(Icons.meeting_room, color: Colors.blue, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  tipeKamarText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info singkat
          Row(
            children: [
              _buildInfoChip(
                Icons.home_outlined,
                'Total: ${kostData?['total_kamar'] ?? 0} kamar',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.check_circle_outline,
                'Tersedia: ${kostData?['available_rooms'] ?? 0}',
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Harga
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Harga',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga Bulanan:',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    Text(
                      'Rp ${_formatCurrency(kostData?['harga_bulanan'])}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (kostData?['deposit'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deposit:',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        'Rp ${_formatCurrency(kostData?['deposit'])}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (biayaTambahanParsed != null && biayaTambahanParsed > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biaya Tambahan:',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        'Rp ${_formatCurrency(kostData?['biaya_tambahan'])}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga Final:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${_formatCurrency(kostData?['harga_final'])}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Spesifikasi
          if (_hasSpecifications())
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spesifikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSpecificationGrid(),
              ],
            ),

          const SizedBox(height: 16),

          // Deskripsi
          if (kostData?['deskripsi'] != null &&
              kostData!['deskripsi'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kostData!['deskripsi'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.blue),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSpecifications() {
    return (kostData?['daya_listrik'] != null &&
            kostData!['daya_listrik'].isNotEmpty) ||
        (kostData?['sumber_air'] != null &&
            kostData!['sumber_air'].isNotEmpty) ||
        (kostData?['wifi_speed'] != null &&
            kostData!['wifi_speed'].isNotEmpty) ||
        (kostData?['jam_survey'] != null &&
            kostData!['jam_survey'].isNotEmpty) ||
        (kostData?['kapasitas_parkir_motor'] != null &&
            (double.tryParse(kostData!['kapasitas_parkir_motor'].toString()) ??
                    0) >
                0) ||
        (kostData?['kapasitas_parkir_mobil'] != null &&
            (double.tryParse(kostData!['kapasitas_parkir_mobil'].toString()) ??
                    0) >
                0);
  }

  Widget _buildSpecificationGrid() {
    List<Widget> specs = [];

    if (kostData?['daya_listrik'] != null &&
        kostData!['daya_listrik'].isNotEmpty) {
      specs.add(
        _buildSpecItem(
          Icons.electrical_services,
          'Daya Listrik',
          kostData!['daya_listrik'],
        ),
      );
    }

    if (kostData?['sumber_air'] != null && kostData!['sumber_air'].isNotEmpty) {
      specs.add(
        _buildSpecItem(Icons.water_drop, 'Sumber Air', kostData!['sumber_air']),
      );
    }

    if (kostData?['wifi_speed'] != null && kostData!['wifi_speed'].isNotEmpty) {
      specs.add(
        _buildSpecItem(Icons.wifi, 'Kecepatan WiFi', kostData!['wifi_speed']),
      );
    }

    if (kostData?['jam_survey'] != null && kostData!['jam_survey'].isNotEmpty) {
      specs.add(
        _buildSpecItem(
          Icons.access_time,
          'Jam Survey',
          kostData!['jam_survey'],
        ),
      );
    }

    final int kapasitasParkirMotorDisplay =
        (double.tryParse(kostData!['kapasitas_parkir_motor'].toString()) ?? 0)
            .toInt();
    if (kapasitasParkirMotorDisplay > 0) {
      specs.add(
        _buildSpecItem(
          Icons.two_wheeler,
          'Parkir Motor',
          '${kapasitasParkirMotorDisplay} unit',
        ),
      );
    }

    final int kapasitasParkirMobilDisplay =
        (double.tryParse(kostData!['kapasitas_parkir_mobil'].toString()) ?? 0)
            .toInt();
    if (kapasitasParkirMobilDisplay > 0) {
      specs.add(
        _buildSpecItem(
          Icons.directions_car,
          'Parkir Mobil',
          '${kapasitasParkirMobilDisplay} unit',
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 8,
      children: specs,
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFasilitas() {
    final fasilitas = kostData?['kost_fasilitas'] as List?;

    if (fasilitas == null || fasilitas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fasilitas',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children:
                fasilitas.map((f) {
                  final fasilitasData = f['fasilitas'];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          fasilitasData['nama_fasilitas'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeraturan() {
    final peraturan = kostData?['kost_peraturan'] as List?;

    if (peraturan == null || peraturan.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peraturan Kost',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children:
                peraturan.map((p) {
                  final peraturanData = p['peraturan'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.orange[800],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                peraturanData['nama_peraturan'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (p['keterangan_tambahan'] != null &&
                                  p['keterangan_tambahan'].isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  p['keterangan_tambahan'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceMenus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layanan Kost',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildServiceCard(
                'Reservasi Kamar',
                'assets/icon_reservasi.png',
                Colors.blue,
                () {
                  // Navigasi ke reservasi management dengan data kost
                  Get.to(
                    () => const ValidasiReservasiScreen(),
                    arguments: kostData, // Pass kostData
                  );
                },
              ),
              _buildServiceCard(
                'Manajemen Catering',
                'assets/icon_makanan.png',
                Colors.orange,
                () {
                  // Pastikan kostData dikirim dengan benar
                  Get.to(
                    () =>
                        const LayananMakananScreen(), // Dashboard Layanan Makanan
                    arguments: kostData, // kostData dari response API
                  );
                },
              ),
              _buildServiceCard(
                'Manajemen Laundry',
                'assets/icon_laundry.png',
                Colors.green,
                () {
                  Get.to(
                    () =>
                        const DashboardLaundryScreen(), // Gunakan screen yang baru
                    arguments: kostData,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    dynamic icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ubah bagian icon untuk menyamakan dengan _LayananCard
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  icon is IconData
                      ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 28, color: color),
                      )
                      : Image.asset(
                        icon,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain, // Ubah dari cover ke contain
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                size: 25,
                                color: Colors.grey,
                              ),
                            ),
                      ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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

    String formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return formatted;
  }
}
