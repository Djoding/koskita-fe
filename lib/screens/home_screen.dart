import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/admin/dashboard_admin.dart';
import 'package:kosan_euy/screens/owner/dashboard_owner_screen.dart';
import 'package:kosan_euy/screens/penghuni/dashboard_kos_screen.dart';
import 'package:kosan_euy/screens/settings/create_password_screen.dart';
import 'package:kosan_euy/screens/tamu/dashboard_tamu_screen.dart';
import 'package:kosan_euy/services/auth_service.dart';

class HomeScreenPage extends StatefulWidget {
  final String userRole;
  const HomeScreenPage({super.key, this.userRole = ''});

  @override
  State<HomeScreenPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<HomeScreenPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  int _currentStep = 0;
  String _username = "";
  String _email = "";
  String? _selectedRole;

  final Map<String, String> _roleMap = {
    'Pengelola Kos': 'PENGELOLA',
    'Penghuni Kos': 'PENGHUNI',
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() {
        _currentStep = 1;
        _email = email;
        _username = email.split('@')[0];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan email yang valid.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submitPassword() async {
    final password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final userData = await _authService.login(_email, password);

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _handleLoginSuccess(userData);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password tidak boleh kosong.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userData = await _authService.signInWithGoogle();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final bool hasManualPassword = userData['has_manual_password'] ?? false;
      final String? userId = userData['user_id'];
      final String? userEmail = userData['email'];

      if (userId == null || userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Data pengguna tidak lengkap dari Google login.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      if (hasManualPassword == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePasswordScreen(userEmail: userEmail),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda perlu membuat password akun Anda.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        _handleLoginSuccess(userData);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Peran pengguna tidak dikenali.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login berhasil!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goToRegistration() {
    setState(() {
      _currentStep = 2;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _fullNameController.clear();
      _selectedRole = null;
    });
  }

  void _backToLogin() {
    setState(() {
      _currentStep = 0;
      _passwordController.clear();
      _confirmPasswordController.clear();
      _emailController.clear();
      _fullNameController.clear();
      _selectedRole = null;
    });
  }

  Future<void> _submitRegistration() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih peran Anda (Pengelola Kos atau Penghuni Kos).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!isValidForm) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final String? backendRole = _roleMap[_selectedRole];
      if (backendRole == null) {
        throw Exception('Invalid role selected.');
      }

      await _authService.register(
        email.split('@')[0],
        fullName,
        email,
        password,
        role: backendRole,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      _backToLogin();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFADBDE6),
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
                if (_currentStep == 0) _buildEmailScreen(),
                if (_currentStep == 1) _buildPasswordScreen(),
                if (_currentStep == 2) _buildRegistrationScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailScreen() {
    return Column(
      children: [
        Text(
          'Selamat Datang di',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        Text(
          'KostKita',
          style: GoogleFonts.poppins(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 30),

        Image.asset('assets/home.png', height: 180, fit: BoxFit.contain),
        const SizedBox(height: 30),

        _buildInputField(
          controller: _emailController,
          hintText: 'Masukkan email Anda',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          suffixIcon:
              _emailController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => setState(() => _emailController.clear()),
                  )
                  : null,
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _submitEmail,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(144, 122, 204, 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: Text(
              'Lanjutkan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum punya akun?',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            TextButton(
              onPressed: _goToRegistration,
              child: Text(
                'Daftar Sekarang',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Row(
            children: [
              const Expanded(child: Divider(color: Colors.white54)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'atau masuk dengan',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Colors.white54)),
            ],
          ),
        ),

        InkWell(
          onTap: _isLoading ? null : _signInWithGoogle,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).toInt()),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Color.fromRGBO(144, 122, 204, 1.0),
                      )
                      : Image.asset('assets/google_logo.png', height: 30),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () {
            Get.to(() => DashboardTamuScreen());
          },
          child: Text(
            'Masuk sebagai tamu',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Selamat Datang Kembali!',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Silakan masukkan kata sandi Anda untuk melanjutkan.',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        const SizedBox(height: 16),
        Text(
          _username,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          _email,
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
        ),
        const SizedBox(height: 30),

        _buildInputField(
          controller: _passwordController,
          hintText: 'Password',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed:
                () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitPassword,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(144, 122, 204, 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Masuk',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _backToLogin,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  'Kembali',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Daftar Akun Baru',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Buat akun Anda untuk mulai mencari kosan impian!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
            ),

            const SizedBox(height: 30),

            _buildInputField(
              controller: _fullNameController,
              hintText: 'Nama Lengkap',
              keyboardType: TextInputType.text,
              prefixIcon: Icons.person_outline,
              suffixIcon:
                  _fullNameController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed:
                            () => setState(() => _fullNameController.clear()),
                      )
                      : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama lengkap tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              suffixIcon:
                  _emailController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed:
                            () => setState(() => _emailController.clear()),
                      )
                      : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
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
            const SizedBox(height: 16),

            _buildInputField(
              controller: _confirmPasswordController,
              hintText: 'Konfirmasi Password',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed:
                    () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != _passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                      _selectedRole == null
                          ? Colors.redAccent
                          : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  hint: Text(
                    'Pilih Peran Anda',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                  isExpanded: true,
                  style: GoogleFonts.poppins(color: Colors.black87),
                  items:
                      <String>[
                        'Pengelola Kos',
                        'Penghuni Kos',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(144, 122, 204, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Daftar',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _backToLogin,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kembali ke Login',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
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
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
        suffixIcon: suffixIcon,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.redAccent, 
            width: 2.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color:
                Colors.red,
            width: 2.5,
          ),
        ),
        errorStyle: GoogleFonts.poppins(
          color: Colors.redAccent,
          fontSize:
              12, 
          height:
              1.2,
        ),
        errorMaxLines: 2,
      ),
      validator: validator,
    );
  }
}
