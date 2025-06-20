import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kosan_euy/services/api_service.dart';
import 'package:kosan_euy/services/pengelola_service.dart'; // Import ApiService

class EditKosScreen extends StatefulWidget {
  final Map<String, dynamic> kostData;

  const EditKosScreen({super.key, required this.kostData});

  @override
  State<EditKosScreen> createState() => _EditKosScreenState();
}

class _EditKosScreenState extends State<EditKosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final _namaKostController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaBulananController = TextEditingController();
  final _depositController = TextEditingController();
  final _biayaTambahanController = TextEditingController();
  final _totalKamarController = TextEditingController();
  final _dayaListrikController = TextEditingController();
  final _sumberAirController = TextEditingController();
  final _wifiSpeedController = TextEditingController();
  final _jamSurveyController = TextEditingController();
  final _kapasitasParkirMotorController = TextEditingController();
  final _kapasitasParkirMobilController = TextEditingController();

  // State variables
  List<Map<String, dynamic>> tipeKamarList = [];
  String? selectedTipeKamar;
  List<File> newFotoKost = [];
  List<String> existingFotoKost = [];
  File? newFotoQris;
  String? existingFotoQris;
  bool isLoading = false;
  bool isLoadingTipeKamar = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadTipeKamar();
  }

  void _initializeData() {
    final data = widget.kostData;

    _namaKostController.text = data['nama_kost'] ?? '';
    _alamatController.text = data['alamat'] ?? '';
    _deskripsiController.text = data['deskripsi'] ?? '';

    // FIX: Safely parse numbers from dynamic type (could be String or num)
    // before converting to string for TextEditingController.
    _hargaBulananController.text =
        (double.tryParse(data['harga_bulanan']?.toString() ?? '0.0') ?? 0.0)
            .toStringAsFixed(0);
    _depositController
        .text = (double.tryParse(data['deposit']?.toString() ?? '0.0') ?? 0.0)
        .toStringAsFixed(0);
    _biayaTambahanController.text =
        (double.tryParse(data['biaya_tambahan']?.toString() ?? '0.0') ?? 0.0)
            .toStringAsFixed(0);

    _totalKamarController.text = data['total_kamar']?.toString() ?? '';
    _dayaListrikController.text = data['daya_listrik'] ?? '';
    _sumberAirController.text = data['sumber_air'] ?? '';
    _wifiSpeedController.text = data['wifi_speed'] ?? '';
    _jamSurveyController.text = data['jam_survey'] ?? '';
    _kapasitasParkirMotorController.text =
        data['kapasitas_parkir_motor']?.toString() ?? '0';
    _kapasitasParkirMobilController.text =
        data['kapasitas_parkir_mobil']?.toString() ?? '0';

    selectedTipeKamar = data['tipe_id'];

    if (data['foto_kost'] != null) {
      existingFotoKost = List<String>.from(data['foto_kost']);
    }

    // Assign existing Qris image path
    existingFotoQris = data['qris_image'];

    // If you need to display full URL for existing QRIS in Edit screen preview
    // If existingFotoQris is a relative path, construct the full URL here for display
    if (existingFotoQris != null && !existingFotoQris!.startsWith('http')) {
      existingFotoQris =
          '${ApiService.baseUrl.replaceFirst('/api/v1/', '')}${existingFotoQris}';
    }
  }

  Future<void> _loadTipeKamar() async {
    try {
      final response = await PengelolaService.getTipeKamar();
      if (response['status'] && response['data'] != null) {
        setState(() {
          tipeKamarList = List<Map<String, dynamic>>.from(response['data']);
          isLoadingTipeKamar = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingTipeKamar = false;
      });
      Get.snackbar(
        'Error',
        'Gagal memuat data tipe kamar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          newFotoKost = images.map((image) => File(image.path)).toList();
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickQrisImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          newFotoQris = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar QRIS: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      existingFotoKost.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      newFotoKost.removeAt(index);
    });
  }

  Future<void> _updateKost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await PengelolaService.updateKost(
        widget.kostData['kost_id'],
        {
          'nama_kost': _namaKostController.text.trim(),
          'alamat': _alamatController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          'nama_tipe': selectedTipeKamar!,
          'harga_bulanan': double.parse(_hargaBulananController.text),
          'deposit':
              _depositController.text.isNotEmpty
                  ? double.parse(_depositController.text)
                  : null,
          'biaya_tambahan':
              _biayaTambahanController.text.isNotEmpty
                  ? double.parse(_biayaTambahanController.text)
                  : null,
          'total_kamar': int.parse(_totalKamarController.text),
          'daya_listrik': _dayaListrikController.text.trim(),
          'sumber_air': _sumberAirController.text.trim(),
          'wifi_speed': _wifiSpeedController.text.trim(),
          'jam_survey': _jamSurveyController.text.trim(),
          'kapasitas_parkir_motor':
              _kapasitasParkirMotorController.text.isNotEmpty
                  ? int.parse(_kapasitasParkirMotorController.text)
                  : null,
          'kapasitas_parkir_mobil':
              _kapasitasParkirMobilController.text.isNotEmpty
                  ? int.parse(_kapasitasParkirMobilController.text)
                  : null,
        },
        existingFotoKost: existingFotoKost,
        newFotoKost: newFotoKost,
        existingFotoQris: existingFotoQris,
        newFotoQris: newFotoQris,
      );

      if (response['status']) {
        Get.back();
        Get.back(); // Back to detail screen
        Get.snackbar(
          'Sukses',
          'Kost berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal memperbarui kost',
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Edit Kost',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _updateKost,
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isLoading ? Colors.grey : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body:
          isLoadingTipeKamar
              ? Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Informasi Dasar', [
                        _buildTextField(
                          controller: _namaKostController,
                          label: 'Nama Kost',
                          validator:
                              (value) =>
                                  value?.isEmpty == true
                                      ? 'Nama kost harus diisi'
                                      : null,
                        ),
                        _buildTextField(
                          controller: _alamatController,
                          label: 'Alamat',
                          maxLines: 2,
                          validator:
                              (value) =>
                                  value?.isEmpty == true
                                      ? 'Alamat harus diisi'
                                      : null,
                        ),
                        _buildTipeKamarDropdown(),
                        _buildTextField(
                          controller: _deskripsiController,
                          label: 'Deskripsi',
                          maxLines: 3,
                        ),
                      ]),

                      SizedBox(height: 24),

                      _buildSection('Harga & Kapasitas', [
                        _buildTextField(
                          controller: _hargaBulananController,
                          label: 'Harga Bulanan',
                          keyboardType: TextInputType.number,
                          validator:
                              (value) =>
                                  value?.isEmpty == true
                                      ? 'Harga bulanan harus diisi'
                                      : null,
                        ),
                        _buildTextField(
                          controller: _depositController,
                          label: 'Deposit (Opsional)',
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          controller: _biayaTambahanController,
                          label: 'Biaya Tambahan (Opsional)',
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          controller: _totalKamarController,
                          label: 'Total Kamar',
                          keyboardType: TextInputType.number,
                          validator:
                              (value) =>
                                  value?.isEmpty == true
                                      ? 'Total kamar harus diisi'
                                      : null,
                        ),
                      ]),

                      SizedBox(height: 24),

                      _buildSection('Spesifikasi', [
                        _buildTextField(
                          controller: _dayaListrikController,
                          label: 'Daya Listrik (misal: 450W)',
                        ),
                        _buildTextField(
                          controller: _sumberAirController,
                          label: 'Sumber Air (misal: PDAM)',
                        ),
                        _buildTextField(
                          controller: _wifiSpeedController,
                          label: 'Kecepatan WiFi (misal: 50 Mbps)',
                        ),
                        _buildTextField(
                          controller: _jamSurveyController,
                          label: 'Jam Survey (misal: 09:00-17:00)',
                        ),
                        _buildTextField(
                          controller: _kapasitasParkirMotorController,
                          label: 'Kapasitas Parkir Motor',
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          controller: _kapasitasParkirMobilController,
                          label: 'Kapasitas Parkir Mobil',
                          keyboardType: TextInputType.number,
                        ),
                      ]),

                      SizedBox(height: 24),

                      _buildImageSection(),

                      SizedBox(height: 24),

                      _buildQrisSection(),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildTipeKamarDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedTipeKamar,
        decoration: InputDecoration(
          labelText: 'Tipe Kamar',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items:
            tipeKamarList.map((tipe) {
              return DropdownMenuItem<String>(
                value: tipe['tipe_id'],
                child: Text(tipe['nama_tipe'] ?? ''),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            selectedTipeKamar = value;
          });
        },
        validator: (value) => value == null ? 'Tipe kamar harus dipilih' : null,
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Foto Kost',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.add_photo_alternate, size: 18),
                label: Text('Tambah Foto'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Existing images
          if (existingFotoKost.isNotEmpty) ...[
            Text(
              'Foto Existing:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: existingFotoKost.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(existingFotoKost[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
          ],

          // New images
          if (newFotoKost.isNotEmpty) ...[
            Text(
              'Foto Baru:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: newFotoKost.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(newFotoKost[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(index),
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          if (existingFotoKost.isEmpty && newFotoKost.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada foto dipilih',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQrisSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Foto QRIS (Opsional)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _pickQrisImage,
                icon: Icon(Icons.qr_code, size: 18),
                label: Text('Pilih QRIS'),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child:
                newFotoQris != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(newFotoQris!, fit: BoxFit.cover),
                    )
                    : existingFotoQris != null &&
                        existingFotoQris!
                            .isNotEmpty // Check if it's not null and not empty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        existingFotoQris!, // Use the full URL here
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Gagal memuat QRIS',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                    : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Belum ada QRIS dipilih',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaKostController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    _hargaBulananController.dispose();
    _depositController.dispose();
    _biayaTambahanController.dispose();
    _totalKamarController.dispose();
    _dayaListrikController.dispose();
    _sumberAirController.dispose();
    _wifiSpeedController.dispose();
    _jamSurveyController.dispose();
    _kapasitasParkirMotorController.dispose();
    _kapasitasParkirMobilController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
