import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for better typography
import 'package:kosan_euy/screens/penghuni/makanan/keranjang.dart';
import 'package:kosan_euy/screens/penghuni/makanan/order_food_history.dart';

class MenuMakanan extends StatefulWidget {
  const MenuMakanan({super.key});

  @override
  State<MenuMakanan> createState() => _MenuMakananScreenState();
}

class _MenuMakananScreenState extends State<MenuMakanan>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFoodTab = true;
  final TextEditingController _searchController =
      TextEditingController(); // Added search controller for UI
  String _searchQuery = ''; // Added search query state for UI

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text; // Update search query for UI changes
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Elegant gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF89B3DE), // Lighter blue
              Color(0xFF6B9EDD), // Deeper blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to start
            children: [
              _buildHeader(),
              _buildTitleAndSearchBar(),
              _buildFoodDrinkToggle(),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _showFoodTab ? const FoodGridView() : const DrinkGridView(),
              ),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Building Methods ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Adjusted padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Semi-transparent white
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
                color: Colors.white, // White icon
              ),
              onPressed: () => Navigator.pop(context), // Original functionality
            ),
          ),
          Row(
            // Wrap cart and history buttons in a Row
            children: [
              // Order History Button
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
                    Icons.history, // History icon
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Get.to(
                      () => const OrderHistoryScreen(),
                    ); // Navigate to OrderHistoryScreen
                  },
                ),
              ),
              const SizedBox(width: 10), // Spacing between buttons
              // Cart Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.2,
                  ), // Semi-transparent white
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
                    Icons.shopping_cart_outlined, // Cart icon
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Get.to(
                      () => const KeranjangScreen(),
                    ); // Original functionality
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ), // Adjusted padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _showFoodTab
                ? 'Temukan Makanan Favoritmu!'
                : 'Segarkan dengan Minumanmu!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26, // Larger title
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
              borderRadius: BorderRadius.circular(
                30,
              ), // More rounded search bar
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController, // Link controller
              onChanged: (value) {
                // This will trigger setState via the listener in initState, updating _searchQuery
                // No functional filtering implemented as per instructions
              },
              decoration: InputDecoration(
                hintText: _showFoodTab ? 'Cari makanan...' : 'Cari minuman...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF4D9DAB),
                ), // Icon color
                suffixIcon:
                    _searchQuery
                            .isNotEmpty // Show clear icon if text is not empty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: InputBorder.none, // Remove default border
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
          color: Colors.white.withOpacity(
            0.2,
          ), // Semi-transparent background for toggle
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
          _searchController
              .clear(); // Clear search when changing tab for cleaner UI
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ), // Adjusted padding
      child: SizedBox(
        width: double.infinity,
        height: 55, // Slightly taller button
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4D9DAB), // Primary accent color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // More rounded corners
            ),
            elevation: 8, // Add elevation for depth
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          onPressed: () {
            Get.to(() => const KeranjangScreen()); // Original functionality
          },
          child: Text(
            'Lanjutkan ke Keranjang', // More descriptive text
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18, // Larger font
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class FoodGridView extends StatelessWidget {
  const FoodGridView({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: 'price' is kept as String here, as per your original code.
    // For functional price calculations, it's better to use double/int.
    final List<Map<String, dynamic>> foodItems = [
      {
        'name': 'Indomie kuah/goreng Spesial',
        'price': 'RP 8.000',
        'image': 'assets/food6.png',
      },
      {
        'name': 'Nasi Goreng Telur',
        'price': 'RP 12.000',
        'image': 'assets/food5.png',
      },
      {'name': 'Telur Dadar', 'price': 'RP 6.000', 'image': 'assets/food4.png'},
      {
        'name': 'Telur Ceplok',
        'price': 'RP 7.000',
        'image': 'assets/food3.png',
      },
      {'name': 'Nasi Putih', 'price': 'RP 5.000', 'image': 'assets/food2.png'},
      {'name': 'Midog', 'price': 'RP 5.000', 'image': 'assets/food1.png'},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78, // Adjusted aspect ratio for better card fit
        crossAxisSpacing: 15, // Increased spacing
        mainAxisSpacing: 15, // Increased spacing
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        // Pass individual properties as per original FoodItemCard constructor
        return FoodItemCard(
          name: foodItems[index]['name'],
          price: foodItems[index]['price'],
          imagePath: foodItems[index]['image'],
        );
      },
    );
  }
}

class DrinkGridView extends StatelessWidget {
  const DrinkGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> drinkItems = [
      {
        'name': 'Es Teh/hangat',
        'price': 'RP 4.000',
        'image': 'assets/drink1.png',
      },
      {
        'name': 'Es Nutrisari',
        'price': 'RP 5.000',
        'image': 'assets/drink2.png',
      },
      {
        'name': 'Es Kopi Good Day',
        'price': 'RP 5.000',
        'image': 'assets/drink3.png',
      },
      {'name': 'Es Milo', 'price': 'RP 7.000', 'image': 'assets/drink4.png'},
      {'name': 'Es Sirsir', 'price': 'RP 5.000', 'image': 'assets/drink5.png'},
      {'name': 'Es Dancow', 'price': 'RP 7.000', 'image': 'assets/drink6.png'},
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78, // Adjusted aspect ratio for better card fit
        crossAxisSpacing: 15, // Increased spacing
        mainAxisSpacing: 15, // Increased spacing
      ),
      itemCount: drinkItems.length,
      itemBuilder: (context, index) {
        // Pass individual properties as per original FoodItemCard constructor
        return FoodItemCard(
          name: drinkItems[index]['name'],
          price: drinkItems[index]['price'],
          imagePath: drinkItems[index]['image'],
        );
      },
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;

  const FoodItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Added elevation for depth
      shadowColor: Colors.black.withOpacity(0.2), // Subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // More rounded card corners
      ),
      color: Colors.white, // White card background
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  12,
                ), // Rounded image corners
                child: Image.asset(
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
                // Use Google Fonts
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2, // Allow two lines for name
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              price, // Price as String
              style: GoogleFonts.poppins(
                // Use Google Fonts
                color: const Color(0xFF4D9DAB), // Accent color for price
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // 'Tambah' button for adding to cart
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B8FAC),
                borderRadius: BorderRadius.circular(20), // Rounded button
                boxShadow: [
                  // Subtle shadow for button
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$name berhasil ditambahkan!',
                      ), // Dynamic message
                      backgroundColor: const Color(0xFF0B8FAC),
                      duration: const Duration(milliseconds: 1000),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Keep row tight to content
                    children: [
                      const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 16,
                      ), // Shopping cart icon
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
                'Menu Midog Berhasil Dihapus', // Using GoogleFonts for consistency
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
                    'Kembali', // Using GoogleFonts for consistency
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
