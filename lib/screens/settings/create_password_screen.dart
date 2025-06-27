// create_password_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/admin/dashboard_admin.dart';
import 'package:kosan_euy/screens/owner/dashboard_owner_screen.dart';
import 'package:kosan_euy/screens/penghuni/dashboard_kos_screen.dart';
import 'package:kosan_euy/services/auth_service.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String userEmail;
  const CreatePasswordScreen({super.key, required this.userEmail});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userData = await _authService.setupPasswordAndLogin(
        widget.userEmail,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      _handleLoginSuccess(userData);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleLoginSuccess(Map<String, dynamic> userData) {
    Widget targetScreen;
    final String? role = userData['role'];

    if (role == "ADMIN") {
      targetScreen = const DashboardAdminScreen();
    } else if (role == "PENGELOLA") {
      targetScreen = const DashboardOwnerScreen();
    } else if (role == "PENGHUNI") {
      targetScreen = const KosScreen();
    } else {
      Get.snackbar('Error', 'Peran pengguna tidak dikenali.');
      return;
    }

    Get.offAll(() => targetScreen);

    Get.snackbar(
      'Sukses',
      'Password berhasil dibuat. Selamat datang!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFE4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
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
                    onToggleVisibility:
                        () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword,
                        ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Password baru tidak boleh kosong';
                      if (value.length < 8)
                        return 'Password minimal 8 karakter';
                      if (!value.contains(RegExp(r'[a-z]')))
                        return 'Harus mengandung setidaknya satu huruf kecil';
                      if (!value.contains(RegExp(r'[A-Z]')))
                        return 'Harus mengandung setidaknya satu huruf besar';
                      if (!value.contains(RegExp(r'\d')))
                        return 'Harus mengandung setidaknya satu angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    labelText: 'Konfirmasi Password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                    validator: (value) {
                      if (value != _newPasswordController.text)
                        return 'Password tidak cocok';
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
                              'Buat Password & Masuk',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4D9DAB), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        errorStyle: GoogleFonts.poppins(
          color: Colors.redAccent,
          fontSize: 12,
          height: 1.2,
        ),
        errorMaxLines: 2,
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
    );
  }
}
