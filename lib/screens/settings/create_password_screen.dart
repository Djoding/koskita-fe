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
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Password baru dan konfirmasi password tidak boleh kosong.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password baru dan konfirmasi password tidak cocok.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (newPassword.length < 8) {
      Get.snackbar(
        'Error',
        'Password baru minimal 8 karakter.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _authService.setPassword(
        widget.userEmail,
        newPassword,
        confirmPassword,
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
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
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
          ),
        ),
      ),
    );
  }
}
