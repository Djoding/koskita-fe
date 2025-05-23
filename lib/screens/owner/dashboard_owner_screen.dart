import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kosan_euy/screens/makanan/makanan_screen.dart';
import 'package:kosan_euy/screens/owner/daftar_kos_screen.dart';
import 'package:kosan_euy/screens/owner/notification/notification_owner.dart';
import 'package:kosan_euy/screens/owner/penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/reservasi/reservasi_screen.dart';
import 'package:kosan_euy/screens/settings/notification_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/kost_service.dart';
import 'package:kosan_euy/widgets/profile_section.dart';
import 'package:kosan_euy/widgets/top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../home_screen.dart';

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
    _fetchKostData();
    _getUserId();
    super.initState();
  }

  Future _fetchKostData() async {
    var responseData = await KostService.getDataKost();
    isExists = responseData['status'];
    if (isExists) {
      setState(() {
        List<dynamic> rawData = responseData['data'];
        daftarKost = List<Map<String, dynamic>>.from(rawData);
      });
    }
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
  
  Widget _buildMenuCard(){
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationOwner()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 32),
                      enableFeedback: true,
                      color: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingScreen()),
                        );
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PenghuniScreen())
                          );
                        },
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Melihat Data Penghuni Kost', style: GoogleFonts.poppins(
                                        fontSize: 20 ,
                                        fontWeight: FontWeight.bold
                                    ),),
                                    Image.asset(
                                      'assets/icon_penghuni.png',
                                      width: 150,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('Lihat lebih lanjut >', style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300
                                      ),),
                                    )
                                  ],
                                )
                            )
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),

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
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReservasiScreen())
                          );
                        },
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Layanan Reservasi Kamar', style: GoogleFonts.poppins(
                                        fontSize: 20 ,
                                        fontWeight: FontWeight.bold
                                    ),),
                                    Image.asset(
                                      'assets/icon_reservasi.png',
                                      width: 150,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('Lihat lebih lanjut >', style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300
                                      ),),
                                    )
                                  ],
                                )
                            )
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),

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
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FoodListScreen())
                          );
                        },
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Layanan Pemesanan Makan', style: GoogleFonts.poppins(
                                        fontSize: 20 ,
                                        fontWeight: FontWeight.bold
                                    ),),
                                    Image.asset(
                                      'assets/icon_makanan.png',
                                      width: 150,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('Lihat lebih lanjut >', style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300
                                      ),),
                                    )
                                  ],
                                )
                            )
                        ),
                      ),
                    ),

                    SizedBox(height: 30,),

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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Menu Layanan Laundry tap"),
                              duration: Duration(seconds: 1),
                              showCloseIcon: true,
                            ),
                          );
                        },
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Layanan Laundry', style: GoogleFonts.poppins(
                                        fontSize: 20 ,
                                        fontWeight: FontWeight.bold
                                    ),),
                                    Image.asset(
                                      'assets/icon_laundry.png',
                                      width: 150,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('Lihat lebih lanjut >', style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300
                                      ),),
                                    )
                                  ],
                                )
                            )
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      onPressed: () {
                        _onLogout(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreenPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.notifications_none, color: Colors.black, size: 28),
                    onPressed: () {
                      //
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _buildMenuCard(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Anda tidak berhak untuk masuk kost ini"),
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
                            color: Colors.white.withOpacity(0.4),
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
                                    image: NetworkImage(kost["Thumbnail"] as String),
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
                      )
                    );

                  },
                )
              ),

              // Register button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.3),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DaftarKosScreen())
                          );
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
    await AuthService.logout();
  }
}
