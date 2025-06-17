// lib/screens/admin/pengelola_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/widgets/success_delete_screen.dart';
import 'package:kosan_euy/services/admin_service.dart';
import 'package:kosan_euy/widgets/dialog_utils.dart';

class PenggelolaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pengelola;

  const PenggelolaDetailScreen({super.key, required this.pengelola});

  @override
  State<PenggelolaDetailScreen> createState() => _PenggelolaDetailScreenState();
}

class _PenggelolaDetailScreenState extends State<PenggelolaDetailScreen> {
  late Map<String, dynamic> pengelola;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pengelola = Map.from(widget.pengelola);
    _loadDetailedUserData();
  }

  Future<void> _loadDetailedUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AdminService.getUserById(pengelola['user_id']);
      if (result['status']) {
        setState(() {
          pengelola = result['data'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading user details: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileSection(),
                            const SizedBox(height: 20),
                            _buildPersonalInfoSection(),
                            const SizedBox(height: 20),
                            _buildAccountStatusSection(),
                            const SizedBox(height: 20),
                            _buildSystemInfoSection(),
                            const SizedBox(height: 30),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pengelola',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Informasi lengkap pengelola kos',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  pengelola['is_approved'] == true
                      ? Colors.green
                      : Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              pengelola['is_approved'] == true ? 'Verified' : 'Pending',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF119DB1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFF119DB1), width: 3),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage:
                  pengelola['avatar'] != null
                      ? NetworkImage(pengelola['avatar'])
                      : null,
              child:
                  pengelola['avatar'] == null
                      ? const Icon(
                        Icons.person,
                        color: Color(0xFF119DB1),
                        size: 40,
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pengelola['full_name'] ?? 'Nama tidak tersedia',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pengelola['email'] ?? 'Email tidak tersedia',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${pengelola['username'] ?? 'username'}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF119DB1),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.badge, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Pengelola Kos',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildInfoSection('Informasi Personal', Icons.person, [
      _buildInfoRow('Nama Lengkap', pengelola['full_name'] ?? 'Tidak tersedia'),
      _buildInfoRow('Email', pengelola['email'] ?? 'Tidak tersedia'),
      _buildInfoRow(
        'Username',
        '@${pengelola['username'] ?? 'Tidak tersedia'}',
      ),
      _buildInfoRow('No. Telepon', pengelola['phone'] ?? 'Tidak tersedia'),
      _buildInfoRow(
        'WhatsApp',
        pengelola['whatsapp_number'] ?? 'Tidak tersedia',
      ),
    ]);
  }

  Widget _buildAccountStatusSection() {
    return _buildInfoSection('Status Akun', Icons.account_circle, [
      _buildInfoRow(
        'Status Approval',
        pengelola['is_approved'] == true ? 'Disetujui' : 'Menunggu Persetujuan',
        valueColor:
            pengelola['is_approved'] == true ? Colors.green : Colors.orange,
      ),
      _buildInfoRow(
        'Email Verified',
        pengelola['email_verified'] == true
            ? 'Terverifikasi'
            : 'Belum Terverifikasi',
        valueColor:
            pengelola['email_verified'] == true ? Colors.green : Colors.red,
      ),
      _buildInfoRow(
        'Tipe Akun',
        pengelola['is_guest'] == true ? 'Guest' : 'Regular',
      ),
      if (pengelola['google_id'] != null)
        _buildInfoRow('Google Account', 'Terhubung', valueColor: Colors.blue),
    ]);
  }

  Widget _buildSystemInfoSection() {
    return _buildInfoSection('Informasi Sistem', Icons.info, [
      _buildInfoRow('User ID', pengelola['user_id'] ?? 'Tidak tersedia'),
      _buildInfoRow('Role', pengelola['role'] ?? 'PENGELOLA'),
      _buildInfoRow('Bergabung', _formatDate(pengelola['created_at'])),
      _buildInfoRow('Diperbarui', _formatDate(pengelola['updated_at'])),
      if (pengelola['last_login'] != null)
        _buildInfoRow(
          'Login Terakhir',
          _formatDateTime(pengelola['last_login']),
          valueColor: Colors.green,
        ),
    ]);
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF119DB1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xFF119DB1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (pengelola['is_approved'] == true) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _deletePengelola,
          icon: const Icon(Icons.delete),
          label: const Text('Hapus Pengelola'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _verifyPengelola,
            icon: const Icon(Icons.check),
            label: const Text('Verifikasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _deletePengelola,
            icon: const Icon(Icons.delete),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  void _verifyPengelola() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Verifikasi Pengelola',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apakah Anda yakin ingin memverifikasi pengelola berikut?',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            pengelola['avatar'] != null
                                ? NetworkImage(pengelola['avatar'])
                                : null,
                        child:
                            pengelola['avatar'] == null
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pengelola['full_name'] ?? 'Nama tidak tersedia',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              pengelola['email'] ?? 'Email tidak tersedia',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Setelah diverifikasi, pengelola dapat mengelola kos dan menggunakan semua fitur aplikasi.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  final currentContext = context;
                  DialogUtils.showLoadingDialog(currentContext, false);

                  try {
                    final result = await AdminService.approveUser(
                      pengelola['user_id'],
                      true,
                    );

                    if (!currentContext.mounted) return;
                    DialogUtils.hideLoadingDialog(currentContext);

                    if (result['status']) {
                      setState(() {
                        pengelola['is_approved'] = true;
                      });

                      if (currentContext.mounted) {
                        ScaffoldMessenger.of(currentContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${pengelola['full_name']} berhasil diverifikasi',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Get.back(result: pengelola);
                      }
                    }
                  } catch (e) {
                    if (currentContext.mounted) {
                      DialogUtils.hideLoadingDialog(currentContext);
                      ScaffoldMessenger.of(
                        currentContext,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Verifikasi'),
              ),
            ],
          ),
    );
  }

  void _deletePengelola() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Hapus Pengelola',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apakah Anda yakin ingin menghapus pengelola berikut?',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            pengelola['avatar'] != null
                                ? NetworkImage(pengelola['avatar'])
                                : null,
                        child:
                            pengelola['avatar'] == null
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pengelola['full_name'] ?? 'Nama tidak tersedia',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              pengelola['email'] ?? 'Email tidak tersedia',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tindakan ini tidak dapat dibatalkan!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.amber[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  final currentContext = context;
                  DialogUtils.showLoadingDialog(currentContext, false);

                  try {
                    final result = await AdminService.deleteUser(
                      pengelola['user_id'],
                    );

                    if (!currentContext.mounted) return;
                    DialogUtils.hideLoadingDialog(currentContext);

                    if (result['status']) {
                      if (currentContext.mounted) {
                        Get.off(
                          () => SuccessDeleteScreen(
                            title: '${pengelola['full_name']} berhasil dihapus',
                            onBack: () => Get.back(result: 'deleted'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (currentContext.mounted) {
                      DialogUtils.hideLoadingDialog(currentContext);
                      ScaffoldMessenger.of(
                        currentContext,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tidak diketahui';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Format tanggal salah';
    }
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'Tidak diketahui';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Format tanggal salah';
    }
  }
}
