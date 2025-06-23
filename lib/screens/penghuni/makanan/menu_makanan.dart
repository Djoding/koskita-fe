import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/penghuni/makanan/keranjang.dart';
import 'package:kosan_euy/screens/penghuni/makanan/order_food_history.dart';
import 'package:kosan_euy/services/catering_menu_service.dart';
import 'package:kosan_euy/models/catering_model.dart';
import 'package:intl/intl.dart';

class MenuMakanan extends StatefulWidget {
  final String cateringId;
  final String reservasiId;

  const MenuMakanan({
    super.key,
    required this.cateringId,
    required this.reservasiId,
  });

  @override
  State<MenuMakanan> createState() => _MenuMakananScreenState();
}

class _MenuMakananScreenState extends State<MenuMakanan>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFoodTab = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<CateringMenuItem> _allMenus = [];
  Catering? _cateringInfo; // Ini akan berisi rekening_info dan qrisImage
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, Map<String, dynamic>> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadCateringMenus();
  }

  void _handleAddToCart(
    String menuId,
    String name,
    double price,
    String imagePath,
    String kategori,
  ) {
    int quantity = 1;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Kuantitas $name',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () {
                        if (quantity > 1) {
                          setModalState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      '$quantity',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        setModalState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D9DAB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  setState(() {
                    if (_selectedItems.containsKey(menuId)) {
                      _selectedItems.update(menuId, (value) {
                        value['jumlah'] = (value['jumlah'] as int) + quantity;
                        return value;
                      });
                    } else {
                      _selectedItems[menuId] = {
                        'menu_id': menuId,
                        'image': imagePath,
                        'nama': name,
                        'harga': price,
                        'jumlah': quantity,
                        'kategori': kategori,
                      };
                    }
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$quantity x $name berhasil ditambahkan!',
                        ),
                        backgroundColor: const Color(0xFF0B8FAC),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  });
                },
                child: Text(
                  'Tambahkan ke Keranjang',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _loadCateringMenus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await CateringMenuService.getCateringMenu(
        widget.cateringId,
      );
      if (result['status'] == true) {
        setState(() {
          _cateringInfo = result['catering_info'] as Catering;
          _allMenus = result['data'] as List<CateringMenuItem>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat menu catering.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading catering menus: $e");
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CateringMenuItem> _getFilteredMenus(bool isFoodTab) {
    final String category = isFoodTab ? 'MAKANAN_BERAT' : 'MINUMAN';
    List<CateringMenuItem> filteredByCategory =
        _allMenus
            .where((menu) => menu.kategori == category && menu.isAvailable)
            .toList();

    if (_searchQuery.isEmpty) {
      return filteredByCategory;
    } else {
      return filteredByCategory
          .where(
            (menu) => menu.namaMenu.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF89B3DE), Color(0xFF6B9EDD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_cateringInfo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    'Menu dari ${_cateringInfo!.namaCatering}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              _buildTitleAndSearchBar(),
              _buildFoodDrinkToggle(),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _isLoading
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
                                  onPressed: _loadCateringMenus, // Coba lagi
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                        : _getFilteredMenus(_showFoodTab).isEmpty
                        ? Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'Menu "$_searchQuery" tidak ditemukan.'
                                : 'Tidak ada menu ${_showFoodTab ? 'makanan' : 'minuman'} yang tersedia.',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.78,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                          itemCount: _getFilteredMenus(_showFoodTab).length,
                          itemBuilder: (context, index) {
                            final menu = _getFilteredMenus(_showFoodTab)[index];
                            return FoodItemCard(
                              name: menu.namaMenu,
                              price: menu.harga,
                              imagePath:
                                  menu.fotoMenu ??
                                  'assets/placeholder_food.png',
                              kategori: menu.kategori,
                              menuId: menu.menuId,
                              onAddToCart: _handleAddToCart,
                            );
                          },
                        ),
              ),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () {
                    Get.to(
                      () => OrderHistoryScreen(reservasiId: widget.reservasiId),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    final List<Map<String, dynamic>> itemsToSend =
                        _selectedItems.values.toList();

                    if (itemsToSend.isEmpty) {
                      Get.snackbar(
                        'Keranjang Kosong',
                        'Tambahkan item ke keranjang sebelum melanjutkan.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(
                          0xFF119DB1,
                        ).withAlpha((0.9 * 255).toInt()),
                        colorText: Colors.white,
                      );
                      return;
                    }

                    Get.to(
                      () => KeranjangScreen(
                        selectedItems: itemsToSend,
                        cateringId: widget.cateringId,
                        reservasiId: widget.reservasiId,
                        qrisImage: _cateringInfo?.qrisImage,
                        rekeningInfo: _cateringInfo?.rekeningInfo,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _showFoodTab
                ? 'Temukan Makanan Favoritmu!'
                : 'Segarkan dengan Minumanmu!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Update search query
                });
              },
              decoration: InputDecoration(
                hintText: _showFoodTab ? 'Cari makanan...' : 'Cari minuman...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4D9DAB)),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDrinkToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _buildToggleItem('Makanan', true)),
            Expanded(child: _buildToggleItem('Minuman', false)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String text, bool isFood) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () {
        setState(() {
          _showFoodTab = isFood;
          _searchController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color:
              _showFoodTab == isFood
                  ? const Color(0xFFE0BFFF)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: _showFoodTab == isFood ? Colors.black87 : Colors.white,
              fontWeight:
                  _showFoodTab == isFood ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4D9DAB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          onPressed: () {
            final List<Map<String, dynamic>> itemsToSend =
                _selectedItems.values.toList();

            if (itemsToSend.isEmpty) {
              Get.snackbar(
                'Keranjang Kosong',
                'Tambahkan item ke keranjang sebelum melanjutkan.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orangeAccent.withOpacity(0.9),
                colorText: Colors.white,
              );
              return;
            }

            Get.to(
              () => KeranjangScreen(
                selectedItems: itemsToSend,
                cateringId: widget.cateringId,
                reservasiId: widget.reservasiId,
                qrisImage: _cateringInfo?.qrisImage,
                rekeningInfo: _cateringInfo?.rekeningInfo,
              ),
            );
          },
          child: Text(
            'Lanjutkan ke Keranjang',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class FoodGridView extends StatelessWidget {
  final List<CateringMenuItem> menus;
  final Function(
    String menuId,
    String name,
    double price,
    String imagePath,
    String kategori,
  )
  onAddToCart;

  const FoodGridView({
    super.key,
    required this.menus,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return FoodItemCard(
          menuId: menu.menuId,
          name: menu.namaMenu,
          price: menu.harga, // Passing double price directly
          imagePath: menu.fotoMenu ?? 'assets/placeholder_food.png',
          kategori: menu.kategori,
          onAddToCart: onAddToCart,
        );
      },
    );
  }
}

class DrinkGridView extends StatelessWidget {
  final List<CateringMenuItem> menus;
  final Function(
    String menuId,
    String name,
    double price,
    String imagePath,
    String kategori,
  )
  onAddToCart;

  const DrinkGridView({
    super.key,
    required this.menus,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return FoodItemCard(
          menuId: menu.menuId,
          name: menu.namaMenu,
          price: menu.harga, // Passing double price directly
          imagePath: menu.fotoMenu ?? 'assets/placeholder_drink.png',
          kategori: menu.kategori,
          onAddToCart: onAddToCart,
        );
      },
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String name;
  final double price; // <--- UBAH TIPE DATA MENJADI double
  final String imagePath;
  final Function(
    String menuId,
    String name,
    double price,
    String imagePath,
    String kategori,
  )
  onAddToCart;
  final String menuId;
  final String kategori;

  const FoodItemCard({
    super.key,
    required this.name,
    required this.price, // <--- UBAH TIPE DATA MENJADI double
    required this.imagePath,
    required this.onAddToCart,
    required this.menuId,
    required this.kategori,
  });

  // === Pindahkan fungsi _formatPrice ke dalam FoodItemCard ===
  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', // Lokalisasi Indonesia
      symbol: 'Rp ', // Simbol mata uang
      decimalDigits: 0, // Tidak ada digit desimal
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    imagePath.startsWith('http')
                        ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                color: const Color(0xFF4D9DAB),
                              ),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              ),
                        )
                        : Image.asset(
                          // Fallback to asset if not a network URL
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              ),
                        ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // === GUNAKAN _formatPrice DI SINI ===
            Text(
              _formatPrice(price),
              style: GoogleFonts.poppins(
                color: const Color(0xFF4D9DAB),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B8FAC),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  onAddToCart(
                    menuId,
                    name,
                    price, // <--- KIRIM DOUBLE ASLI KE onAddToCart
                    imagePath,
                    kategori,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tambah',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
    );
  }
}

class DeleteSuccessScreen extends StatelessWidget {
  const DeleteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF89B3DE),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFFA51C1C),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.close, color: Colors.white, size: 120),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Menu Midog Berhasil Dihapus',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFA51C1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 240,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA51C1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
