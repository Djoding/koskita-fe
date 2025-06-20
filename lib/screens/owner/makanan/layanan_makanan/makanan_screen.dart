// lib/screens/owner/makanan/layanan_makanan/makanan_screen.dart
import 'package:flutter/material.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/add_screen.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/edit_screen.dart';
import 'package:kosan_euy/services/catering_menu_service.dart'; // Import service
import 'package:kosan_euy/models/catering_model.dart'; // Import models
import 'package:kosan_euy/routes/app_pages.dart'; // For navigation
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To get user ID

class FoodListScreen extends StatefulWidget {
  // Pass kostData for context, if needed. Assuming it's passed via Get.arguments
  final Map<String, dynamic>? kostData;

  const FoodListScreen({super.key, this.kostData});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFoodTab = true; // True for Makanan, False for Minuman
  List<CateringMenuItem> _menuItems = [];
  bool _isLoadingMenus = true;
  String _errorMessage = '';

  String? _cateringId; // The ID of the catering service
  String? _pengelolaId; // Current logged in pengelola ID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCateringData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getPengelolaId() async {
    final prefs =
        await Get.find<SharedPreferences>(); // Get SharedPreferences instance
    final token = prefs.getString('accessToken');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _pengelolaId =
          decodedToken["userId"]; // Assuming "userId" is the key in JWT for user ID
    }
  }

  Future<void> _initializeCateringData() async {
    await _getPengelolaId(); // Get pengelola ID first

    if (widget.kostData == null) {
      setState(() {
        _errorMessage = 'Kost data is missing. Cannot fetch catering menus.';
        _isLoadingMenus = false;
      });
      return;
    }

    // First, get the catering service associated with this kost
    try {
      final response = await CateringMenuService.getCateringsByKost(
        widget.kostData!['kost_id'],
      );
      if (response['status'] && (response['data'] as List).isNotEmpty) {
        final List<Catering> caterings = response['data'];
        _cateringId =
            caterings
                .first
                .cateringId; // Assuming one catering per kost for simplicity

        await _fetchCateringMenus(); // Then fetch menus for this catering
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'No catering service found for this kost.';
          _isLoadingMenus = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching catering service: $e';
        _isLoadingMenus = false;
      });
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
      final response = await CateringMenuService.getCateringMenu(_cateringId!);
      if (response['status']) {
        setState(() {
          _menuItems = response['data'];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load menu items.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error fetching menus: $e';
      });
    } finally {
      setState(() {
        _isLoadingMenus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        // Pass cateringId to AddFoodScreen
                        if (_cateringId != null) {
                          Get.toNamed(
                            Routes.addCateringMenu,
                            arguments: {'cateringId': _cateringId},
                          );
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
              const SizedBox(height: 20),
              Text(
                _showFoodTab ? 'Daftar Menu Makanan' : 'Daftar Menu Minuman',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showFoodTab = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _showFoodTab
                                ? const Color(0xFFE0BFFF)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Makanan',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight:
                              _showFoodTab
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showFoodTab = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            !_showFoodTab
                                ? const Color(0xFFE0BFFF)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Minuman',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight:
                              !_showFoodTab
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoadingMenus
                  ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _errorMessage.isNotEmpty
                  ? Expanded(
                    child: Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  : Expanded(
                    child:
                        _showFoodTab
                            ? MenuGridView(
                              menuItems:
                                  _menuItems
                                      .where(
                                        (item) =>
                                            item.kategori == 'MAKANAN_BERAT' ||
                                            item.kategori == 'SNACK',
                                      ) // Filter based on category
                                      .toList(),
                              cateringId: _cateringId!,
                              onRefresh: _fetchCateringMenus,
                            )
                            : MenuGridView(
                              menuItems:
                                  _menuItems
                                      .where(
                                        (item) => item.kategori == 'MINUMAN',
                                      ) // Filter based on category
                                      .toList(),
                              cateringId: _cateringId!,
                              onRefresh: _fetchCateringMenus,
                            ),
                  ),
              // The "Edit" button below should be per item, not global here.
              // We will adjust FoodItemCard to have edit functionality directly.
              // For now, removing this global Edit button if it was meant for item editing.
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 16.0),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 50,
              //     child: ElevatedButton(
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: const Color(0xFF4D9DAB),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(25),
              //         ),
              //       ),
              //       onPressed: () {
              //         Get.to(() => const EditFoodScreen());
              //       },
              //       child: const Text(
              //         'Edit',
              //         style: TextStyle(color: Colors.white, fontSize: 16),
              //       ),
              //     ),
              //   ),
              // ),
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
  final VoidCallback onRefresh; // Callback to refresh menus

  const MenuGridView({
    super.key,
    required this.menuItems,
    required this.cateringId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada menu ditemukan.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return GridView.builder(
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
    );
  }
}

// Rename to MenuCard or similar to avoid confusion with FoodItemCard
// class FoodItemCard extends StatelessWidget { // This will be the new FoodItemCard
//   final String name;
//   final String price;
//   final String imagePath;
//   // ... (constructor)
// }

// Create a new FoodItemCard that takes CateringMenuItem
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
                  Get.back(); // Close dialog
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
                      );
                      onRefresh(); // Refresh the list after deletion
                    } else {
                      Get.snackbar(
                        'Error',
                        response['message'] ?? 'Gagal menghapus menu.',
                      );
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'Terjadi kesalahan: $e');
                  }
                },
                child: const Text('Hapus'),
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
        Text(
          menuItem.namaMenu,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          _formatCurrency(menuItem.harga),
          style: const TextStyle(color: Colors.white, fontSize: 12),
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
                        menuItem.fotoMenuUrl != null
                            ? NetworkImage(menuItem.fotoMenuUrl!)
                                as ImageProvider // Use NetworkImage for URL
                            : const AssetImage(
                              'assets/food_placeholder.png',
                            ), // Placeholder asset
                    fit: BoxFit.cover,
                  ),
                ),
                child:
                    menuItem
                            .isAvailable // Overlay if not available
                        ? null
                        : Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Tidak Tersedia',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: InkWell(
                    onTap:
                        () => _showDeleteConfirmation(
                          context,
                        ), // Use new delete function
                    child: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Hapus',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Edit button overlay
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(
                        Routes.editCateringMenu,
                        arguments: {
                          'cateringId': cateringId,
                          'menuItem': menuItem, // Pass the whole menu item
                        },
                      );
                    },
                    child: Icon(Icons.edit, color: Colors.white, size: 14),
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
