// lib/screens/owner/laundry/add_edit_laundry_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
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
        existingQrisImageUrl = null; // Clear existing if new picked
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
      } else {
        formData['whatsapp_number'] = null; // Send null if empty
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
      } else {
        formData['rekening_info'] = null; // Send null if empty
      }

      // Debug print untuk melihat data yang akan dikirim
      print('=== FORM DATA DEBUG ===');
      print('FormData: $formData');
      formData.forEach((key, value) {
        print('$key: $value (${value.runtimeType})');
      });

      // Call create or update based on isEdit flag
      final response =
          isEdit && laundryData != null
              ? await LaundryService.updateLaundry(
                laundryId: laundryData!['laundry_id'],
                kostId: formData['kost_id'],
                namalaundry: formData['nama_laundry'],
                alamat: formData['alamat'],
                whatsappNumber: formData['whatsapp_number'],
                isPartner: formData['is_partner'],
                rekeningInfo: formData['rekening_info'],
                qrisImage: qrisImageFile,
              )
              : await LaundryService.createLaundry(formData, qrisImageFile);

      if (response['status']) {
        Get.back(result: true);
        Get.snackbar(
          'Success',
          isEdit
              ? 'Laundry berhasil diperbarui'
              : 'Laundry berhasil ditambahkan',
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
                        'Informasi Laundry',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nama Laundry
                      _buildTextField(
                        controller: _namaLaundryController,
                        label: 'Nama Laundry *',
                        hint: 'Masukkan nama laundry',
                        icon: Icons.local_laundry_service,
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
                      _buildTextField(
                        controller: _alamatController,
                        label: 'Alamat *',
                        hint: 'Masukkan alamat laundry',
                        icon: Icons.location_on,
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
                      _buildTextField(
                        controller: _whatsappController,
                        label: 'WhatsApp (Opsional)',
                        hint: 'Contoh: 081234567890',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            // FIX: Escape '+' in regex for literal match
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
                                if (qrisImageFile != null ||
                                    (existingQrisImageUrl != null &&
                                        existingQrisImageUrl!
                                            .isNotEmpty)) // Add clear button if image exists
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        qrisImageFile = null;
                                        existingQrisImageUrl =
                                            ''; // Explicitly set to empty string to signal deletion to backend
                                      });
                                    },
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                            ),
                            if (qrisImageFile != null) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    qrisImageFile!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ] else if (existingQrisImageUrl != null &&
                                existingQrisImageUrl!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    existingQrisImageUrl!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
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
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bank Info
                      _buildTextField(
                        controller: _bankController,
                        label: 'Nama Bank (Opsional)',
                        hint: 'Contoh: BCA, Mandiri, BRI',
                        icon: Icons.account_balance,
                      ),
                      const SizedBox(height: 16),

                      // Nomor Rekening
                      _buildTextField(
                        controller: _rekeningController,
                        label: 'Nomor Rekening (Opsional)',
                        hint: 'Masukkan nomor rekening',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Atas Nama
                      _buildTextField(
                        controller: _atasNamaController,
                        label: 'Nama Pemilik Rekening (Opsional)',
                        hint: 'Nama pemilik rekening',
                        icon: Icons.person,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A99BD), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
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
