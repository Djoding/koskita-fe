// lib/screens/owner/dashboard_owner_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kosan_euy/screens/owner/kost_detail_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/pengelola_service.dart';
import 'package:kosan_euy/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/routes/app_pages.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({super.key});

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> daftarKost = [];
  String? userId;
  String _displayedUserName = 'Memuat...';
  bool _isLoggedIn = false;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndLoadProfile();
    _fetchKostData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatusAndLoadProfile() async {
    bool loggedIn = false;
    String userName = 'Pengelola';

    try {
      final userData = await _authService.getStoredUserData();
      if (userData != null && userData['full_name'] != null) {
        loggedIn = true;
        userName = userData['full_name'];
      }
    } catch (e) {
      loggedIn = false;
      userName = 'Pengelola';
    }

    setState(() {
      _isLoggedIn = loggedIn;
      _displayedUserName = userName;
    });
  }

  Future<void> _fetchKostData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await PengelolaService.getKostByOwner(
        namaKost:
            _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
      );

      if (response['status']) {
        setState(() {
          daftarKost = List<Map<String, dynamic>>.from(response['data'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load kost data';
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

  Future<void> _onLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Fungsi untuk membersihkan URL yang terduplikasi
  String _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Debug print untuk melihat URL asli
    print('Original URL: $url');

    // Jika URL sudah berupa URL lengkap (dimulai dengan http/https), gunakan langsung
    if (url.startsWith('https://') || url.startsWith('http://')) {
      // Cek apakah ada duplikasi localhost
      if (url.contains('localhost:3000') &&
          url.indexOf('localhost:3000') != url.lastIndexOf('localhost:3000')) {
        // Ambil bagian setelah localhost:3000 terakhir
        final parts = url.split('localhost:3000');
        if (parts.length > 1) {
          final cleanUrl = parts.last;
          print('Cleaned URL: $cleanUrl');
          return cleanUrl.startsWith('http') ? cleanUrl : 'https:$cleanUrl';
        }
      }
      return url;
    }

    // Jika URL relatif, tidak perlu ditambah base URL
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF86B0DD),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _checkLoginStatusAndLoadProfile();
            await _fetchKostData();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display user name
                          Text(
                            'Halo, $_displayedUserName',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () async {
                            await _checkLoginStatusAndLoadProfile();
                            await _fetchKostData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Get.to(() => SettingScreen()),
                        ),
                      ],
                    ),
                  ],
                ),

                // Search bar
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari kost Anda',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onSubmitted: (value) => _fetchKostData(),
                  ),
                ),

                // Kost listings
                const SizedBox(height: 24),
                Expanded(child: _buildKostList()),

                // Register button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(Routes.daftarKos);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '+ Daftarkan Kost Baru',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKostList() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Memuat data kost...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchKostData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF86B0DD),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (daftarKost.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_outlined, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'Belum ada kost yang terdaftar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Daftarkan kost pertama Anda untuk mulai mengelola',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: daftarKost.length,
      itemBuilder: (BuildContext context, int index) {
        final kost = daftarKost[index];
        return _buildKostCard(kost);
      },
    );
  }

  Widget _buildKostCard(Map<String, dynamic> kost) {
    return InkWell(
      onTap: () {
        Get.to(() => KostDetailScreen(kostId: kost['kost_id']));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9EBFED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Kost image
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: _buildKostImage(kost['foto_kost']),
              ),
              const SizedBox(width: 16),
              // Kost details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      kost["nama_kost"] ?? 'Nama Kost',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kost["alamat"] ?? 'Alamat tidak tersedia',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Total: ${kost["total_kamar"] ?? 0}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tersedia: ${kost['available_rooms'] ?? 0}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (kost["harga_bulanan"] != null)
                      Text(
                        'Rp ${_formatCurrency(kost["harga_bulanan"])}/bulan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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

  Widget _buildKostImage(dynamic fotoKost) {
    String? imageUrl;

    if (fotoKost != null && (fotoKost as List).isNotEmpty) {
      final firstImage = (fotoKost as List).first;
      imageUrl = _cleanImageUrl(firstImage?.toString());
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
        child: Icon(Icons.home, size: 50, color: Colors.grey[600]),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          print('Failed URL: $imageUrl');
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: Icon(Icons.home, size: 50, color: Colors.grey[600]),
          );
        },
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
