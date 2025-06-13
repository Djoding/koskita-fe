import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:kosan_euy/screens/penghuni/laundry/order_laundry_history.dart';
import 'package:kosan_euy/screens/penghuni/laundry/pemesanan_laundry.dart';

class LaundryPenghuni extends StatelessWidget {
  const LaundryPenghuni({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> laundryList = [
      {
        'name': '1 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 6.000', // Formatted price for display
        'image': 'assets/laundry.png',
      },
      {
        'name': '2 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 12.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '3 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 18.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '4 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 24.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '5 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 30.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '6 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 36.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '7 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 42.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '8 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 48.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '9 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 54.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '10 Kg',
        'service': 'Cuci & Gosok',
        'price': 'Rp 60.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': 'Sprei',
        'service': 'Cuci & Gosok',
        'price': 'Rp 15.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': 'Bedcover',
        'service': 'Cuci & Gosok',
        'price': 'Rp 25.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': 'Karpet',
        'service': 'Cuci & Gosok',
        'price': 'Rp 20.000',
        'image': 'assets/laundry.png',
      },
    ];

    return Scaffold(
      body: Container(
        // Use a gradient background for a modern look
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
            children: [
              _buildHeader(context),
              const SizedBox(height: 24), // Increased spacing
              Expanded(
                child:
                    laundryList.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ), // Adjusted padding
                          itemCount: laundryList.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(
                                height: 15,
                              ), // Spacing between cards
                          itemBuilder: (context, index) {
                            final item = laundryList[index];
                            return _LaundryItemCard(item: item);
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

  // --- UI Building Methods ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Consistent padding
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Distribute elements
        crossAxisAlignment: CrossAxisAlignment.center,
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
                Icons
                    .arrow_back_ios_new_rounded, // Rounded icon for consistency
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          // Title and Subtitle
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center text vertically
            children: [
              Text(
                'Layanan Laundry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700, // Bolder
                  fontSize: 22, // Larger
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cuci & Gosok',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8), // Slightly transparent
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          // Right side buttons/icons
          Row(
            children: [
              // History Button
              Container(
                width: 44,
                height: 44,
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
                    Icons.history, // History icon for laundry orders
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Get.to(
                      () => const LaundryOrderHistoryScreen(),
                    ); // Navigate to Laundry Order History
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ), // Spacing between history and laundry icon
              // Laundry Icon (Original icon from your design)
              SizedBox(
                width: 50, // Adjusted size
                height: 50,
                child: Image.asset(
                  'assets/icon_laundry.png', // Ensure this asset exists
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.local_laundry_service,
                        color: Colors.white, // White icon for consistency
                        size: 40,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_laundry_service,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada layanan laundry tersedia saat ini.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
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
              'Silakan coba lagi nanti atau hubungi pengelola.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30), // Adjusted padding
      child: SizedBox(
        width: double.infinity,
        height: 55, // Taller button
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const PemesananLaundryScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF119DB0), // Accent color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // More rounded
            ),
            elevation: 8, // Add shadow
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: Text(
            'Lanjutkan Pemesanan', // More descriptive text
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700, // Bolder
            ),
          ),
        ),
      ),
    );
  }
}

// --- Laundry Item Card Widget ---
class _LaundryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _LaundryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Add elevation for depth
      shadowColor: Colors.black.withOpacity(0.15), // Subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // More rounded corners
      ),
      color: Colors.white, // White card background
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16,
        ), // Consistent padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side: Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // Rounded image
              child: Image.asset(
                item['image'],
                width: 70, // Slightly larger image
                height: 70,
                fit: BoxFit.contain, // Use contain for icons/logos
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        size: 35,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 16), // Spacing between image and text
            // Middle: Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, // Bolder
                      fontSize: 18, // Larger
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Layanan: ${item['service']}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['price'],
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4D9DAB), // Accent color for price
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Add button
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFF4D9DAB,
                ).withOpacity(0.1), // Light accent background
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFF4D9DAB), // Accent color for icon
                  size: 24,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${item['name']} berhasil ditambahkan!',
                      ), // Dynamic message
                      backgroundColor: const Color(0xFF0B8FAC),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                splashRadius: 28, // Larger splash area
              ),
            ),
          ],
        ),
      ),
    );
  }
}
