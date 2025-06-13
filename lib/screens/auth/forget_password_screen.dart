import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/home_screen.dart';

class ForgetpasswordScreen extends StatefulWidget {
  const ForgetpasswordScreen({super.key});

  @override
  State<ForgetpasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetpasswordScreen> {
  final TextEditingController _forgetPasswordController =
      TextEditingController();

  void _submitEmail() {
    final email = _forgetPasswordController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan email yang valid.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Tampilkan dialog sukses
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap OK to dismiss
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Permintaan Terkirim',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(76, 56, 126, 1),
              ),
            ),
            content: Text(
              'Link reset password telah dikirim ke email Anda. Mohon cek inbox Anda.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Get.offAll(
                    () => const HomeScreenPage(),
                  ); // Kembali ke halaman login utama
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color.fromRGBO(144, 122, 204, 1.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _forgetPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna latar belakang yang sama dengan HomeScreenPage sebelumnya
    return Scaffold(
      backgroundColor: const Color(0xFFADBDE6), // Warna dari screenshot
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 30.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image Assets
                Image.asset(
                  'assets/home.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),

                // Lupa password text
                Text(
                  'Lupa Password?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32, // Ukuran font lebih besar
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Masukkan email Anda untuk menerima link reset password.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),

                // Email Input Field (Menggunakan fungsi helper _buildInputField)
                _buildInputField(
                  controller: _forgetPasswordController,
                  hintText: 'Email Anda', // Lebih spesifik
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  // Tidak perlu obscureText untuk email
                  // suffixIcon ditangani di dalam _buildInputField
                ),
                const SizedBox(height: 20),

                // Button kirim
                SizedBox(
                  width: double.infinity,
                  height: 55, // Tinggi button lebih besar
                  child: ElevatedButton(
                    onPressed: _submitEmail,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(
                        144,
                        122,
                        204,
                        1.0,
                      ), // Warna konsisten
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Border radius konsisten
                      ),
                      elevation: 5, // Tambahkan elevation
                    ),
                    child: Text(
                      'Kirim Link Reset', // Teks button lebih jelas
                      style: GoogleFonts.poppins(
                        fontSize: 18, // Ukuran font lebih besar
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Back to login link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _forgetPasswordController.clear();
                      Get.back(); // Menggunakan Get.back() untuk kembali ke halaman sebelumnya
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back, // Ikon kembali yang konsisten
                          size: 18,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kembali ke Login', // Teks lebih jelas
                          style: GoogleFonts.poppins(
                            color: Colors.white70, // Warna konsisten
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  // Fungsi helper untuk input field yang konsisten
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: Colors.black87),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[700])
                : null,
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => controller.clear()),
                )
                : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color.fromRGBO(144, 122, 204, 1.0),
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
