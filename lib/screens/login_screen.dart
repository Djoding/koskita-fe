import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kosan_euy/screens/forgetpassword_screen.dart';
import 'package:kosan_euy/screens/owner/dashboard_owner_screen.dart';
import 'package:kosan_euy/screens/tenant/dashboard_tenant_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kosan_euy/services/auth_service.dart';
import 'package:kosan_euy/widgets/dialog_utils.dart';

class LoginScreen extends StatefulWidget {
  final String userRole;
  const LoginScreen({super.key, this.userRole = ''});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        "597965256700-rnvu6hrqq0ucng2qbma4s56bcsl3jt0s.apps.googleusercontent.com",
  );
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Track the current step of the login flow
  int _currentStep = 0; // 0: Email, 1: Password, 2: Registration (optional)

  // Store username for display after email submission
  String _username = "";
  String _email = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle email submission and move to password step
  void _submitEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() {
        _currentStep = 1;
        _email = email;
        // Extract username from email (before @)
        _username = email.split('@')[0];
      });
    }
  }

  // Handle password submission
  Future<void> _submitPassword() async {
    final password = _passwordController.text.trim();
    if (password.isNotEmpty) {
      try {
        DialogUtils.showLoadingDialog(context, true);

        var responLogin = await AuthService.login(_email, password);

        if (!responLogin["status"]) {
          if (!mounted) return;
          DialogUtils.hideLoadingDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // Create a SnackBar widget
              content: Text(responLogin["message"]),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {
                  // Code to execute when the action button is pressed
                },
              ),
            ),
          );
          return;
        }

        Widget targetScreen;
        var token = responLogin["token"];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        var role = decodedToken["role"];
        if (widget.userRole == "Pengelola" && role == "Pengelola") {
          targetScreen = const DashboardOwnerScreen();
        } else if (widget.userRole == "Penghuni" && role == "Penghuni") {
          targetScreen = const DashboardTenantScreen();
        } else {
          return;
        }

        if (!mounted) return;
        DialogUtils.hideLoadingDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responLogin["message"]),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        DialogUtils.hideLoadingDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan di Server.'),
            backgroundColor:
                Colors.red, // Optional: change background color for errors
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Switch to registration mode
  void _goToRegistration() {
    setState(() {
      _currentStep = 2;
    });
  }

  // Return to login screen
  void _backToLogin() {
    setState(() {
      _currentStep = 0;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display appropriate screen based on current step
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

  // Email input screen
  Widget _buildEmailScreen() {
    return Column(
      children: [
        // Header
        Text(
          'Login',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'KostKita',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // House Image
        Image.asset('assets/home.png', height: 150),
        const SizedBox(height: 24),

        // Email Input
        _buildInputField(
          controller: _emailController,
          hintText: 'Email',
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
        const SizedBox(height: 24),

        // Submit Email Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitEmail,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(175, 137, 240, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Kirim',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        //Register onclick
        TextButton(
          onPressed: () => {_goToRegistration()},
          child: Text(
            'Belum daftar?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              const Expanded(child: Divider(color: Colors.white60)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'atau lanjutkan dengan',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ),
              const Expanded(child: Divider(color: Colors.white60)),
            ],
          ),
        ),

        // Google Sign In Button
        InkWell(
          onTap: () {
            _signIn();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/google_logo.png', // Make sure to add this asset
                height: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Password input screen
  Widget _buildPasswordScreen() {
    return Column(
      children: [
        // User profile section
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color.fromRGBO(175, 137, 240, 1),
          child: Text(
            _username.isNotEmpty ? _username[0].toUpperCase() : "U",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _username,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          _email,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 24),

        // Password Input
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
        const SizedBox(height: 24),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitPassword,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(175, 137, 240, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Masuk',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Forgot Password link
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgetPasswordScreen(),
              ),
            );
          },
          child: Text(
            'Lupa Password?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Back to login link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _backToLogin,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'kembali ke login',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Registration screen
  Widget _buildRegistrationScreen() {
    return Column(
      children: [
        //Image
        Image.asset('assets/home.png', width: 150),
        // Title
        Text(
          'Mendaftar',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Silahkan buat Email dan Password',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        ),

        const SizedBox(height: 24),

        // Email Input
        _buildInputField(
          controller: _emailController,
          hintText: 'Email',
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
        const SizedBox(height: 16),

        // Password Input
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
        const SizedBox(height: 16),

        // Confirm Password Input
        _buildInputField(
          controller: _confirmPasswordController,
          hintText: 'Masukkan Kembali Password',
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed:
                () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
          ),
        ),
        const SizedBox(height: 24),

        // Register Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Handle registration logic
              debugPrint('Registration submitted');
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(175, 137, 240, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Masuk',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Back to login link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _backToLogin,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'kembali ke login',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
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
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: Color.fromRGBO(144, 122, 204, 1.0),
            width: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      DialogUtils.showLoadingDialog(context, true);
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null || googleUser == null) {
        throw Exception('Tidak bisa mendapatkan autentikasi dari Google');
      }

      final String? idToken = googleAuth.idToken;

      var dataLogin = await AuthService.loginWithGoogle(
        googleUser.displayName.toString(),
        googleUser.email,
        idToken!,
        googleUser.photoUrl.toString(),
        widget.userRole,
      );

      if (!mounted) return;
      if (dataLogin['status']) {
        DialogUtils.hideLoadingDialog(context);
        if (widget.userRole == "Pengelola") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardOwnerScreen(),
            ),
          );
        }

        if (widget.userRole == "Penghuni") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardTenantScreen(),
            ),
          );
        }
        return;
      }
      DialogUtils.hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dataLogin['message']),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      DialogUtils.hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan di Server.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      debugPrint('Error sign in with Google: $error');
    }
  }
}
