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
  bool _isLoadingMenus = true;
  String _errorMessage = '';

  String? _cateringId;
  String? _pengelolaId;
  // Removed _kostData from here as it's now used to get cateringId in CateringListScreen

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

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
    super.dispose();
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
                    // Group refresh and add buttons
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          onPressed: _fetchCateringMenus, // Call refresh logic
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ), // Spacer between refresh and add
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
                      const SizedBox(
                        width: 8,
                      ), // Spacer between settings and add
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () async {
                            // Added async
                            if (_cateringId != null) {
                              final result = await Get.toNamed(
                                // Await result
                                Routes.addCateringMenu,
                                arguments: {'cateringId': _cateringId},
                              );
                              if (result == true) {
                                // Check if result is true for refresh
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
                      const SizedBox(width: 10),
                      Text(
                        'Cari Menu...',
                        style: TextStyle(color: Colors.grey[400]),
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
                              _menuItems
                                  .where(
                                    (item) => item.kategori == 'MAKANAN_BERAT',
                                  )
                                  .toList(),
                          cateringId: _cateringId ?? '',
                          onRefresh: _fetchCateringMenus,
                          kategori: 'Makanan Berat',
                        ),
                        // Tab Snack
                        MenuGridView(
                          menuItems:
                              _menuItems
                                  .where((item) => item.kategori == 'SNACK')
                                  .toList(),
                          cateringId: _cateringId ?? '',
                          onRefresh: _fetchCateringMenus,
                          kategori: 'Snack',
                        ),
                        // Tab Minuman
                        MenuGridView(
                          menuItems:
                              _menuItems
                                  .where((item) => item.kategori == 'MINUMAN')
                                  .toList(),
                          cateringId: _cateringId ?? '',
                          onRefresh: _fetchCateringMenus,
                          kategori: 'Minuman',
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

  const MenuGridView({
    super.key,
    required this.menuItems,
    required this.cateringId,
    required this.onRefresh,
    required this.kategori,
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
              'Belum ada menu $kategori.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
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
      // Added RefreshIndicator
      onRefresh: () async {
        onRefresh(); // Trigger refresh from parent
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

  const FoodItemCard({
    super.key,
    required this.menuItem,
    required this.cateringId,
    required this.onRefresh,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          menuItem.namaMenu,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
