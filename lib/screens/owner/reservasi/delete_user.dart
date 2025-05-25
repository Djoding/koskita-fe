import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteUserScreen extends StatelessWidget {
  const DeleteUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nama =
        (Get.arguments != null && Get.arguments['nama'] != null)
            ? Get.arguments['nama']
            : 'Penghuni';
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lingkaran merah dengan X
                Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA72828),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.close, color: Colors.white, size: 100),
                  ),
                ),
                const SizedBox(height: 32),
                // Nama berhasil dihapus
                Text(
                  '$nama\nBerhasil Dihapus',
                  style: GoogleFonts.poppins(
                    color: Color(0xFFA72828),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Tombol kembali
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed('/dashboard-owner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA72828),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Kembali',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
