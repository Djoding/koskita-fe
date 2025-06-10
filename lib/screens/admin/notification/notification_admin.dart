// lib/screens/admin/notification/notification_admin.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/admin/pengelola_detail_screen.dart';
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
                    'Pemberitahuan Admin',
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
                      Text(
                        'Hari Ini',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Notifikasi 1 - Pengguna baru mendaftar
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => PenggelolaDetailScreen(
                              pengelola: {
                                'id': '1',
                                'nama': 'John Doe',
                                'email': 'john@example.com',
                                'namaKost': 'Kost Kapling 40',
                                'lokasi': 'Jl. Kapling No. 40',
                                'tanggalDaftar': '2024-06-10',
                                'status': 'pending',
                                'phone': '08123456789',
                                'alamat': 'Jl. Contoh No. 123, Semarang',
                                'nik': '3374123456789012',
                                'jumlahKamar': 10,
                                'harga': '1000000',
                                'jenisKost': 'Putra',
                              },
                            ),
                          );
                        },
                        child: _NotifItem(
                          icon: Icons.person_add_alt_1,
                          iconBg: const Color(0xFF29B6F6),
                          title: 'Pengelola Baru Mendaftar',
                          subtitle: 'John Doe - Kost Kapling 40',
                          time: '17:00 - 10 Juni 2024',
                          isBlue: true,
                          showArrow: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Notifikasi 2 - Pengguna berhasil diverifikasi
                      _NotifItem(
                        icon: Icons.verified_user,
                        iconBg: const Color(0xFF4CAF50),
                        title: 'Pengelola Berhasil Diverifikasi',
                        subtitle: 'Ahmad Sari - Kost Mawar',
                        time: '14:30 - 10 Juni 2024',
                        isBlue: false,
                        showArrow: false,
                      ),
                      const SizedBox(height: 16),
                      // Notifikasi 3 - Pengguna dihapus
                      _NotifItem(
                        icon: Icons.person_remove,
                        iconBg: const Color(0xFFF44336),
                        title: 'Pengelola Dihapus dari Sistem',
                        subtitle: 'Data spam telah dibersihkan',
                        time: '12:30 - 10 Juni 2024',
                        isBlue: false,
                        showArrow: false,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Kemarin',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Notifikasi 4 - Laporan harian
                      _NotifItem(
                        icon: Icons.analytics,
                        iconBg: const Color(0xFF9C27B0),
                        title: 'Laporan Harian Sistem',
                        subtitle: '5 pengelola baru, 3 diverifikasi',
                        time: '23:59 - 9 Juni 2024',
                        isBlue: false,
                        showArrow: false,
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
  final String subtitle;
  final String time;
  final bool isBlue;
  final bool showArrow;

  const _NotifItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isBlue = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (showArrow)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}
