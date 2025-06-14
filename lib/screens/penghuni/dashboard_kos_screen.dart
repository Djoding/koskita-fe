import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/penghuni/dashboard_tenant_screen.dart';
import 'package:kosan_euy/screens/penghuni/reservasi/detail_kos.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/auth_service.dart';
import 'dart:ui';

class KosScreen extends StatefulWidget {
  const KosScreen({super.key});

  @override
  State<KosScreen> createState() => _KosScreenState();
}

class _KosScreenState extends State<KosScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final AuthService _authService = AuthService();
  String _displayedUserName = 'Memuat...';
  bool _isLoggedIn = false;

  final List<Map<String, String>> kostList = [
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Melati',
      'alamat': 'Jalan Melati No. 10, Bandung',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Mawar',
      'alamat': 'Jalan Mawar No. 15, Jakarta',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Anggrek',
      'alamat': 'Jalan Anggrek No. 20, Surabaya',
    },
  ];

  final List<Map<String, String>> activeKostList = [
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Dahlia',
      'alamat': 'Jalan Dahlia No. 5, Yogyakarta',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Sakura',
      'alamat': 'Jalan Sakura No. 8, Semarang',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Teratai',
      'alamat': 'Jalan Teratai No. 12, Medan',
    },
  ];

  final List<Map<String, String>> historyReservedKostList = [
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Kenanga',
      'alamat': 'Jalan Kenanga No. 3, Malang',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Bougenville',
      'alamat': 'Jalan Bougenville No. 7, Bali',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Cempaka',
      'alamat': 'Jalan Cempaka No. 9, Makassar',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndLoadProfile().then((_) {
      _initTabController();
    });
  }

  void _initTabController() {
    _tabController?.dispose();
    _tabController = TabController(length: _isLoggedIn ? 3 : 1, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
    setState(() {});
  }

  Future<void> _checkLoginStatusAndLoadProfile() async {
    bool loggedIn = await _authService.isLoggedIn();
    String userName = 'Tamu';
    if (loggedIn) {
      final userData = await _authService.getStoredUserData();
      if (userData != null && userData['full_name'] != null) {
        userName = userData['full_name'];
      }
    }
    setState(() {
      _isLoggedIn = loggedIn;
      _displayedUserName = userName;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterKost(List<Map<String, dynamic>> data) {
    if (_searchQuery.isEmpty) return data;
    return data.where((kost) {
      final namaKost = (kost['nama'] as String).toLowerCase();
      final alamat = (kost['alamat'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return namaKost.contains(query) || alamat.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE0F2F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Widget> tabBarViews;
    if (_isLoggedIn) {
      tabBarViews = [
        _buildKostList(kostList, 'Daftar Kos'),
        _buildKostList(activeKostList, 'Kos yang Sedang Aktif'),
        _buildKostList(historyReservedKostList, 'Riwayat Pemesanan Kos'),
      ];
    } else {
      tabBarViews = [_buildKostList(kostList, 'Daftar Kos')];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(tabBarViews.length),
            Expanded(
              child: TabBarView(
                controller: _tabController!,
                children: tabBarViews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF91B7DE),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _isLoggedIn
                      ? _buildCircularIconButton(
                        icon: Icons.settings,
                        onPressed: () => Get.to(() => const SettingScreen()),
                      )
                      : _buildCircularIconButton(
                        icon: Icons.login,
                        onPressed: () {
                          Get.to(() => const HomeScreenPage());
                        },
                      ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                'Halo, $_displayedUserName!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Temukan dan reservasi kos dengan mudah.',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTabBar(int tabCount) {
    List<Widget> tabs;
    if (tabCount == 1) {
      tabs = [
        Tab(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('Daftar Kos (${kostList.length})'),
          ),
        ),
      ];
    } else {
      tabs = [
        Tab(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('Daftar Kos (${kostList.length})'),
          ),
        ),
        Tab(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('Kos Aktif (${activeKostList.length})'),
          ),
        ),
        Tab(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('Riwayat (${historyReservedKostList.length})'),
          ),
        ),
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController!,
        isScrollable: false,
        indicatorColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(
          horizontal: 5.0,
          vertical: 5.0,
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xFF119DB1),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelPadding: EdgeInsets.zero,
        tabs: tabs,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari kos atau lokasi...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF119DB1)),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildKostList(
    List<Map<String, String>> data,
    String emptyMessagePrefix,
  ) {
    final filteredData = _filterKost(data);
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child:
              filteredData.isEmpty
                  ? _buildEmptyState(
                    'Tidak ada $emptyMessagePrefix yang ditemukan.',
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      return _KostCard(
                        kost: filteredData[index],
                        onTap: () => _goToDetail(),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Coba cari dengan kata kunci lain atau periksa tab lainnya.',
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

void _goToDetail() {
    if (_isLoggedIn) {
      Get.to(() => DashboardTenantScreen());
    } else {
      Get.to(() => DetailKos());
    }
  }
}

class _KostCard extends StatelessWidget {
  final Map<String, dynamic> kost;
  final VoidCallback onTap;

  const _KostCard({required this.kost, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFF119DB1).withOpacity(0.1),
          highlightColor: const Color(0xFF119DB1).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'kost-image-${kost['nama']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      kost['image'] ?? 'assets/placeholder_image.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.broken_image,
                              size: 45,
                              color: Colors.grey[400],
                            ),
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
                        kost['nama'] ?? 'Nama kos tidak tersedia',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.blueGrey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kost['alamat'] ?? 'Alamat tidak tersedia',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 18,
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
}
