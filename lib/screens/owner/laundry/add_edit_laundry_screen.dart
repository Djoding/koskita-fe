// lib/screens/owner/laundry/add_edit_laundry_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class AddEditLaundryScreen extends StatefulWidget {
  const AddEditLaundryScreen({super.key});

  @override
  State<AddEditLaundryScreen> createState() => _AddEditLaundryScreenState();
}

class _AddEditLaundryScreenState extends State<AddEditLaundryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaLaundryController = TextEditingController();
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
  Map<String, dynamic>? laundryData;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    kostData = arguments['kost_data'];
    isEdit = arguments['is_edit'] ?? false;

    if (isEdit) {
      laundryData = arguments['laundry_data'];
      _loadLaundryData();
    }
  }

  void _loadLaundryData() {
    if (laundryData != null) {
      _namaLaundryController.text = laundryData!['nama_laundry'] ?? '';
      _alamatController.text = laundryData!['alamat'] ?? '';
      _whatsappController.text = laundryData!['whatsapp_number'] ?? '';
      isPartner = laundryData!['is_partner'] ?? false;
      existingQrisImageUrl = laundryData!['qris_image_url'];

      if (laundryData!['rekening_info'] != null) {
        final rekeningInfo =
            laundryData!['rekening_info'] as Map<String, dynamic>;
        _bankController.text = rekeningInfo['bank'] ?? '';
        _rekeningController.text = rekeningInfo['nomor'] ?? '';
        _atasNamaController.text = rekeningInfo['atas_nama'] ?? '';
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
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (kostData == null) {
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
      // Prepare form data
      final Map<String, dynamic> formData = {
        'kost_id': kostData!['kost_id'],
        'nama_laundry': _namaLaundryController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'is_partner': isPartner,
      };

      if (_whatsappController.text.trim().isNotEmpty) {
        formData['whatsapp_number'] = _whatsappController.text.trim();
      }

      // Add rekening info if provided
      if (_bankController.text.trim().isNotEmpty ||
          _rekeningController.text.trim().isNotEmpty ||
          _atasNamaController.text.trim().isNotEmpty) {
        formData['rekening_info'] = {
          'bank': _bankController.text.trim(),
          'nomor': _rekeningController.text.trim(),
          'atas_nama': _atasNamaController.text.trim(),
        };
      }

      // Debug print untuk melihat data yang akan dikirim
      print('=== FORM DATA DEBUG ===');
      print('FormData: $formData');
      formData.forEach((key, value) {
        print('$key: $value (${value.runtimeType})');
      });

      final response = await LaundryService.createLaundry(
        formData,
        qrisImageFile,
      );

      if (response['status']) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          isEdit ? 'Laundry berhasil diperbarui' : 'Laundry berhasil ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal menyimpan data laundry',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
                    isEdit ? 'Edit Laundry' : 'Tambah Laundry',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
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
                        'Informasi Laundry',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nama Laundry
                      TextFormField(
                        controller: _namaLaundryController,
                        decoration: InputDecoration(
                          labelText: 'Nama Laundry *',
                          hintText: 'Masukkan nama laundry',
                          prefixIcon: const Icon(Icons.local_laundry_service),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama laundry tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Nama laundry minimal 3 karakter';
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
                          hintText: 'Masukkan alamat laundry',
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
                          labelText: 'WhatsApp',
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
                            const Icon(Icons.verified, color: Colors.blue),
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
                                    'Laundry partner mendapat prioritas',
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
                                    'QRIS',
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
                            ] else if (existingQrisImageUrl != null) ...[
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
                                          Icons.qr_code,
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
                          labelText: 'Bank',
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
                          labelText: 'Nomor Rekening',
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
                          labelText: 'Atas Nama',
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
                                        ? 'Perbarui Laundry'
                                        : 'Tambah Laundry',
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
    _namaLaundryController.dispose();
    _alamatController.dispose();
    _whatsappController.dispose();
    _bankController.dispose();
    _rekeningController.dispose();
    _atasNamaController.dispose();
    super.dispose();
  }
}
