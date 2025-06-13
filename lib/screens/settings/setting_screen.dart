import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/settings/edit_profile_screen.dart';
import 'package:kosan_euy/screens/settings/security_screen.dart';
import 'package:kosan_euy/services/auth_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AuthService _authService = AuthService();
  String _fullName = 'Memuat...';
  String _userRole = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getStoredUserData();
      if (userData != null) {
        setState(() {
          _fullName = userData['full_name'] ?? 'Nama Pengguna';
          _userRole = userData['role'] ?? 'Peran Pengguna';
          if (_userRole == 'ADMIN' || _userRole == 'PENGELOLA') {
            _userRole = 'Pengelola Kost';
          } else if (_userRole == 'PENGHUNI') {
            _userRole = 'Penghuni Kost';
          }
        });
      }
    } catch (e) {
      setState(() {
        _fullName = 'Error';
        _userRole = 'Error';
      });
      // Optionally, show a SnackBar or other error indication to the user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3C4D82), Color(0xFF6A82FB)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
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
                        'Pengaturan',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_none_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(241, 255, 243, 1.0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 30.0,
                    ),
                    child: Column(
                      children: [
                        _buildProfileInfo(),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              menuItem(
                                icon: Icons.person_outline,
                                iconColor: Colors.blue,
                                iconBackground: Colors.blue.withAlpha(
                                  (0.1 * 255).toInt(),
                                ),
                                title: 'Edit Profil',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const EditProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1, color: Colors.grey[200]),
                              menuItem(
                                icon: Icons.shield_outlined,
                                iconColor: Colors.blue,
                                iconBackground: Colors.blue.withAlpha(
                                  (0.1 * 255).toInt(),
                                ),
                                title: 'Keamanan',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SecurityScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1, color: Colors.grey[200]),
                              menuItem(
                                icon: Icons.logout,
                                iconColor: Colors.redAccent,
                                iconBackground: Colors.redAccent.withAlpha(
                                  (0.1 * 255).toInt(),
                                ),
                                title: 'Keluar',
                                onTap: () async {
                                  final bool? confirmed =
                                      await showLogoutConfirmationDialog(
                                        context,
                                      );
                                  if (confirmed == true) {
                                    await _authService.logout();
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const HomeScreenPage(),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Text(
          _fullName,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        Text(
          _userRole,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget menuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showLogoutConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: const LogoutConfirmationContent(),
      );
    },
  );
}

class LogoutConfirmationContent extends StatelessWidget {
  const LogoutConfirmationContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sesi Akhir',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3F4C),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5EBE8E),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: Text(
              'Ya',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFEAF9F0),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Tidak',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
