import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/tamu/dashboard_tamu.dart';

class PembayaranTamuSelesaiScreen extends StatelessWidget {
  const PembayaranTamuSelesaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Hero Image
              Image.asset(
                'assets/header_done.png',
                width: 240,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              // DONE text
              Text(
                'DONE',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF119DB1),
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 18),
              // Subtext
              Text(
                'Pembayaran Berhasil!\nTerima kasih telah melakukan pembayaran.',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              // Button kembali ke dashboard
              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => DashboardTamuScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF119DB1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
