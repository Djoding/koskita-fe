import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_Penghuni.dart';

class PemesananLaundryScreen extends StatefulWidget {
  const PemesananLaundryScreen({super.key});

  @override
  State<PemesananLaundryScreen> createState() => _PemesananLaundryScreenState();
}

class _PemesananLaundryScreenState extends State<PemesananLaundryScreen> {
  // Using nullable int to represent no selection initially, or set default index
  int? selectedTanggalPesan;
  int? selectedJamPesan;
  int? selectedTanggalKirim;
  int? selectedJamKirim;

  // Mock data for dates and times
  final List<String> hariTanggal = [
    'Senin\n23 Des',
    'Selasa\n24 Des',
    'Rabu\n25 Des',
    'Kamis\n26 Des',
    'Jumat\n27 Des',
    'Sabtu\n28 Des',
    'Minggu\n29 Des',
  ];
  final List<String> jamList = [
    '09.00 WIB',
    '10.00 WIB',
    '11.00 WIB',
    '12.00 WIB',
    '14.00 WIB',
    '15.00 WIB',
    '17.00 WIB',
    '19.00 WIB',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize default selections, e.g., first item
    selectedTanggalPesan = 0; // Select first date for pickup
    selectedJamPesan = 0; // Select first time for pickup
    selectedTanggalKirim = 0; // Select first date for delivery
    selectedJamKirim = 0; // Select first time for delivery
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ), // Consistent padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30), // Increased spacing
                  _buildSectionTitle('Waktu Penjemputan Pakaian'),
                  const SizedBox(height: 15),
                  _buildDateSelector(
                    hariTanggal,
                    selectedTanggalPesan,
                    (index) => setState(() => selectedTanggalPesan = index),
                  ),
                  const SizedBox(height: 15),
                  _buildTimeSelector(
                    jamList,
                    selectedJamPesan,
                    (index) => setState(() => selectedJamPesan = index),
                  ),
                  const SizedBox(height: 30), // Increased spacing
                  _buildSectionTitle('Waktu Pengembalian Pakaian'),
                  const SizedBox(height: 15),
                  _buildDateSelector(
                    hariTanggal,
                    selectedTanggalKirim,
                    (index) => setState(() => selectedTanggalKirim = index),
                  ),
                  const SizedBox(height: 15),
                  _buildTimeSelector(
                    jamList,
                    selectedJamKirim,
                    (index) => setState(() => selectedJamKirim = index),
                  ),
                  const SizedBox(height: 35), // Increased spacing
                  _buildLaundrySummaryCard(),
                  const SizedBox(height: 35), // Increased spacing
                  const Divider(
                    color: Colors.white,
                    thickness: 1.2,
                    height: 36,
                    indent: 8,
                    endIndent: 8,
                  ),
                  const SizedBox(height: 25), // Increased spacing
                  _buildNextButton(),
                  const SizedBox(height: 30), // Increased bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Building Methods ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0), // Adjusted padding
      child: Row(
        children: [
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
            'Pemesanan Laundry', // More descriptive title
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              shadows: [
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

  Widget _buildSectionTitle(String title) {
    return Center(
      // Centered title for clarity
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          shadows: [
            // Subtle shadow for text
            Shadow(
              offset: const Offset(0.5, 0.5),
              blurRadius: 2.0,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    List<String> dates,
    int? selectedIndex,
    ValueChanged<int> onSelected,
  ) {
    return SizedBox(
      height: 70, // Slightly increased height for better touch target
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, i) => const SizedBox(width: 12),
        itemBuilder:
            (context, i) => GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                // Animated for smooth transitions
                duration: const Duration(milliseconds: 250),
                constraints: const BoxConstraints(minWidth: 75), // Min width
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      selectedIndex == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    15,
                  ), // More rounded corners
                  border: Border.all(
                    color:
                        selectedIndex == i
                            ? const Color(0xFF119DB1)
                            : Colors.white.withOpacity(
                              0.5,
                            ), // Accent border on selected
                    width: selectedIndex == i ? 2 : 1,
                  ),
                  boxShadow: [
                    // Subtle shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    dates[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color:
                          selectedIndex == i
                              ? const Color(0xFF119DB1)
                              : Colors.white,
                      fontWeight:
                          selectedIndex == i
                              ? FontWeight.bold
                              : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTimeSelector(
    List<String> times,
    int? selectedIndex,
    ValueChanged<int> onSelected,
  ) {
    return Align(
      alignment: Alignment.centerLeft, // Align wrap content to left
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          times.length,
          (i) => GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              // Animated for smooth transitions
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color:
                    selectedIndex == i
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15), // More rounded corners
                border: Border.all(
                  color:
                      selectedIndex == i
                          ? const Color(0xFF119DB1)
                          : Colors.white.withOpacity(
                            0.5,
                          ), // Accent border on selected
                  width: selectedIndex == i ? 2 : 1,
                ),
                boxShadow: [
                  // Subtle shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                times[i],
                style: GoogleFonts.poppins(
                  color:
                      selectedIndex == i
                          ? const Color(0xFF119DB1)
                          : Colors.white,
                  fontWeight:
                      selectedIndex == i ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLaundrySummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Stronger shadow
            blurRadius: 15, // Increased blur
            offset: const Offset(0, 8), // More pronounced offset
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25, // Increased padding
          vertical: 25, // Increased padding
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center vertically in row
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3 Kg', // Example data
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700, // Bolder
                      fontSize: 22, // Larger
                    ),
                  ),
                  const SizedBox(height: 8), // Increased spacing
                  Text(
                    'Layanan:',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700], // Softer color
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cuci & Gosok', // Example data
                    style: GoogleFonts.poppins(
                      color: Colors.black54, // Softer black
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15), // Increased spacing
                  Text(
                    'Rp 18.000', // Example data
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4D9DAB), // Accent color
                      fontWeight: FontWeight.w800, // Extra bold
                      fontSize: 20, // Larger price
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Image and 'Tambah +' button
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15), // More rounded image
                  child: Image.asset(
                    'assets/laundry.png', // Ensure this asset exists
                    width: 100, // Larger image
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  // Using GestureDetector for the button
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '3 Kg laundry berhasil ditambahkan!',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF0B8FAC),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D9DAB), // Accent color for button
                      borderRadius: BorderRadius.circular(25), // Fully rounded
                      boxShadow: [
                        // Subtle shadow for button
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Tambah +',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Center(
      // Center the button
      child: SizedBox(
        width: 300, // Wider button
        height: 58, // Taller button
        child: ElevatedButton(
          onPressed: () {
            // Validate selections before navigating
            if (selectedTanggalPesan == null ||
                selectedJamPesan == null ||
                selectedTanggalKirim == null ||
                selectedJamKirim == null) {
              Get.snackbar(
                'Peringatan!',
                'Mohon lengkapi semua pilihan tanggal dan jam penjemputan serta pengiriman.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orangeAccent.withOpacity(0.9),
                colorText: Colors.white,
              );
              return;
            }
            Get.to(() => MenuPembayaranPenghuni());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF119DB1), // Accent color
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // More rounded
            ),
            elevation: 8, // Add stronger shadow
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: Text(
            'Lanjutkan Pembayaran', // More descriptive text
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
