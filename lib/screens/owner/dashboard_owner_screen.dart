import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/penghuni_screen.dart';
import 'package:kosan_euy/screens/reservasi_screen.dart';
import 'package:kosan_euy/widgets/profile_section.dart';
import 'package:kosan_euy/widgets/top_bar.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({super.key});

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (Notification & Settings)
              TopBar(),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Menu Pemesanan Makanan tap"),
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
}
