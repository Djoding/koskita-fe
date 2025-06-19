import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/penghuni/laundry/laundry_penghuni.dart';
import 'package:kosan_euy/screens/penghuni/makanan/menu_makanan.dart';
import 'package:kosan_euy/screens/penghuni/reservasi/dashboard_reservasi.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/auth_service.dart';
import 'package:kosan_euy/services/reservation_service.dart';
import 'package:intl/intl.dart';

class DashboardTenantScreen extends StatefulWidget {
  const DashboardTenantScreen({super.key});

  @override
  State<DashboardTenantScreen> createState() => _DashboardTenantScreenState();
}

class _DashboardTenantScreenState extends State<DashboardTenantScreen> {
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();

  String _displayedUserName = 'Memuat...';
  String _kostName = 'Memuat...';
  String _kostAddress = 'Memuat...';
  String _checkInDate = 'N/A';
  String _checkOutDate = 'N/A';
  String _kostImageUrl = 'assets/placeholder_image.png';
  String? _statusPenghunian;
  String? _activeReservationId;

  bool _isLoadingProfile = true;
  bool _isLoadingReservationDetail = true;
  String? _errorMessage;

  String? _kostIdFromArgs;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['kostId'] != null) {
      _kostIdFromArgs = args['kostId'] as String;
    }

    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await _loadUserProfile();
    if (_kostIdFromArgs != null) {
      await _loadReservationDetail(_kostIdFromArgs!);
    } else {
      setState(() {
        _isLoadingReservationDetail = false;
        _errorMessage = 'ID Kos tidak diterima untuk memuat detail reservasi.';
      });
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      final userData = await _authService.getStoredUserData();
      if (userData != null) {
        setState(() {
          _displayedUserName = userData['full_name'] ?? 'Pengguna';
        });
      } else {
        _errorMessage = 'Gagal memuat profil pengguna.';
        _handleUnauthorizedAccess();
      }
    } catch (e) {
      debugPrint("Error loading user profile: $e");
      _errorMessage = 'Terjadi kesalahan memuat profil: ${e.toString()}';
      _handleUnauthorizedAccess();
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadReservationDetail(String kostId) async {
    setState(() {
      _isLoadingReservationDetail = true;
      _errorMessage = null;
    });
    try {
      final result = await _reservationService.getReservationsByKostAndUser(
        kostId,
      );
      if (result['status'] == true &&
          result['data'] != null &&
          result['data'].isNotEmpty) {
        final Map<String, dynamic> reservationData = Map<String, dynamic>.from(
          result['data'][0],
        );

        final Map<String, dynamic>? kostInfo = reservationData['kost'];

        if (kostInfo != null) {
          String imageUrl = 'assets/placeholder_image.png';
          if (kostInfo['foto_kost'] != null &&
              kostInfo['foto_kost'].isNotEmpty) {
            String rawUrl = kostInfo['foto_kost'][0].toString();
            if (rawUrl.startsWith('http://localhost:3000http')) {
              imageUrl = rawUrl.substring('http://localhost:3000'.length);
            } else {
              imageUrl = rawUrl;
            }
          }

          setState(() {
            _kostName = kostInfo['nama_kost'] ?? 'Nama Kost Tidak Tersedia';
            _kostAddress = kostInfo['alamat'] ?? 'Alamat Tidak Tersedia';
            _checkInDate = _formatDate(reservationData['tanggal_check_in']);
            _checkOutDate = _formatDate(reservationData['tanggal_keluar']);
            _kostImageUrl = imageUrl;
            _statusPenghunian = reservationData['status_penghunian'] as String?;
            _activeReservationId = reservationData['reservasi_id'] as String?;
          });
        } else {
          _errorMessage = 'Data kos untuk reservasi tidak ditemukan.';
          _kostName = 'Tidak ada Kost Aktif';
          _kostAddress = '';
          _checkInDate = 'N/A';
          _checkOutDate = 'N/A';
          _kostImageUrl = 'assets/placeholder_image.png';
          _statusPenghunian = null;
          _activeReservationId = null;
        }
      } else {
        _errorMessage =
            result['message'] ?? 'Tidak ada detail reservasi aktif ditemukan.';
        _kostName = 'Tidak ada Kost Aktif';
        _kostAddress = '';
        _checkInDate = 'N/A';
        _checkOutDate = 'N/A';
        _kostImageUrl = 'assets/placeholder_image.png';
        _statusPenghunian = null;
        _activeReservationId = null;
      }
    } catch (e) {
      debugPrint("Error loading reservation detail: $e");
      _errorMessage =
          'Terjadi kesalahan memuat detail reservasi: ${e.toString()}';
      if (e.toString().contains('Unauthorized')) {
        _handleUnauthorizedAccess();
      }
    } finally {
      setState(() {
        _isLoadingReservationDetail = false;
      });
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

  void _handleUnauthorizedAccess() {
    _authService.logout().then((_) {
      Get.offAll(() => const HomeScreenPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    bool overallLoading = _isLoadingProfile || _isLoadingReservationDetail;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF91B7DE), Color(0xFF6B9EDD)],
          ),
        ),
        child: SafeArea(
          child:
              overallLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : _errorMessage != null
                  ? Center(
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
                            onPressed: _loadDashboardData,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        _buildProfileSection(),
                        _buildSectionTitle('Riwayat Pemesanan Anda'),
                        _buildBookingHistoryCard(),
                        _buildSectionTitle('Layanan Manajemen'),
                        _buildServiceCards(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularIconButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Get.back(),
            backgroundColor: Colors.white.withAlpha((0.2 * 255).toInt()),
            iconColor: Colors.white,
          ),
          Row(
            children: [
              const SizedBox(width: 10),
              _buildCircularIconButton(
                icon: Icons.settings,
                onPressed: () => Get.to(() => const SettingScreen()),
                backgroundColor: Colors.white.withAlpha((0.2 * 255).toInt()),
                iconColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $_displayedUserName!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _kostName == 'Tidak ada Kost Aktif'
                ? 'Anda belum memiliki kost aktif.'
                : 'Penghuni $_kostName',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 20, 15),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildBookingHistoryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (_kostName != 'Tidak ada Kost Aktif') {
              Get.to(() => DashboardReservasiScreen());
            } else {
              Get.snackbar(
                'Informasi',
                'Anda belum memiliki reservasi kos aktif.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blueAccent,
                colorText: Colors.white,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).toInt()),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withAlpha((0.4 * 255).toInt()),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      _kostImageUrl.startsWith('assets/')
                          ? Image.asset(
                            _kostImageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildErrorImagePlaceholder(),
                          )
                          : Image.network(
                            _kostImageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
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
                                    _buildErrorImagePlaceholder(),
                          ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _kostName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _kostName == 'Tidak ada Kost Aktif'
                            ? 'Anda belum memiliki reservasi aktif.'
                            : '$_checkInDate - $_checkOutDate',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withAlpha((0.9 * 255).toInt()),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _kostAddress,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withAlpha((0.7 * 255).toInt()),
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
      ),
    );
  }

  Widget _buildErrorImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[500]),
    );
  }

  Widget _buildServiceCards() {
    final bool showTenantServices = _statusPenghunian != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _LayananCard(
            title: 'Layanan Reservasi Kamar',
            imageAsset: 'assets/icon_reservasi.png',
            onTap: () {
              Get.to(
                () => DashboardReservasiScreen(),
                arguments: {'reservasiId': _activeReservationId},
              );
            },
          ),
          if (showTenantServices) const SizedBox(height: 15),
          if (showTenantServices)
            _LayananCard(
              title: 'Layanan Pemesanan Makanan',
              imageAsset: 'assets/icon_makanan.png',
              onTap: () {
                Get.to(() => const MenuMakanan());
              },
            ),
          if (showTenantServices) const SizedBox(height: 15),
          if (showTenantServices)
            _LayananCard(
              title: 'Layanan Laundry',
              imageAsset: 'assets/icon_laundry.png',
              onTap: () {
                Get.to(() => const LaundryPenghuni());
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.black,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}

class _LayananCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;

  const _LayananCard({
    required this.title,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        splashColor: Colors.white.withAlpha((0.3 * 255).toInt()),
        highlightColor: Colors.white.withAlpha((0.1 * 255).toInt()),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).toInt()),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withAlpha((0.4 * 255).toInt()),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imageAsset,
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            size: 35,
                            color: Colors.grey[500],
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Lihat lebih detail >',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withAlpha((0.8 * 255).toInt()),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
