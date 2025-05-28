import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/admin/notification/notification_admin.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/widgets/success_delete_screen.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Stack(
          children: [
            // Statistik Users/Locations (pojok kanan atas, tulisan selalu di tengah)
            Positioned(
              top: 24,
              right: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.10 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF119DB1),
                        width: 5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Users : 3',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF119DB1),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Locations : 3',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF119DB1),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            // Konten utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ],
                  ),
                  // Spacer agar greeting tidak ketabrak statistik
                  const SizedBox(height: 80),
                  // Greeting & Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi Admin!',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Selamat datang kembali ke panel Anda.',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Notifikasi & Settings dalam satu baris
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.black,
                              size: 28,
                            ),
                            onPressed: () {
                              Get.to(() => NotificationAdminScreen());
                            },
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.black,
                              size: 28,
                            ),
                            onPressed: () {
                              Get.to(() => SettingScreen());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Judul Daftar Pengguna
                  Text(
                    'Daftar Pengguna',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // List Pengguna
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 8),
                      children: [
                        _UserCard(nama: 'Kost Kapling 40'),
                        const SizedBox(height: 18),
                        _UserCard(nama: 'Kost Melati'),
                        const SizedBox(height: 18),
                        _UserCard(nama: 'Kost Mawar'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String nama;
  const _UserCard({required this.nama});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: const Color(0xFF119DB1), width: 2.5),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.person, color: Color(0xFF119DB1), size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              nama,
              style: GoogleFonts.poppins(
                color: const Color(0xFF119DB1),
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      title: const Text(
                        'Konfirmasi Hapus',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        'Apakah Anda yakin ingin menghapus $nama ini?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA51B1B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => SuccessDeleteScreen(
                                title: 'Data berhasil dihapus',
                              ),
                            );
                          },
                          child: const Text('Iya'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
