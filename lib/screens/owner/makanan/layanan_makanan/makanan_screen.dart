// lib/screens/owner/makanan/layanan_makanan/makanan_screen.dart
import 'package:flutter/material.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/add_screen.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/edit_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/catering_menu_service.dart';
import 'package:kosan_euy/models/catering_model.dart';
import 'package:kosan_euy/routes/app_pages.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Import untuk Timer

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<CateringMenuItem> _menuItems = [];
  List<CateringMenuItem> _filteredMenuItems = []; // List untuk hasil filter
  bool _isLoadingMenus = true;
  String _errorMessage = '';

  String? _cateringId;
  String? _pengelolaId;

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _filterMenuItems(); // Filter ulang ketika tab berubah
    });

    // Setup search listener dengan debounce
    _searchController.addListener(_onSearchChanged);

    // Get cateringId directly from arguments
    _cateringId = Get.arguments['cateringId'] as String?;
    if (_cateringId == null) {
      _errorMessage = 'Catering ID tidak ditemukan. Tidak dapat memuat menu.';
      _isLoadingMenus = false;
    } else {
      _fetchCateringMenus();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel timer sebelumnya jika ada
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Buat timer baru dengan delay 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
      _filterMenuItems();
    });
  }

  void _filterMenuItems() {
    setState(() {
      if (_searchQuery.isEmpty) {
        // Jika tidak ada query search, tampilkan semua menu sesuai kategori
        _filteredMenuItems = _getMenusByCategory(_currentTabIndex);
      } else {
        // Filter berdasarkan search query dan kategori
        final categoryMenus = _getMenusByCategory(_currentTabIndex);
        _filteredMenuItems =
            categoryMenus.where((item) {
              return item.namaMenu.toLowerCase().contains(_searchQuery);
            }).toList();
      }
    });
  }

  List<CateringMenuItem> _getMenusByCategory(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _menuItems
            .where((item) => item.kategori == 'MAKANAN_BERAT')
            .toList();
      case 1:
        return _menuItems.where((item) => item.kategori == 'SNACK').toList();
      case 2:
        return _menuItems.where((item) => item.kategori == 'MINUMAN').toList();
      default:
        return [];
    }
  }

  Future<void> _fetchCateringMenus() async {
    if (_cateringId == null) {
      setState(() {
        _errorMessage = 'Catering ID is not available.';
        _isLoadingMenus = false;
      });
      return;
    }

    setState(() {
      _isLoadingMenus = true;
      _errorMessage = '';
    });

    try {
      print('Fetching menus for catering: $_cateringId');

      final response = await CateringMenuService.getCateringMenu(_cateringId!);

      print('Menu response: $response');

      if (response['status']) {
        setState(() {
          _menuItems = response['data'];
          _isLoadingMenus = false;
        });
        // Filter menu items setelah data dimuat
        _filterMenuItems();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load menu items.';
          _isLoadingMenus = false;
        });
      }
    } catch (e) {
      print('Error fetching catering menus: $e');
      setState(() {
        _errorMessage = 'Network error fetching menus: $e';
        _isLoadingMenus = false;
      });
    }
  }

  String get _currentTabTitle {
    switch (_currentTabIndex) {
      case 0:
        return 'Daftar Menu Makanan Berat';
      case 1:
        return 'Daftar Menu Snack';
      case 2:
        return 'Daftar Menu Minuman';
      default:
        return 'Daftar Menu';
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _filterMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          onPressed: _fetchCateringMenus,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            size: 20,
                          ),
                          onPressed: () => Get.to(() => SettingScreen()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () async {
                            if (_cateringId != null) {
                              final result = await Get.toNamed(
                                Routes.addCateringMenu,
                                arguments: {'cateringId': _cateringId},
                              );
                              if (result == true) {
                                _fetchCateringMenus();
                              }
                            } else {
                              Get.snackbar(
                                'Error',
                                'Catering service not found for this kost. Cannot add menu.',
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _currentTabTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Search Bar - Updated dengan functionality
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari Menu...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Clear button - tampil jika ada text
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tab Bar dengan 3 tab
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFE0BFFF),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: const [
                    Tab(text: 'Makanan'),
                    Tab(text: 'Snack'),
                    Tab(text: 'Minuman'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _isLoadingMenus
                  ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _errorMessage.isNotEmpty
                  ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchCateringMenus,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab Makanan Berat
                        MenuGridView(
                          menuItems:
                              _searchQuery.isEmpty
                                  ? _menuItems
                                      .where(
                                        (item) =>
                                            item.kategori == 'MAKANAN_BERAT',
                                      )
                                      .toList()
                                  : _filteredMenuItems,
                          cateringId: _cateringId ?? '',
                          onRefresh: _fetchCateringMenus,
                          kategori: 'Makanan Berat',
                          searchQuery: _searchQuery,
                        ),
                        // Tab Snack
                        MenuGridView(
                          menuItems:
                              _searchQuery.isEmpty
                                  ? _menuItems
                                      .where((item) => item.kategori == 'SNACK')
                                      .toList()
                                  : _filteredMenuItems,
                          cateringId: _cateringId ?? '',
                          onRefresh: _fetchCateringMenus,
                          kategori: 'Snack',
                          searchQuery: _searchQuery,
                        ),
                        // Tab Minuman
                        MenuGridView(
                          menuItems:
                              _searchQuery.isEmpty
                                  ? _menuItems
                                      .where(
                                        (item) => item.kategori == 'MINUMAN',
                                      )
                                      .toList()
                                  : _filteredMenuItems,
                          cateringId: _cateringId ?? '',
                          onRefresh: _fetchCateringMenus,
                          kategori: 'Minuman',
                          searchQuery: _searchQuery,
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
}

class MenuGridView extends StatelessWidget {
  final List<CateringMenuItem> menuItems;
  final String cateringId;
  final VoidCallback onRefresh;
  final String kategori;
  final String searchQuery; // Tambahan parameter untuk search query

  const MenuGridView({
    super.key,
    required this.menuItems,
    required this.cateringId,
    required this.onRefresh,
    required this.kategori,
    this.searchQuery = '', // Default empty string
  });

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'Tidak ada menu $kategori yang cocok dengan "${searchQuery}"'
                  : 'Belum ada menu $kategori.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (searchQuery.isEmpty)
              Text(
                'Tambahkan menu $kategori pertama Anda!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return FoodItemCard(
            menuItem: item,
            cateringId: cateringId,
            onRefresh: onRefresh,
            searchQuery: searchQuery, // Pass search query untuk highlighting
          );
        },
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final CateringMenuItem menuItem;
  final String cateringId;
  final VoidCallback onRefresh;
  final String searchQuery; // Tambahan parameter

  const FoodItemCard({
    super.key,
    required this.menuItem,
    required this.cateringId,
    required this.onRefresh,
    this.searchQuery = '',
  });

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus menu "${menuItem.namaMenu}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  try {
                    final response =
                        await CateringMenuService.deleteCateringMenuItem(
                          cateringId: cateringId,
                          menuId: menuItem.menuId,
                        );
                    if (response['status']) {
                      Get.snackbar(
                        'Sukses',
                        response['message'] ?? 'Menu berhasil dihapus!',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                      onRefresh();
                    } else {
                      Get.snackbar(
                        'Error',
                        response['message'] ?? 'Gagal menghapus menu.',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Terjadi kesalahan: $e',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Color _getCategoryColor() {
    switch (menuItem.kategori) {
      case 'MAKANAN_BERAT':
        return Colors.orange;
      case 'SNACK':
        return Colors.purple;
      case 'MINUMAN':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Widget untuk highlight text yang cocok dengan search
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final startIndex = lowerText.indexOf(lowerQuery);
    final endIndex = startIndex + query.length;

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, startIndex),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black26,
            ),
          ),
          TextSpan(
            text: text.substring(endIndex),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menggunakan highlighted text untuk nama menu
        _buildHighlightedText(menuItem.namaMenu, searchQuery),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              _formatCurrency(menuItem.harga),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoryColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                menuItem.kategori == 'MAKANAN_BERAT'
                    ? 'MB'
                    : menuItem.kategori == 'SNACK'
                    ? 'S'
                    : 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image:
                        menuItem.fotoMenuUrl != null &&
                                menuItem.fotoMenuUrl!.isNotEmpty
                            ? NetworkImage(menuItem.fotoMenuUrl!)
                            : const AssetImage('assets/icon_makanan.png')
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child:
                    !menuItem.isAvailable
                        ? Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.not_interested,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tidak Tersedia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        : null,
              ),

              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final result = await Get.toNamed(
                        Routes.editCateringMenu,
                        arguments: {
                          'cateringId': cateringId,
                          'menuItem': menuItem,
                        },
                      );
                      if (result == true) {
                        onRefresh();
                      }
                    },
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _showDeleteConfirmation(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, color: Colors.white, size: 12),
                        SizedBox(width: 2),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
