import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kosan_euy/screens/owner/laundry/dashboard_laundry.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_screen.dart';

import 'package:kosan_euy/widgets/profile_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';

import 'package:kosan_euy/routes/app_pages.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({super.key});

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  bool isExists = false;
  late List<Map<String, dynamic>> daftarKost = [];
  String? userId;

  @override
  void initState() {
    // _fetchKostData(); // KOMEN: slicing UI, data dummy
    _getUserId();
    // --- DATA DUMMY UNTUK SLICING UI ---
    daftarKost = [
      {
        'Nama_Kost': 'Kost Mawar',
        'Lokasi_Alamat': 'Jalan hj Umayah II, Citereup Bandung',
        'jumlahKamar': 10,
        'harga': 1000000,
        'Thumbnail': 'assets/kapling40.png',
        'ID_Pengguna': null,
      },
      {
        'Nama_Kost': 'Kost Melati',
        'Lokasi_Alamat': 'Jl. Melati No. 2',
        'jumlahKamar': 8,
        'harga': 900000,
        'Thumbnail': 'assets/kapling40.png',
        'ID_Pengguna': null,
      },
    ];
    isExists = true;
    super.initState();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      setState(() {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        userId = decodedToken["id"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildListKost();
  }

  Widget _buildMenuCard() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (Notification & Settings)
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 32),
                      enableFeedback: true,
                      color: Colors.white,
                      onPressed: () {
                        Get.toNamed(Routes.notificationOwner);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 32),
                      enableFeedback: true,
                      color: Colors.white,
                      onPressed: () {
                        Get.toNamed(Routes.setting);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Spacing
              ProfileSection(),
              const SizedBox(height: 40), // Spacing
              // Menu (Expanded)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Menu Data Penghuni
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(211, 234, 255, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(Routes.penghuni);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Melihat Data Penghuni Kost',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Image.asset(
                                  'assets/icon_penghuni.png',
                                  width: 150,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Lihat lebih lanjut >',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    //Menu Layanan Reservasi Kamar
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(211, 234, 255, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(Routes.homeReservasiOwner);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Layanan Reservasi Kamar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Image.asset(
                                  'assets/icon_reservasi.png',
                                  width: 150,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Lihat lebih lanjut >',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    //Menu Pemesanan Makanan
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(211, 234, 255, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => const LayananMakananScreen());
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Layanan Pemesanan Makan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Image.asset(
                                  'assets/icon_makanan.png',
                                  width: 150,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Lihat lebih lanjut >',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    //Menu Layanan Laundry
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(211, 234, 255, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => const DashboardLaundryScreen());
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Layanan Laundry',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Image.asset(
                                  'assets/icon_laundry.png',
                                  width: 150,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Lihat lebih lanjut >',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildListKost() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () async {
                        await _onLogout(context);
                        Get.offAllNamed(Routes.home);
                      },
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      Get.toNamed(Routes.notification);
                    },
                  ),
                ],
              ),

              // Search bar
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari kost Anda',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

              // Kost listings
              SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: daftarKost.length,
                  itemBuilder: (BuildContext context, int index) {
                    final kost = daftarKost[index];

                    return InkWell(
                      onTap: () {
                        if (kost["ID_Pengguna"] == userId) {
                          Get.to(_buildMenuCard());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Anda tidak berhak untuk masuk kost ini",
                              ),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Dismiss',
                                onPressed: () {
                                  // Code to execute when the action button is pressed
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF9EBFED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withAlpha((0.4 * 255).toInt()),
                            width: 1,
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Kost image with rounded corners
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      kost["Thumbnail"] as String,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              // Kost details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      kost["Nama_Kost"] as String,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      kost["Lokasi_Alamat"] as String,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Register button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withAlpha((0.3 * 255).toInt()),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(child: Divider(color: Colors.white60)),
                      InkWell(
                        onTap: () {
                          Get.toNamed(Routes.daftarKos);
                        },
                        child: Text(
                          'Daftarkan Kost Anda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white60)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    // await AuthService.logout();
  }
}
