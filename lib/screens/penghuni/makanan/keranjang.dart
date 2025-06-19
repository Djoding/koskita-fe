import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_penghuni.dart';

class KeranjangScreen extends StatefulWidget {
  // Added optional selectedItems to simulate receiving data from MenuMakanan
  final List<Map<String, dynamic>>? selectedItems;

  const KeranjangScreen({super.key, this.selectedItems});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  // Use a mutable list for pesanan (cart items)
  List<Map<String, dynamic>> pesanan = [];

  @override
  void initState() {
    super.initState();
    // Initialize pesanan with selectedItems if provided, otherwise use mock data
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      pesanan = List.from(widget.selectedItems!);
    } else {
      // Default mock data if no items are passed (for direct access/testing)
      pesanan = [
        {
          'image': 'assets/food6.png',
          'nama': 'Indomie Kuah Special',
          'harga': 8000,
          'jumlah': 1,
        },
        {
          'image': 'assets/drink5.png',
          'nama': 'Es Teh',
          'harga': 4000,
          'jumlah': 1,
        },
        {
          'image': 'assets/food1.png',
          'nama': 'Midog',
          'harga': 5000,
          'jumlah': 2,
        },
      ];
    }
  }

  // Calculate total price
  int get totalHarga => pesanan.fold(
    0,
    (int sum, item) => sum + (item['harga'] as int) * (item['jumlah'] as int),
  );

  // Calculate total number of items (quantities combined)
  int get totalItem =>
      pesanan.fold(0, (int sum, item) => sum + (item['jumlah'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background for modern look
      body: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildOrderListTitle(),
              const SizedBox(height: 12),
              Expanded(
                child:
                    pesanan.isEmpty
                        ? _buildEmptyCartState()
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ), // Consistent padding
                          itemCount: pesanan.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = pesanan[index];
                            return _CartItemCard(
                              item: item,
                              onQuantityChanged: (change) {
                                setState(() {
                                  item['jumlah'] = (item['jumlah'] + change)
                                      .clamp(0, 99);
                                  if (item['jumlah'] == 0) {
                                    pesanan.removeAt(
                                      index,
                                    ); // Remove if quantity drops to 0
                                  }
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  pesanan.removeAt(index);
                                  // Optional: Show a snackbar after deletion
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item['nama']} dihapus dari keranjang.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                });
                              },
                            );
                          },
                        ),
              ),
              // Spacer to ensure bottom sheet is always at the bottom
              // Replaced with Align widget for the bottom sheet
            ],
          ),
        ),
      ),
      // Use a custom bottom sheet that sits outside the main column
      bottomNavigationBar: _buildBottomSummary(),
    );
  }

  // --- UI Building Methods ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
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
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Keranjang Anda', // More personal title
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22, // Slightly larger
              shadows: [
                // Subtle text shadow
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Daftar Pesanan',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18, // Larger title
          shadows: [
            // Subtle text shadow
            Shadow(
              offset: const Offset(0.5, 0.5),
              blurRadius: 2.0,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjang Anda kosong!',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tambahkan makanan atau minuman untuk memulai pesanan.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back to menu to add items
                Get.back(); // Assumes previous screen is the menu
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4D9DAB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                elevation: 5,
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(
                'Mulai Belanja',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF119DB1).withOpacity(0.9), // Slightly transparent
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30), // More rounded corners
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 25,
      ), // Increased padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah Item',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              Text(
                '$totalItem item',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Increased spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pesanan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ), // Bolder total
              ),
              Text(
                'Rp ${totalHarga.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Bolder total price
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // Increased spacing before button
          SizedBox(
            width: double.infinity,
            height: 55, // Taller button
            child: ElevatedButton(
              onPressed: () {
                if (pesanan.isEmpty) {
                  Get.snackbar(
                    'Keranjang Kosong',
                    'Tambahkan item ke keranjang sebelum melanjutkan pembayaran.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orangeAccent.withOpacity(0.9),
                    colorText: Colors.white,
                  );
                } else {
                  // Get.to(() => MenuPembayaranPenghuni());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button
                foregroundColor: const Color(
                  0xFF119DB1,
                ), // Text color matches theme
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // More rounded
                ),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: Text(
                'Pesan Sekarang',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, // Bolder text
                  fontSize: 18, // Larger font
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Cart Item Card Widget ---
class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final ValueChanged<int> onQuantityChanged; // Callback for quantity change
  final VoidCallback onDelete; // Callback for deletion

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Added elevation
      shadowColor: Colors.black.withOpacity(0.15), // Subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // More rounded corners
      ),
      color: Colors.white, // White card background
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Increased padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // Rounded image corners
              child: Image.asset(
                item['image'],
                width: 90, // Slightly larger image
                height: 90,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        size: 45,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 16), // Spacing between image and text
            // Item Details and Quantity Controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama'],
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700, // Bolder name
                      fontSize: 17, // Larger font
                    ),
                    maxLines: 2, // Allow multiple lines for long names
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${item['harga'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4D9DAB), // Accent color for price
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ), // Spacing before quantity controls
                  // Quantity Adjuster
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Light background for controls
                      borderRadius: BorderRadius.circular(25), // Fully rounded
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Wrap content tightly
                      children: [
                        _buildQuantityButton(
                          Icons.remove,
                          () => onQuantityChanged(-1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${item['jumlah']}',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          Icons.add,
                          () => onQuantityChanged(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Delete Button
            IconButton(
              icon: Icon(
                Icons.delete_forever, // More impactful delete icon
                color: Colors.red.shade400, // Red color for delete
                size: 32,
              ),
              onPressed: onDelete,
              splashRadius: 28, // Larger splash area
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20), // Circular splash
      child: Container(
        padding: const EdgeInsets.all(6), // Padding inside button
        decoration: BoxDecoration(
          color: const Color(
            0xFF4D9DAB,
          ).withOpacity(0.1), // Light accent background
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4D9DAB), // Accent color for icons
          size: 20,
        ),
      ),
    );
  }
}
