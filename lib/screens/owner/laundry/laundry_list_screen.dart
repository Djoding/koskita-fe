// lib/screens/owner/laundry/laundry_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/laundry/add_edit_laundry_screen.dart';
import 'package:kosan_euy/screens/owner/laundry/laundry_detail_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class LaundryListScreen extends StatefulWidget {
  const LaundryListScreen({super.key});

  @override
  State<LaundryListScreen> createState() => _LaundryListScreenState();
}

class _LaundryListScreenState extends State<LaundryListScreen> {
  Map<String, dynamic>? kostData;
  List<dynamic> laundries = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    kostData = Get.arguments;
    _loadLaundries();
  }

  Future<void> _loadLaundries() async {
    if (kostData == null) {
      setState(() {
        errorMessage = 'Data kost tidak ditemukan';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await LaundryService.getLaundriesByKost(
        kostData!['kost_id'],
      );

      if (response['status']) {
        setState(() {
          laundries = response['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat data laundry';
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

  void _showDeleteConfirmation(dynamic laundry) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Laundry',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${laundry['nama_laundry']}?',
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
              _deleteLaundry(laundry);
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

  Future<void> _deleteLaundry(dynamic laundry) async {
    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await LaundryService.deleteLaundry(
        laundry['laundry_id'],
      );

      // Close loading dialog
      Get.back();

      if (response['status']) {
        Get.snackbar(
          'Berhasil',
          response['message'] ?? 'Laundry berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        _loadLaundries(); // Refresh the list
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal menghapus laundry',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                    'Daftar Laundry',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: _loadLaundries, // Call refresh logic
                    ),
                  ),
                  const SizedBox(width: 8), // Spacer between refresh and add
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
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () async {
                        final result = await Get.to(
                          () => const AddEditLaundryScreen(),
                          arguments: {'kost_data': kostData, 'is_edit': false},
                        );
                        if (result == true) {
                          _loadLaundries();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLaundries,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLaundries,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF9EBFED),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (laundries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_laundry_service_outlined,
              size: 80,
              color: Colors.white60,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada laundry yang terdaftar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan laundry pertama untuk mulai menerima pesanan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Get.to(
                  () => const AddEditLaundryScreen(),
                  arguments: {'kost_data': kostData, 'is_edit': false},
                );
                if (result == true) {
                  _loadLaundries();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF9EBFED),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Laundry'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: laundries.length,
      itemBuilder: (context, index) {
        final laundry = laundries[index];
        return _buildLaundryCard(laundry);
      },
    );
  }

  Widget _buildLaundryCard(dynamic laundry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap:
            () => Get.to(
              () => const LaundryDetailScreen(),
              arguments: {'laundry_data': laundry, 'kost_data': kostData},
            ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.local_laundry_service,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laundry['nama_laundry'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                laundry['alamat'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Get.to(
                          () => const AddEditLaundryScreen(),
                          arguments: {
                            'kost_data': kostData,
                            'laundry_data': laundry,
                            'is_edit': true,
                          },
                        );
                        if (result == true) {
                          _loadLaundries(); // Refresh after edit
                        }
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(laundry);
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Text('Hapus', style: GoogleFonts.poppins()),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Info cards
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.phone,
                      laundry['whatsapp_number'] ?? 'Tidak ada',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      laundry['is_partner'] == true
                          ? Icons.verified
                          : Icons.store,
                      laundry['is_partner'] == true ? 'Partner' : 'Non-Partner',
                      laundry['is_partner'] == true
                          ? Colors.blue
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Services count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cleaning_services,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${laundry['services_count'] ?? 0} layanan tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
