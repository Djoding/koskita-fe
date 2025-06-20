import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/makanan_screen.dart';
import 'package:kosan_euy/screens/owner/reservasi/edit_kos.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kosan_euy/screens/owner/laundry/dashboard_laundry.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_screen.dart';
import 'package:kosan_euy/services/api_service.dart';
import 'package:kosan_euy/services/pengelola_service.dart'; // Import ApiService

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

  List<String> _fullImageUrls = []; // New list to store full image URLs
  String? _fullQrisImageUrl; // New variable for full QRIS image URL

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

      if (response['status']) {
        setState(() {
          kostData = response['data'];

          // Generate full URLs for foto_kost
          _fullImageUrls =
              (kostData!['foto_kost'] as List<dynamic>?)
                  ?.map(
                    (path) =>
                        '${ApiService.baseUrl.replaceFirst('/api/v1/', '')}${path}',
                  )
                  .toList() ??
              [];

          // Generate full URL for qris_image
          if (kostData!['qris_image'] != null &&
              kostData!['qris_image'].isNotEmpty) {
            _fullQrisImageUrl =
                '${ApiService.baseUrl.replaceFirst('/api/v1/', '')}${kostData!['qris_image']}';
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
    // Show loading dialog
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Menghapus kost...'),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat detail kost...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchKostDetail,
                        child: Text('Coba Lagi'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(),
              _buildKostInfo(),
              _buildFasilitas(), // Sudah ada, tidak perlu diubah lagi
              _buildPeraturan(), // Sudah ada, tidak perlu diubah lagi
              _buildServiceMenus(),
              SizedBox(height: 20),
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
                  offset: Offset(0, 2),
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
          Spacer(),
          Text(
            'Detail Kost',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Spacer(),
          Container(width: 44), // Placeholder for symmetry
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    // Use _fullImageUrls here
    return Stack(
      children: [
        Container(
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
                      autoPlayInterval: Duration(seconds: 5),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items:
                        _fullImageUrls.map((imageUrl) {
                          return Container(
                            width: double.infinity,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey[600],
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, size: 80, color: Colors.grey[600]),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada foto',
                            style: TextStyle(color: Colors.grey[600]),
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                        size: 20,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            // Pass the actual kostData, not null
                            Get.to(() => EditKosScreen(kostData: kostData!));
                            break;
                          case 'delete':
                            _showDeleteConfirmation();
                            break;
                          case 'share':
                            // Implement share functionality
                            break;
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Edit Kost'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Hapus Kost'),
                                ],
                              ),
                            ),
                          ],
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
                    margin: EdgeInsets.symmetric(horizontal: 4),
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  kostData?['is_approved'] == true
                      ? Colors.green
                      : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              kostData?['is_approved'] == true ? 'Aktif' : 'Pending',
              style: TextStyle(
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
    // Parse `biaya_tambahan` from dynamic to double for comparison.
    // This is needed because the backend might send it as a String.
    final double? biayaTambahanParsed =
        kostData?['biaya_tambahan'] != null
            ? double.tryParse(kostData!['biaya_tambahan'].toString())
            : null;

    // Retrieve tipe kamar data
    final Map<String, dynamic>? tipeKamar = kostData?['tipe'];
    final String tipeKamarText =
        tipeKamar != null
            ? '${tipeKamar['nama_tipe']} - ${tipeKamar['ukuran'] ?? ''} (${tipeKamar['kapasitas']} orang)'
            : 'Tipe kamar tidak tersedia';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
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
              Icon(Icons.location_on, color: Colors.blue, size: 18),
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
          // Tipe Kamar (dipindahkan ke sini)
          Row(
            children: [
              Icon(Icons.meeting_room, color: Colors.blue, size: 18),
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
              SizedBox(width: 12),
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
            padding: EdgeInsets.all(16),
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
                SizedBox(height: 8),
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
                  SizedBox(height: 4),
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
                // Apply the fix here: use the parsed value for comparison
                if (biayaTambahanParsed != null && biayaTambahanParsed > 0) ...[
                  SizedBox(height: 4),
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
                Divider(),
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
                SizedBox(height: 12),
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
                SizedBox(height: 8),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.blue),
          SizedBox(width: 4),
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
                0) || // Safely parse before comparison
        (kostData?['kapasitas_parkir_mobil'] != null &&
            (double.tryParse(kostData!['kapasitas_parkir_mobil'].toString()) ??
                    0) >
                0); // Safely parse before comparison
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

    // Safely parse before using in text
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

    // Safely parse before using in text
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
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 8,
      children: specs,
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
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
      return SizedBox.shrink();
    }

    return Container(
      // Margin diubah agar konsisten dengan padding
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
          SizedBox(height: 12),
          Wrap(
            spacing: 8, // Jarak horizontal antar chip
            runSpacing: 8, // Jarak vertikal antar baris chip
            alignment: WrapAlignment.start, // Agar chip dimulai dari kiri
            crossAxisAlignment:
                WrapCrossAlignment.start, // Agar chip sejajar atas
            children:
                fasilitas.map((f) {
                  final fasilitasData = f['fasilitas'];
                  return Container(
                    // Menggunakan InkWell atau GestureDetector untuk respons sentuhan jika diperlukan
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min, // Agar ukuran container sesuai konten
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 6),
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
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
          SizedBox(height: 12),
          Column(
            children:
                peraturan.map((p) {
                  final peraturanData = p['peraturan'];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
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
                        SizedBox(width: 8),
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
                                SizedBox(height: 4),
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
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildServiceCard(
                'Reservasi Kamar',
                Icons.home_outlined,
                Colors.blue,
                () {
                  Get.toNamed('/home-reservasi-owner', arguments: kostData);
                },
              ),
              _buildServiceCard(
                'Manajemen Catering',
                Icons.restaurant_outlined,
                Colors.orange,
                () {
                  Get.to(
                    () => const LayananMakananScreen(),
                    arguments: kostData,
                  );
                },
              ),
              _buildServiceCard(
                'Manajemen Laundry',
                Icons.local_laundry_service_outlined,
                Colors.green,
                () {
                  Get.to(
                    () => const DashboardLaundryScreen(),
                    arguments: kostData,
                  );
                },
              ),
              _buildServiceCard(
                'Data Penghuni',
                Icons.people_outlined,
                Colors.purple,
                () {
                  Get.toNamed('/penghuni', arguments: kostData);
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
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            SizedBox(height: 12),
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
