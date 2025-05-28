import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/admin/auth/admin_login_screen.dart';
import 'package:kosan_euy/screens/owner/auth/owner_login_screen.dart';
import 'package:kosan_euy/screens/penghuni/auth/penghuni_login_screen.dart';
import 'package:kosan_euy/screens/tamu/auth/tamu_login_screen.dart';

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = size.width * 0.7 > 300 ? 300.0 : size.width * 0.7;
    // _checkIfLoggedIn(context); // --- OFFLINE MODE: dikomentari agar tidak redirect otomatis ---

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                Text(
                  'KostKita',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: size.width * 0.15, // Responsive font size
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // House Image
                Image.asset(
                  'assets/home.png',
                  height: size.height * 0.25, // Responsive image height
                ),
                const SizedBox(height: 24),

                // Login as text
                Text(
                  'Masuk Sebagai',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),

                // User Type Buttons
                _buildGradientButton(
                  context: context,
                  width: buttonWidth,
                  label: 'Pengelola Kost',
                  onPressed: () {
                    Get.to(() => const OwnerLoginScreen());
                  },
                ),
                const SizedBox(height: 12),

                _buildGradientButton(
                  context: context,
                  width: buttonWidth,
                  label: 'Penghuni Kost',
                  onPressed: () {
                    Get.to(() => const PenghuniLoginScreen());
                  },
                ),
                const SizedBox(height: 12),

                _buildGradientButton(
                  context: context,
                  width: buttonWidth,
                  label: 'Tamu',
                  onPressed: () {
                    Get.to(() => const TamuLoginScreen());
                  },
                ),

                const SizedBox(height: 12),

                _buildGradientButton(
                  context: context,
                  width: buttonWidth,
                  label: 'Admin',
                  onPressed: () {
                    Get.to(() => const AdminLoginScreen());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required double width,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(75, 44, 153, 1.0), // Dark purple
            Color.fromRGBO(144, 122, 204, 1.0), // Lighter purple
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.deepPurple, width: 1),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.acme(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Future<void> _checkIfLoggedIn(BuildContext context) async {
  //   Future.microtask(() async {
  //     final isLoggedIn = await AuthService.isLoggedIn();
  //     if (isLoggedIn["isLoggedIn"]) {
  //       var token = isLoggedIn["token"];
  //       Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  //       var role = decodedToken["role"];
  //       if (role == "Pengelola" || role == "Penghuni" || role == "Admin") {
  //         if (role == "Pengelola") {
  //           Get.offNamed(Routes.dashboardOwner);
  //         } else if (role == "Penghuni") {
  //           Get.offNamed(Routes.dashboardTenant);
  //         } else if (role == "Admin") {
  //           Get.offNamed(Routes.dashboardOwner);
  //         }
  //       } else {
  //         debugPrint('Role tidak dikenal: $role');
  //       }
  //     }
  //   });
  // }
}
