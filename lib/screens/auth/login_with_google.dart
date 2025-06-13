import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/admin/dashboard_admin.dart';

class LoginWithGoogle extends StatelessWidget {
  const LoginWithGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tombol back
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(height: 8),
                // Gambar rumah
                Image.asset('assets/home.png', width: 180),
                const SizedBox(height: 16),
                // Judul
                Text(
                  'Login dengan Google',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Emoji
                const Text('✌️', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                // Pilih akun
                Text(
                  'Pilih akun',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                // Card akun
                InkWell(
                  onTap: () {
                    // Routing ke dashboard owner
                    Get.off(() => DashboardAdminScreen());
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            'K',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nama akun',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'akuadmin@gmail.com',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Card gunakan akun lain
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Gunakan akun lain',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Teks kebijakan
                Text(
                  'Untuk melanjutkan, Google akan membagikan nama, alamat email, preferensi bahasa, dan gambar profil Anda dengan Perusahaan. Sebelum menggunakan aplikasi ini, Anda dapat meninjau Kebijakan Privasi Perusahaan.',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Link kebijakan
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: 'kebijakan privasi',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(
                        text: ' dan ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'ketentuan layanan.',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
