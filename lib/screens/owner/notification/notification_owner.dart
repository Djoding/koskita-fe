import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/routes/app_pages.dart';
import 'package:kosan_euy/screens/owner/notification/notifikasi_reservasi/notification_reservasi.dart';
import 'notifikasi_makanan/views/notifikasi_makanan_screen.dart';

class NotificationOwner extends StatefulWidget {
  const NotificationOwner({super.key});

  @override
  State<NotificationOwner> createState() => _NotificationOwnerState();
}

class _NotificationOwnerState extends State<NotificationOwner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          // Changed SingleChildScrollView to Column here
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
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
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),

                  // Title
                  Text(
                    'Pemberitahuan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(width: 50, height: 50),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(241, 255, 243, 1.0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Menu Layanan Reservasi Kamar
                      _buildMenuItem(
                        context: context,
                        title: 'Layanan Reservasi Kamar',
                        iconPath: 'assets/icon_reservasi.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const NotificationReservasiScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      //Menu Pemesanan Makanan
                      _buildMenuItem(
                        context: context,
                        title: 'Layanan Pemesanan Makan',
                        iconPath: 'assets/icon_makanan.png',
                        onTap: () {
                          Get.to(() => const NotifikasiMakananScreen());
                          // Navigator.push(
                          //     context,
                          //     // MaterialPageRoute(builder: (context) => const FoodListScreen())
                          // );
                        },
                      ),

                      const SizedBox(height: 30),

                      //Menu Layanan Laundry
                      _buildMenuItem(
                        context: context,
                        title: 'Layanan Laundry',
                        iconPath: 'assets/icon_laundry.png',
                        onTap: () {
                          Get.toNamed(Routes.notifikasiLaundry);
                        },
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

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    Widget imageWidget;
    try {
      imageWidget = Image.asset(
        iconPath,
        width: 150,
        errorBuilder: (
          BuildContext context,
          Object exception,
          StackTrace? stackTrace,
        ) {
          return Container(
            width: 150,
            height: 100, // Give some height to the placeholder
            color: Colors.grey[300],
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey[600],
              ),
            ),
          );
        },
      );
    } catch (e) {
      imageWidget = Container(
        width: 150,
        height: 100,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(211, 234, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imageWidget,
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
