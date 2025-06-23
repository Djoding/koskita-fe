import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/dashboard_kos_screen.dart';
import 'package:kosan_euy/services/auth_service.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String userEmail;

  const CreatePasswordScreen({super.key, required this.userEmail});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // === Tambahkan GlobalKey untuk Form di sini ===
  final _formKey = GlobalKey<FormState>();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    // === Panggil validasi FORM di sini ===
    // Ini akan memicu validator di setiap TextFormField yang ada di dalam Form
    final isValidForm = _formKey.currentState?.validate() ?? false;

    // Jika form tidak valid, hentikan proses
    if (!isValidForm) {
      debugPrint('Validasi formulir gagal.');
      return;
    }

    // Ambil nilai password setelah validasi FE berhasil
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword =
        _confirmPasswordController.text
            .trim(); // Sebenarnya tidak perlu lagi di sini karena sudah divalidasi oleh validator

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _authService.setPassword(
        widget.userEmail,
        newPassword,
        confirmPassword, // Pastikan backend Anda memvalidasi ini juga
      );

      if (result['success'] == true) {
        Get.snackbar(
          'Sukses',
          result['message'] ?? 'Password berhasil diatur!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(() => const KosScreen());
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Gagal mengatur password. Mohon coba lagi.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error setting password: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFE4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            // === Bungkus Column dengan Form widget ===
            child: Form(
              key: _formKey, // Pasang GlobalKey di sini
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Buat Password',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Halo, ${widget.userEmail}!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Mohon buat password untuk akun Anda.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  _buildPasswordField(
                    controller: _newPasswordController,
                    labelText: 'Password Baru',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    // === Tambahkan validator untuk password baru ===
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password baru tidak boleh kosong';
                      }
                      if (value.length < 8) {
                        return 'Password minimal 8 karakter';
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'Harus mengandung setidaknya satu huruf kecil';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Harus mengandung setidaknya satu huruf besar';
                      }
                      if (!value.contains(RegExp(r'\d'))) {
                        return 'Harus mengandung setidaknya satu angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    labelText: 'Konfirmasi Password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    // === Tambahkan validator untuk konfirmasi password ===
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D9DAB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child:
                        _isSubmitting
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : Text(
                              'Buat Password',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // === Modifikasi _buildPasswordField untuk menjadi TextFormField ===
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator, // Tambahkan parameter validator
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextFormField(
          // <--- UBAH DARI TextField KE TextFormField
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          // Tambahkan onChanged agar UI bisa di-rebuild (misal, visibility icon)
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
            // === Tambahkan properti styling error yang sama ===
            errorBorder: OutlineInputBorder(
              // Border saat ada error tapi tidak fokus
              borderRadius: BorderRadius.circular(
                12,
              ), // Sesuaikan dengan Card shape
              borderSide: const BorderSide(
                color: Colors.redAccent, // Warna border merah untuk error
                width:
                    2.0, // Sedikit lebih tipis dari 2.5 agar tidak terlalu tebal di Card
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              // Border saat ada error dan sedang fokus
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color:
                    Colors
                        .red, // Warna border merah lebih gelap saat error & fokus
                width: 2.5,
              ),
            ),
            errorStyle: GoogleFonts.poppins(
              // Gaya teks untuk pesan error
              color: Colors.redAccent,
              fontSize:
                  12, // Ukuran font yang sedikit lebih kecil agar tidak mudah terpotong
              height:
                  1.2, // Atur line height untuk spacing antar baris jika pesan panjang
            ),
            errorMaxLines:
                2, // Izinkan pesan error hingga 2 baris (opsional, sesuaikan)
            // ======================================================
          ),
          validator:
              validator, // <--- Pasangkan parameter validator ke properti TextFormField
        ),
      ),
    );
  }
}
