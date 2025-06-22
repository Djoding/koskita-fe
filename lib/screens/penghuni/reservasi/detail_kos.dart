import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/penghuni/reservasi/reservation_form_screen.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:kosan_euy/services/auth_service.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/services/kost_service.dart';
import 'package:intl/intl.dart';

class DetailKos extends StatefulWidget {
  const DetailKos({super.key});

  @override
  State<DetailKos> createState() => _DetailKosState();
}

class _DetailKosState extends State<DetailKos> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final AuthService _authService = AuthService();
  final KostService _kostService = KostService();
  bool _isLoggedIn = false;

  Map<String, dynamic>? _kostDetailData;
  String? _currentKostId;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['id'] != null) {
      _currentKostId = args['id'] as String;
      _fetchKostDetail(_currentKostId!);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID Kos tidak ditemukan untuk memuat detail.';
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  Future<void> _fetchKostDetail(String kostId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _kostService.getKostById(kostId);
      if (result['status'] == true && result['data'] != null) {
        setState(() {
          _kostDetailData = Map<String, dynamic>.from(result['data']);
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal mengambil detail kos.';
        });
      }
    } catch (e) {
      debugPrint("Error fetching kost detail: $e");
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatPriceDisplay(int price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(price);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Memuat Detail Kos...',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF91B7DE),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Error',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF91B7DE),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_currentKostId != null) {
                      _fetchKostDetail(_currentKostId!);
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
      );
    }

    if (_kostDetailData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Detail Kos Tidak Tersedia',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF91B7DE),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Data kos tidak ditemukan.')),
      );
    }

    final String namaKost =
        _kostDetailData!['nama_kost'] ?? 'Nama tidak tersedia';
    final String alamat = _kostDetailData!['alamat'] ?? 'Alamat tidak tersedia';
    final String hargaBulananDisplay = _kostDetailData!['harga_bulanan'] ?? '0';
    final List<dynamic> fotoKostRaw = _kostDetailData!['foto_kost'] ?? [];
    final String deskripsi = _kostDetailData!['deskripsi'] ?? 'Tidak tersedia';
    final String totalKamar =
        _kostDetailData!['total_kamar']?.toString() ?? 'N/A';
    final String availableRooms =
        _kostDetailData!['available_rooms']?.toString() ?? 'N/A';
    final String dayaListrik =
        _kostDetailData!['daya_listrik'] ?? 'Tidak tersedia';
    final String sumberAir = _kostDetailData!['sumber_air'] ?? 'Tidak tersedia';
    final String wifiSpeed = _kostDetailData!['wifi_speed'] ?? 'Tidak tersedia';
    final String parkirMotor =
        _kostDetailData!['kapasitas_parkir_motor']?.toString() ?? '0';
    final String parkirMobil =
        _kostDetailData!['kapasitas_parkir_mobil']?.toString() ?? '0';
    final String parkirSepeda =
        _kostDetailData!['kapasitas_parkir_sepeda']?.toString() ?? '0';

    final List<dynamic> kostFasilitasRaw =
        _kostDetailData!['kost_fasilitas'] ?? [];
    final Map<String, List<String>> organizedFasilitas = _organizeFasilitas(
      kostFasilitasRaw,
    );

    final String fasilitasKamar =
        organizedFasilitas['KAMAR']?.join('\n') ?? 'Tidak tersedia';
    final String fasilitasKamarMandi =
        organizedFasilitas['KAMAR_MANDI']?.join('\n') ?? 'Tidak tersedia';
    String fasilitasUmumContent = organizedFasilitas['UMUM']?.join('\n') ?? '';
    fasilitasUmumContent +=
        '\nDaya Listrik: ${_kostDetailData!['daya_listrik'] ?? 'Tidak tersedia'}';
    fasilitasUmumContent += '\nSumber Air: $sumberAir';
    fasilitasUmumContent += '\nKecepatan WiFi: $wifiSpeed';
    fasilitasUmumContent += '\nParkir Motor: $parkirMotor';
    fasilitasUmumContent += '\nParkir Mobil: $parkirMobil';
    fasilitasUmumContent += '\nParkir Sepeda: $parkirSepeda';
    if (fasilitasUmumContent.trim().isEmpty) {
      fasilitasUmumContent = 'Tidak tersedia';
    }

    final Map<String, dynamic>? tipeData =
        _kostDetailData!['tipe'] as Map<String, dynamic>?;
    final String namaTipe = tipeData?['nama_tipe'] ?? 'Tidak tersedia';
    final String ukuranTipe = tipeData?['ukuran'] ?? 'Tidak tersedia';
    final String kapasitasTipe =
        tipeData?['kapasitas']?.toString() ?? 'Tidak tersedia';
    final List<dynamic> kostPeraturanRaw =
        _kostDetailData!['kost_peraturan'] ?? [];
    final String peraturanKos = _formatPeraturan(kostPeraturanRaw);

    final List<String> imageUrls =
        fotoKostRaw.map((url) {
          String cleanUrl = url.toString();
          if (cleanUrl.startsWith('http://localhost:3000http')) {
            cleanUrl = cleanUrl.substring('http://localhost:3000'.length);
          }
          return cleanUrl;
        }).toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 255, 243, 1.0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    enableInfiniteScroll: true,
                    enlargeCenterPage: false,
                  ),
                  items:
                      imageUrls.map((imageUrl) {
                        final bool isAsset = imageUrl.startsWith('assets/');
                        return isAsset
                            ? Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildErrorImageWidget(height: 300),
                            )
                            : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 300,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    color: const Color(0xFF119DB1),
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildErrorImageWidget(height: 300),
                            );
                      }).toList(),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imageUrls.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          _carouselController.animateToPage(index);
                        },
                        child: Container(
                          width: _currentIndex == index ? 20.0 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color:
                                _currentIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.6),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(241, 255, 243, 1.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaKost,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          alamat,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.blueGrey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$availableRooms kamar tersedia dari $totalKamar kamar',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Rp ${_formatPriceDisplay(int.parse(hargaBulananDisplay))} / Per Bulan",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildSectionCard(
                    title: "Deskripsi Properti:",
                    content: deskripsi,
                  ),
                  const SizedBox(height: 15),
                  if (fasilitasKamarMandi.isNotEmpty &&
                      fasilitasKamarMandi != 'Tidak tersedia')
                    _buildSectionCard(
                      title: "Fasilitas Kamar Mandi:",
                      content: fasilitasKamarMandi,
                    ),
                  const SizedBox(height: 15),
                  if (fasilitasUmumContent.isNotEmpty &&
                      fasilitasUmumContent != 'Tidak tersedia')
                    _buildSectionCard(
                      title: "Fasilitas Umum:",
                      content: fasilitasUmumContent,
                    ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: "Tipe Kamar:",
                    content:
                        'Tipe: $namaTipe\nUkuran: $ukuranTipe\nKapasitas: $kapasitasTipe orang\nDaya Listrik: $dayaListrik',
                  ),
                  const SizedBox(height: 15),
                  _buildSectionCard(
                    title: "Peraturan Kost:",
                    content: peraturanKos,
                  ),
                  const SizedBox(height: 15),
                  if (fasilitasKamar.isNotEmpty &&
                      fasilitasKamar != 'Tidak tersedia')
                    _buildSectionCard(
                      title: "Fasilitas Kamar:",
                      content: fasilitasKamar,
                    ),
                  const SizedBox(height: 25),
                  Text(
                    "Lokasi Kost:",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alamat,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A99BD),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xFF4A99BD).withOpacity(0.4),
                    ),
                    onPressed: () {
                      if (_isLoggedIn) {
                        if (_kostDetailData == null) {
                          Get.snackbar(
                            'Error',
                            'Detail kos belum dimuat. Mohon coba lagi.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final int? totalKamar = int.tryParse(
                          _kostDetailData!['total_kamar']?.toString() ?? '0',
                        );
                        final int? availableRooms = int.tryParse(
                          _kostDetailData!['available_rooms']?.toString() ??
                              '0',
                        );

                        // Validasi ketersediaan kamar
                        if (totalKamar == null ||
                            availableRooms == null ||
                            availableRooms <= 0) {
                          Get.snackbar(
                            'Peringatan',
                            'Tidak ada kamar yang tersedia saat ini.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        Get.to(
                          () => InitialReservationFormScreen(
                            kostDetailData: _kostDetailData!,
                            currentKostId: _currentKostId!,
                          ),
                        );
                      } else {
                        Get.to(() => const HomeScreenPage());
                      }
                    },
                    child: Text(
                      "Pesan Sekarang",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor, size: 24),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    if (content.isEmpty || content == 'Tidak tersedia') {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImageWidget({double? height, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 80, color: Colors.grey[400]),
          Text(
            'Gambar tidak tersedia',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _organizeFasilitas(List<dynamic> rawFasilitas) {
    final Map<String, List<String>> organized = {
      'KAMAR': [],
      'KAMAR_MANDI': [],
      'UMUM': [],
      'PARKIR': [],
    };

    for (var item in rawFasilitas) {
      if (item['fasilitas'] != null) {
        final String kategori = item['fasilitas']['kategori'] ?? 'UMUM';
        final String namaFasilitas = item['fasilitas']['nama_fasilitas'] ?? '';
        if (namaFasilitas.isNotEmpty) {
          if (organized.containsKey(kategori)) {
            organized[kategori]!.add(namaFasilitas);
          } else {
            organized['UMUM']!.add(namaFasilitas);
          }
        }
      }
    }
    return organized;
  }

  String _formatPeraturan(List<dynamic> rawPeraturan) {
    if (rawPeraturan.isEmpty) {
      return 'Tidak ada peraturan yang tersedia.';
    }
    List<String> formattedRules = [];
    for (var item in rawPeraturan) {
      if (item['peraturan'] != null) {
        String ruleName = item['peraturan']['nama_peraturan'] ?? '';
        String additionalInfo = item['keterangan_tambahan'] ?? '';
        if (ruleName.isNotEmpty) {
          String ruleEntry = '• $ruleName';
          if (additionalInfo.isNotEmpty) {
            ruleEntry += ' ($additionalInfo)';
          }
          formattedRules.add(ruleEntry);
        }
      }
    }
    return formattedRules.join('\n');
  }
}
