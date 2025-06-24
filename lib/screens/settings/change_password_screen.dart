import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/widgets/success_screen.dart';
import 'package:kosan_euy/services/auth_service.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // === Tambahkan GlobalKey untuk Form di sini ===
  final _formKey = GlobalKey<FormState>();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final AuthService _authService = AuthService();
  String _fullName = 'Memuat...';
  String _userRole = 'Memuat...';
  String? _avatarUrl;
  bool _isLoadingUserData = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });
    try {
      final userData = await _authService.getStoredUserData();
      if (userData != null) {
        setState(() {
          _fullName = userData['full_name'] ?? 'Nama Pengguna';
          _userRole = userData['role'] ?? 'Peran Pengguna';
          String? rawAvatarPath = userData['avatar'];

          if (rawAvatarPath != null && rawAvatarPath.isNotEmpty) {
            if (rawAvatarPath.startsWith('http://') ||
                rawAvatarPath.startsWith('https://')) {
              _avatarUrl = rawAvatarPath;
            } else if (rawAvatarPath.startsWith('/')) {
              _avatarUrl = 'https://kost-kita.my.id$rawAvatarPath';
            } else {
              _avatarUrl = 'https://kost-kita.my.id/$rawAvatarPath';
            }
          } else {
            _avatarUrl = null;
          }

          if (_userRole == 'ADMIN') {
            _userRole = 'Admin';
          } else if (_userRole == 'PENGELOLA') {
            _userRole = 'Pengelola Kost';
          } else if (_userRole == 'PENGHUNI') {
            _userRole = 'Penghuni Kost';
          }
        });
      } else {
        _fullName = 'Tidak Login';
        _userRole = 'Tamu';
        _avatarUrl = null;
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _fullName = 'Error';
        _userRole = 'Error';
        _avatarUrl = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pengguna: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _changePassword() async {
    // === Panggil validasi FORM di sini ===
    final isValidForm = _formKey.currentState?.validate() ?? false;

    // Jika form tidak valid, hentikan proses
    if (!isValidForm) {
      debugPrint('Validasi formulir gagal.');
      // Pesan error akan ditampilkan langsung di bawah TextFormField
      return;
    }

    // Ambil nilai password setelah validasi FE berhasil
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    // final confirmPassword = _confirmPasswordController.text.trim(); // Tidak perlu diperiksa lagi di sini

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _authService.changePassword(
        currentPassword,
        newPassword,
      );

      if (result['success'] == true) {
        Get.snackbar(
          'Sukses',
          result['message'] ?? 'Password berhasil diubah!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.off(
          () => const SuccessScreen(
            title: 'Password Berhasil Diubah',
            subtitle: 'Password Anda telah berhasil diperbarui.',
          ),
        );
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Gagal mengubah password. Mohon coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
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
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFE4),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(248, 248, 255, 1.0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child:
                    _isLoadingUserData
                        ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF3C4D82),
                            ),
                          ),
                        )
                        : SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            top: 80.0,
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          // === Bungkus Column dengan Form widget ===
                          child: Form(
                            key: _formKey, // Pasang GlobalKey di sini
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _fullName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3C4D82),
                                  ),
                                ),
                                Text(
                                  _userRole,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                _buildPasswordField(
                                  controller: _currentPasswordController,
                                  labelText: 'Password Saat Ini',
                                  obscureText: _obscureCurrentPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureCurrentPassword =
                                          !_obscureCurrentPassword;
                                    });
                                  },
                                  // === Tambahkan validator untuk Current Password ===
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password saat ini tidak boleh kosong';
                                    }
                                    // Anda bisa menambahkan validasi lebih lanjut jika Anda ingin membandingkan dengan password pengguna yang tersimpan
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildPasswordField(
                                  controller: _newPasswordController,
                                  labelText: 'Password Baru',
                                  obscureText: _obscureNewPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureNewPassword =
                                          !_obscureNewPassword;
                                    });
                                  },
                                  // === Tambahkan validator untuk New Password ===
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
                                    // Optional: New password should not be the same as current password
                                    // if (value == _currentPasswordController.text) {
                                    //   return 'Password baru tidak boleh sama dengan password saat ini';
                                    // }
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
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  // === Tambahkan validator untuk Confirm Password ===
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
                                  onPressed:
                                      _isSubmitting ? null : _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4D9DAB),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(250, 55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  child:
                                      _isSubmitting
                                          ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          )
                                          : Text(
                                            'Ganti Password',
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
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(child: _buildAvatar()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Text(
            'Ganti Password',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 44, height: 44),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF3C4D82),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child:
            _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? Image.network(
                  _avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading avatar image: $error');
                    return Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth: 3,
                      ),
                    );
                  },
                )
                : Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white.withOpacity(0.8),
                ),
      ),
    );
  }

  // === Modifikasi _buildPasswordField untuk menjadi TextFormField dan menambahkan validator ===
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
          onChanged:
              (_) =>
                  setState(() {}), // Panggil setState agar UI bisa di-rebuild
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
            // === Tambahkan properti styling error ===
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator, // <--- Pasangkan parameter validator
        ),
      ),
    );
  }
}
