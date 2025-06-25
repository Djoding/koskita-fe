// lib/screens/owner/makanan/catering_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/catering_menu_service.dart';
import 'package:kosan_euy/models/catering_model.dart'; // Import Catering model
import 'package:kosan_euy/routes/app_pages.dart'; // Import Routes
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/makanan_screen.dart'; // Import FoodListScreen
import 'package:kosan_euy/screens/owner/makanan/cek_pesanan/owner_cek_pesanan.dart'; // Import OwnerCekPesanan

class CateringDetailScreen extends StatefulWidget {
  const CateringDetailScreen({super.key});

  @override
  State<CateringDetailScreen> createState() => _CateringDetailScreenState();
}

class _CateringDetailScreenState extends State<CateringDetailScreen> {
  Catering? cateringData;
  Map<String, dynamic>? kostData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      cateringData = arguments['catering_data'] as Catering?;
      kostData = arguments['kost_data'] as Map<String, dynamic>?;
      _loadCateringDetail();
    } else {
      Get.snackbar('Error', 'Data catering tidak ditemukan.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }
  }

  Future<void> _loadCateringDetail() async {
    if (cateringData == null || cateringData!.cateringId.isEmpty) {
      setState(() {
        errorMessage = 'ID Catering tidak ditemukan.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Fetch the full catering data to ensure it's up-to-date,
      // especially 'menu_count' and image URLs if they were updated.
      // NOTE: Assuming a service method to get single catering by ID exists or can be created.
      // For now, we'll re-use getCateringsByKost and filter, or directly use the passed data.
      // A more robust solution would be a `getCateringById(cateringId)` method.

      final response = await CateringMenuService.getCateringsByKost(
        kostData!['kost_id'],
      );

      if (response['status'] == true && response['data'] is List<Catering>) {
        final List<Catering> updatedCaterings = response['data'];
        final Catering? foundCatering = updatedCaterings.firstWhereOrNull(
          (c) => c.cateringId == cateringData!.cateringId,
        );

        if (foundCatering != null) {
          setState(() {
            cateringData =
                foundCatering; // Update local cateringData with fresh data
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Catering tidak ditemukan setelah refresh.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat detail catering.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(Catering catering) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Catering',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${catering.namaCatering}? Ini akan menghapus semua menu terkait.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // No delete API for catering directly, show info.
              // If there was a soft delete, it would be called here.
              Get.snackbar(
                'Info',
                'Fitur hapus catering belum tersedia',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF9EBFED),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (errorMessage.isNotEmpty || cateringData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF9EBFED),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage.isNotEmpty
                            ? errorMessage
                            : 'Data catering tidak tersedia.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCateringDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF9EBFED),
                        ),
                        child: const Text('Coba Lagi'),
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

    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildCateringInfo(),
              const SizedBox(height: 24),
              _buildPaymentInfo(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          const Spacer(),
          Text(
            'Detail Catering',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black, size: 20),
              onPressed: _loadCateringDetail,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
                size: 20, // Ubah dari 28 ke 20 untuk konsistensi
              ),
              onPressed: () => Get.to(() => SettingScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCateringInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cateringData!.namaCatering,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            cateringData!.isPartner
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cateringData!.isPartner ? 'Partner' : 'Non-Partner',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              cateringData!.isPartner
                                  ? Colors.blue
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoRow(Icons.location_on, 'Alamat', cateringData!.alamat),

          if (cateringData!.whatsappNumber != null &&
              cateringData!.whatsappNumber!.isNotEmpty)
            _buildInfoRow(
              Icons.phone,
              'WhatsApp',
              cateringData!.whatsappNumber!,
            ),

          _buildInfoRow(
            Icons.access_time,
            'Dibuat',
            _formatDateTime(cateringData!.createdAt),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Menu:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${cateringData!.menuCount} menu',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // QRIS
          if (cateringData!.qrisImageUrl != null &&
              cateringData!.qrisImageUrl!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.blue),
                const SizedBox(width: 12),
                Text('QRIS tersedia', style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  cateringData!.qrisImageUrl!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.qr_code, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Text(
                  'QRIS belum tersedia',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],

          // Rekening Info
          if (cateringData!.rekeningInfo != null &&
              cateringData!.rekeningInfo!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ...() {
              final rekeningInfo = cateringData!.rekeningInfo!;
              return [
                if (rekeningInfo['bank'] != null &&
                    rekeningInfo['bank'].isNotEmpty)
                  _buildInfoRow(
                    Icons.account_balance,
                    'Bank',
                    rekeningInfo['bank'],
                  ),

                if (rekeningInfo['nomor'] != null &&
                    rekeningInfo['nomor'].isNotEmpty)
                  _buildInfoRow(
                    Icons.credit_card,
                    'Nomor Rekening',
                    rekeningInfo['nomor'],
                  ),

                if (rekeningInfo['nama'] != null &&
                    rekeningInfo['nama'].isNotEmpty)
                  _buildInfoRow(
                    Icons.person,
                    'Atas Nama',
                    rekeningInfo['nama'],
                  ),
              ];
            }(),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Get.toNamed(
                  Routes.addEditCatering,
                  arguments: {
                    'kost_data': kostData,
                    'catering_data': cateringData,
                    'is_edit': true,
                  },
                );
                if (result == true) {
                  _loadCateringDetail();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9EBFED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: Text(
                'Edit Informasi Catering',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  () => Get.toNamed(
                    Routes.foodListScreen,
                    arguments: {'cateringId': cateringData!.cateringId},
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.menu_book, color: Colors.white),
              label: Text(
                'Kelola Daftar Menu',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  () => Get.to(
                    () => const OwnerCekPesanan(),
                    arguments: {
                      'kost_data': kostData,
                      'catering_filter': cateringData!.cateringId,
                    },
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.list_alt, color: Colors.white),
              label: Text(
                'Lihat Pesanan Catering',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
