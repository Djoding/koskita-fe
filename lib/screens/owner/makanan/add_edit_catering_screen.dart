// lib/screens/owner/makanan/add_edit_catering_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/catering_menu_service.dart';
import 'package:kosan_euy/models/catering_model.dart'; // Import Catering model

class AddEditCateringScreen extends StatefulWidget {
  const AddEditCateringScreen({super.key});

  @override
  State<AddEditCateringScreen> createState() => _AddEditCateringScreenState();
}

class _AddEditCateringScreenState extends State<AddEditCateringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCateringController = TextEditingController();
  final _alamatController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _bankController = TextEditingController();
  final _rekeningController = TextEditingController();
  final _atasNamaController = TextEditingController();

  bool isEdit = false;
  bool isPartner = false;
  bool isLoading = false;
  File? qrisImageFile;
  String? existingQrisImageUrl;

  Map<String, dynamic>? kostData;
  Catering? cateringData; // Use Catering model for data

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      kostData = arguments['kost_data'];
      isEdit = arguments['is_edit'] ?? false;

      if (isEdit) {
        cateringData = arguments['catering_data'] as Catering?;
        _loadCateringData();
      }
    } else {
      // Handle missing arguments if necessary, though it should be passed
      Get.snackbar('Error', 'Missing arguments for AddEditCateringScreen');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }
  }

  void _loadCateringData() {
    if (cateringData != null) {
      _namaCateringController.text = cateringData!.namaCatering;
      _alamatController.text = cateringData!.alamat;
      _whatsappController.text = cateringData!.whatsappNumber ?? '';
      isPartner = cateringData!.isPartner;
      existingQrisImageUrl =
          cateringData!.qrisImageUrl; // Use qrisImageUrl from model

      if (cateringData!.rekeningInfo != null) {
        final rekeningInfo = cateringData!.rekeningInfo!;
        _bankController.text = rekeningInfo['bank'] ?? '';
        _rekeningController.text = rekeningInfo['nomor'] ?? '';
        _atasNamaController.text =
            rekeningInfo['nama'] ?? ''; // 'nama' for catering, not 'atas_nama'
      }
    }
  }

  Future<void> _pickQrisImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        qrisImageFile = File(image.path);
        existingQrisImageUrl =
            null; // Clear existing image if new one is picked
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (kostData == null || kostData!['kost_id'] == null) {
      Get.snackbar(
        'Error',
        'Data kost tidak ditemukan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> rekeningInfo = {};
      if (_bankController.text.trim().isNotEmpty) {
        rekeningInfo['bank'] = _bankController.text.trim();
      }
      if (_rekeningController.text.trim().isNotEmpty) {
        rekeningInfo['nomor'] = _rekeningController.text.trim();
      }
      if (_atasNamaController.text.trim().isNotEmpty) {
        rekeningInfo['nama'] =
            _atasNamaController.text.trim(); // 'nama' for catering
      }

      // Check if rekeningInfo is empty, set to null if so
      final Map<String, dynamic>? finalRekeningInfo =
          rekeningInfo.isNotEmpty ? rekeningInfo : null;

      if (isEdit && cateringData != null) {
        // Update existing catering
        final response = await CateringMenuService.updateCatering(
          cateringId: cateringData!.cateringId,
          kostId: kostData!['kost_id'],
          namaCatering: _namaCateringController.text.trim(),
          alamat: _alamatController.text.trim(),
          whatsappNumber:
              _whatsappController.text.trim().isEmpty
                  ? null
                  : _whatsappController.text.trim(),
          qrisImage: qrisImageFile,
          rekeningInfo: finalRekeningInfo,
          isPartner: isPartner,
          existingQrisImageUrl:
              existingQrisImageUrl, // Pass existing URL for comparison
        );

        if (response['status']) {
          Get.back(result: true);
          Get.snackbar(
            'Success',
            response['message'] ?? 'Catering berhasil diperbarui',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(response['message'] ?? 'Gagal memperbarui catering');
        }
      } else {
        // Create new catering
        final response = await CateringMenuService.createCatering(
          kostId: kostData!['kost_id'],
          namaCatering: _namaCateringController.text.trim(),
          alamat: _alamatController.text.trim(),
          whatsappNumber:
              _whatsappController.text.trim().isEmpty
                  ? null
                  : _whatsappController.text.trim(),
          qrisImage: qrisImageFile,
          rekeningInfo: finalRekeningInfo,
          isPartner: isPartner,
        );

        if (response['status']) {
          Get.back(result: true);
          Get.snackbar(
            'Success',
            response['message'] ?? 'Catering berhasil ditambahkan',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(response['message'] ?? 'Gagal menambahkan catering');
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
                    isEdit ? 'Edit Catering' : 'Tambah Catering',
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
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Informasi Catering',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nama Catering
                      TextFormField(
                        controller: _namaCateringController,
                        decoration: InputDecoration(
                          labelText: 'Nama Catering *',
                          hintText: 'Masukkan nama catering',
                          prefixIcon: const Icon(Icons.restaurant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama catering tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama catering minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Alamat
                      TextFormField(
                        controller: _alamatController,
                        decoration: InputDecoration(
                          labelText: 'Alamat *',
                          hintText: 'Masukkan alamat catering',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat tidak boleh kosong';
                          }
                          if (value.trim().length < 10) {
                            return 'Alamat minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // WhatsApp
                      TextFormField(
                        controller: _whatsappController,
                        decoration: InputDecoration(
                          labelText: 'WhatsApp (Opsional)',
                          hintText: 'Contoh: 081234567890',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(
                              r'^(\+62|0)[0-9]{8,13}$',
                            ).hasMatch(value.trim())) {
                              return 'Format WhatsApp tidak valid';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Status Partner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Partner',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Catering partner mendapat prioritas',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isPartner,
                              onChanged: (value) {
                                setState(() {
                                  isPartner = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Informasi Pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // QRIS Image
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.qr_code, color: Colors.blue),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'QRIS (Opsional)',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _pickQrisImage,
                                  child: Text(
                                    qrisImageFile != null ||
                                            existingQrisImageUrl != null
                                        ? 'Ubah'
                                        : 'Upload',
                                  ),
                                ),
                              ],
                            ),
                            if (qrisImageFile != null) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  qrisImageFile!,
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ] else if (existingQrisImageUrl != null &&
                                existingQrisImageUrl!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  existingQrisImageUrl!,
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 150,
                                        width: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bank Info
                      TextFormField(
                        controller: _bankController,
                        decoration: InputDecoration(
                          labelText: 'Nama Bank (Opsional)',
                          hintText: 'Contoh: BCA, Mandiri, BRI',
                          prefixIcon: const Icon(Icons.account_balance),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nomor Rekening
                      TextFormField(
                        controller: _rekeningController,
                        decoration: InputDecoration(
                          labelText: 'Nomor Rekening (Opsional)',
                          hintText: 'Masukkan nomor rekening',
                          prefixIcon: const Icon(Icons.credit_card),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Atas Nama
                      TextFormField(
                        controller: _atasNamaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Pemilik Rekening (Opsional)',
                          hintText: 'Nama pemilik rekening',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9EBFED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    isEdit
                                        ? 'Perbarui Catering'
                                        : 'Tambah Catering',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaCateringController.dispose();
    _alamatController.dispose();
    _whatsappController.dispose();
    _bankController.dispose();
    _rekeningController.dispose();
    _atasNamaController.dispose();
    super.dispose();
  }
}
