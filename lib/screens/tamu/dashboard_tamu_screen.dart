import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/tamu/detail_kos_tamu.dart';
import 'package:kosan_euy/services/kost_service.dart';
import 'dart:ui';

class DashboardTamuScreen extends StatefulWidget {
  const DashboardTamuScreen({super.key});

  @override
  State<DashboardTamuScreen> createState() => _DashboardTamuScreenState();
}

class _DashboardTamuScreenState extends State<DashboardTamuScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final KostService _kostService = KostService();

  List<Map<String, dynamic>> _allKostData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initTabController();
    _fetchAllKost();
  }

  void _initTabController() {
    _tabController = TabController(length: 1, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
  }

  Future<void> _fetchAllKost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _kostService.getAllKost();
      if (result['status'] == true && result['data'] != null) {
        _allKostData =
            (result['data'] as List<dynamic>).map((item) {
              final Map<String, dynamic> typedItem = Map<String, dynamic>.from(
                item,
              );

              String imageUrl = 'assets/placeholder_image.png';
              if (typedItem['foto_kost'] != null &&
                  typedItem['foto_kost'].isNotEmpty) {
                String rawUrl = typedItem['foto_kost'][0].toString();
                if (rawUrl.startsWith('http://localhost:3000http')) {
                  imageUrl = rawUrl.substring('http://localhost:3000'.length);
                } else {
                  imageUrl = rawUrl;
                }
              }
              return {
                'id': typedItem['kost_id'],
                'image': imageUrl,
                'nama': typedItem['nama_kost'],
                'alamat': typedItem['alamat'],
                ...typedItem,
              };
            }).toList();
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengambil daftar kos.';
      }
    } catch (e) {
      debugPrint("Error fetching all kost: $e");
      _errorMessage =
          'Terjadi kesalahan saat memuat daftar kos: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      final namaKost = (kost['nama'] as String?)?.toLowerCase() ?? '';
      final alamat = (kost['alamat'] as String?)?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return namaKost.contains(query) || alamat.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null || _isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE0F2F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Widget> tabBarViews = [_buildKostList(_allKostData, 'Daftar Kos')];

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
                  _buildCircularIconButton(
                    icon: Icons.login,
                    onPressed: () {
                      Get.to(() => const HomeScreenPage());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                'Halo, Tamu!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Temukan kos impianmu dengan mudah.',
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
    tabs = [
      Tab(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Daftar Kos (${_allKostData.length})'),
        ),
      ),
    ];

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
    List<Map<String, dynamic>> data,
    String emptyMessagePrefix,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _buildEmptyState('$_errorMessage\nCoba lagi.');
    }

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
                        onTap: () => _goToDetail(filteredData[index]),
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
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: _fetchAllKost,
                  child: const Text('Refresh Data'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _goToDetail(Map<String, dynamic> kosData) {
    final String? kosId = kosData['id'] as String?;

    if (kosId == null) {
      Get.snackbar(
        'Error',
        'ID Kos tidak tersedia untuk detail.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    Get.to(() => DetailKosTamu(), arguments: {'id': kosId});
  }
}

class _KostCard extends StatelessWidget {
  final Map<String, dynamic> kost;
  final VoidCallback onTap;

  const _KostCard({required this.kost, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = kost['image'] ?? 'assets/placeholder_image.png';
    final bool isAsset = imageUrl.startsWith('assets/');

    final String displayedNama =
        (kost['nama'] as String?) ?? 'Nama kos tidak tersedia';
    final String displayedAlamat =
        (kost['alamat'] as String?) ?? 'Alamat tidak tersedia';

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
                  tag: 'kost-image-${kost['id']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        isAsset
                            ? Image.asset(
                              imageUrl,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildErrorImage(),
                            )
                            : Image.network(
                              imageUrl,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
                                      _buildErrorImage(),
                            ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayedNama,
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
                        displayedAlamat,
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

  Widget _buildErrorImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.broken_image, size: 45, color: Colors.grey[400]),
    );
  }
}
