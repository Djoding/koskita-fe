import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/admin/notification/tamu_success_screen.dart';

class NotificationAdminScreen extends StatelessWidget {
  const NotificationAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFF91B7DE),
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 12,
                bottom: 18,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                  const SizedBox(width: 12),
                  Text(
                    'Pemberitahuan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Konten bawah dengan background putih kehijauan dan sudut atas melengkung
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3FFF7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hari Ini',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Notifikasi 1
                      _NotifItem(
                        icon: Icons.logout,
                        iconBg: const Color(0xFF2196F3),
                        title: 'Pengguna Kost Kapling 40 Berhasil Dihapus',
                        time: '12:30 - 10 Desember 2024',
                        isBlue: true,
                        showArrow: false,
                      ),
                      const SizedBox(height: 16),
                      // Notifikasi 2
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  title: const Text(
                                    'Konfirmasi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                    'Setujui Calon Pengguna kost ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF119DB1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Get.to(
                                          () => TamuSuccessScreen(
                                            title:
                                                'Pengguna kost berhasil ditambahkan',
                                          ),
                                        );
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: _NotifItem(
                          icon: Icons.person_add_alt_1,
                          iconBg: const Color(0xFF29B6F6),
                          title: 'Terdapat Pengguna Baru',
                          time: '17:00 - 10 Desember 2024',
                          isBlue: true,
                          showArrow: true,
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
    );
  }
}

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String time;
  final bool isBlue;
  final bool showArrow;
  const _NotifItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.time,
    this.isBlue = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isBlue ? const Color(0xFF1976D2) : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: isBlue ? TextDecoration.underline : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        if (showArrow)
          Container(
            margin: const EdgeInsets.only(left: 8, top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.black54,
            ),
          ),
      ],
    );
  }
}
