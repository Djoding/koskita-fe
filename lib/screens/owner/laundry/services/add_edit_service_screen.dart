// lib/screens/owner/laundry/services/add_edit_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({super.key});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaLayananController = TextEditingController();
  final _satuanController = TextEditingController();
  final _hargaController = TextEditingController();

  bool isEdit = false;
  bool isAvailable = true;
  bool isLoading = false;

  Map<String, dynamic>? laundryData;
  Map<String, dynamic>? serviceData;
  List<dynamic> availableLayanan = [];

  // PERBAIKAN: Ubah tipe data menjadi String untuk konsistensi dengan API
  String? selectedLayananId;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    laundryData = arguments['laundry_data'];
    isEdit = arguments['is_edit'] ?? false;

    if (isEdit) {
      serviceData = arguments['service_data'];
      _loadServiceData();
    }

    _loadAvailableLayanan();
  }

  void _loadServiceData() {
    if (serviceData != null) {
      final layanan = serviceData!['layanan'] as Map<String, dynamic>;
      // PERBAIKAN: Konversi ke String untuk konsistensi
      selectedLayananId = layanan['layanan_id']?.toString();
      _namaLayananController.text = layanan['nama_layanan'] ?? '';
      _satuanController.text = layanan['satuan'] ?? '';
      _hargaController.text =
          serviceData!['harga_per_satuan']?.toString() ?? '';
      isAvailable = serviceData!['is_available'] ?? true;
    }
  }

  Future<void> _loadAvailableLayanan() async {
    try {
      final response = await LaundryService.getAvailableLayanan();

      if (response['status']) {
        setState(() {
          availableLayanan = response['data'] as List? ?? [];
        });
      } else {
        // PERBAIKAN: Tampilkan error jika gagal load data
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal memuat data layanan',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data layanan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (laundryData == null) {
      Get.snackbar(
        'Error',
        'Data laundry tidak ditemukan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> formData = {
        'harga_per_satuan': double.parse(_hargaController.text.trim()),
        'is_available': isAvailable,
      };

      if (isEdit) {
        // Update existing service
        if (serviceData == null) {
          throw Exception('Data layanan tidak ditemukan');
        }

        final layanan = serviceData!['layanan'] as Map<String, dynamic>;

        final response = await LaundryService.updateLaundryService(
          laundryData!['laundry_id'].toString(),
          layanan['layanan_id'].toString(),
          formData,
        );

        if (response['status']) {
          Get.back(result: true);
          Get.snackbar(
            'Success',
            'Layanan berhasil diperbarui',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(response['message'] ?? 'Gagal memperbarui layanan');
        }
      } else {
        // Create new service
        if (selectedLayananId == null) {
          Get.snackbar(
            'Error',
            'Pilih jenis layanan terlebih dahulu',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // PERBAIKAN: Pastikan layanan_id dikirim sebagai integer
        formData['layanan_id'] = selectedLayananId!;

        final response = await LaundryService.createLaundryService(
          laundryData!['laundry_id'].toString(),
          formData,
        );

        if (response['status']) {
          Get.back(result: true);
          Get.snackbar(
            'Success',
            'Layanan berhasil ditambahkan',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw Exception(response['message'] ?? 'Gagal menambahkan layanan');
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
                    isEdit ? 'Edit Layanan' : 'Tambah Layanan',
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
                        'Informasi Layanan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Jenis Layanan (Dropdown for new, readonly for edit)
                      if (isEdit) ...[
                        _buildTextField(
                          controller: _namaLayananController,
                          label: 'Jenis Layanan',
                          icon: Icons.cleaning_services,
                          readOnly: true,
                        ),
                      ] else ...[
                        // PERBAIKAN: Ubah tipe dropdown menjadi String
                        DropdownButtonFormField<String>(
                          value: selectedLayananId,
                          decoration: InputDecoration(
                            labelText: 'Jenis Layanan *',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.cleaning_services,
                              color: Colors.grey,
                            ),
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
                              borderSide: const BorderSide(
                                color: Color(0xFF4A99BD),
                                width: 2.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items:
                              availableLayanan.map((layanan) {
                                return DropdownMenuItem<String>(
                                  // PERBAIKAN: Konversi ke String
                                  value: layanan['layanan_id']?.toString(),
                                  child: Text(
                                    layanan['nama_layanan'] ?? '',
                                    style: GoogleFonts.poppins(),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedLayananId = value;
                              // Auto-fill data if available
                              final selectedLayanan = availableLayanan
                                  .firstWhere(
                                    (layanan) =>
                                        layanan['layanan_id']?.toString() ==
                                        value,
                                    orElse: () => null,
                                  );
                              if (selectedLayanan != null) {
                                _namaLayananController.text =
                                    selectedLayanan['nama_layanan'] ?? '';
                                _satuanController.text =
                                    selectedLayanan['satuan'] ?? '';
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih jenis layanan';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Satuan (readonly)
                      _buildTextField(
                        controller: _satuanController,
                        label: 'Satuan',
                        icon: Icons.straighten,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Harga per Satuan
                      _buildTextField(
                        controller: _hargaController,
                        label: 'Harga per Satuan *',
                        hint: 'Masukkan harga dalam rupiah',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          final price = double.tryParse(value.trim());
                          if (price == null || price <= 0) {
                            return 'Harga harus berupa angka positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Status Ketersediaan
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.cancel,
                              color: isAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Layanan',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    isAvailable
                                        ? 'Layanan aktif dan dapat dipesan'
                                        : 'Layanan nonaktif dan tidak dapat dipesan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  isAvailable = value;
                                });
                              },
                            ),
                          ],
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
                                        ? 'Perbarui Layanan'
                                        : 'Tambah Layanan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TAMBAHAN: Debug info untuk development (hapus nanti)
                      if (availableLayanan.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Text(
                            'Tidak ada data layanan tersedia. Pastikan API endpoint benar.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
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

  // NEW: Helper _buildTextField to reuse styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
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
    _namaLayananController.dispose();
    _satuanController.dispose();
    _hargaController.dispose();
    super.dispose();
  }
}
