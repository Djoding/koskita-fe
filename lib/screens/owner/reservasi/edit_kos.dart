// lib/screens/owner/reservasi/edit_kos.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kosan_euy/services/api_service.dart';
import 'package:kosan_euy/services/pengelola_service.dart';
import 'package:uploadthing/uploadthing.dart';

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

  // Rekening controllers
  final _bankController = TextEditingController();
  final _nomorRekeningController = TextEditingController();
  final _namaPemilikController = TextEditingController();

  // State variables
  List<Map<String, dynamic>> tipeKamarList = [];
  List<Map<String, dynamic>> fasilitasList = [];
  List<Map<String, dynamic>> peraturanList = [];
  String? selectedTipeKamar;
  Set<String> selectedFasilitas = {};
  List<Map<String, dynamic>> selectedPeraturan = [];
  
  List<File> newFotoKost = [];
  List<String> existingFotoKost = [];
  File? newFotoQris;
  String? existingFotoQris;
  bool isLoading = false;
  bool isLoadingMasterData = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadMasterData();
  }

  void _initializeData() {
    final data = widget.kostData;

    _namaKostController.text = data['nama_kost'] ?? '';
    _alamatController.text = data['alamat'] ?? '';
    _deskripsiController.text = data['deskripsi'] ?? '';

    // Parse numbers safely
    _hargaBulananController.text = _formatNumberForDisplay(data['harga_bulanan']);
    _depositController.text = _formatNumberForDisplay(data['deposit']);
    _biayaTambahanController.text = _formatNumberForDisplay(data['biaya_tambahan']);
    
    _totalKamarController.text = data['total_kamar']?.toString() ?? '';
    _dayaListrikController.text = data['daya_listrik'] ?? '';
    _sumberAirController.text = data['sumber_air'] ?? '';
    _wifiSpeedController.text = data['wifi_speed'] ?? '';
    _jamSurveyController.text = data['jam_survey'] ?? '';
    _kapasitasParkirMotorController.text = data['kapasitas_parkir_motor']?.toString() ?? '0';
    _kapasitasParkirMobilController.text = data['kapasitas_parkir_mobil']?.toString() ?? '0';

    selectedTipeKamar = data['tipe_id'];

    // Handle foto_kost
    if (data['foto_kost'] != null) {
      existingFotoKost = List<String>.from(data['foto_kost']);
    }

    // Handle qris_image
    existingFotoQris = data['qris_image'];

    // Handle rekening_info
    if (data['rekening_info'] != null) {
      final rekeningInfo = data['rekening_info'];
      _bankController.text = rekeningInfo['bank'] ?? '';
      _nomorRekeningController.text = rekeningInfo['nomor'] ?? '';
      _namaPemilikController.text = rekeningInfo['nama'] ?? '';
    }

    // Handle selected fasilitas
    if (data['kost_fasilitas'] != null) {
      selectedFasilitas = (data['kost_fasilitas'] as List)
          .map((f) => f['fasilitas']['fasilitas_id'] as String)
          .toSet();
    }

    // Handle selected peraturan
    if (data['kost_peraturan'] != null) {
      selectedPeraturan = (data['kost_peraturan'] as List)
          .map((p) => {
                'peraturan_id': p['peraturan']['peraturan_id'],
                'keterangan_tambahan': p['keterangan_tambahan'] ?? '',
              })
          .toList();
    }
  }

  String _formatNumberForDisplay(dynamic value) {
    if (value == null) return '';
    double parsed = double.tryParse(value.toString()) ?? 0.0;
    if (parsed == 0.0) return '';
    return parsed.toStringAsFixed(0);
  }

  Future<void> _loadMasterData() async {
    setState(() {
      isLoadingMasterData = true;
    });

    try {
      final responses = await Future.wait([
        PengelolaService.getTipeKamar(),
        PengelolaService.getFasilitas(),
        PengelolaService.getPeraturan(),
      ]);

      setState(() {
        if (responses[0]['status']) {
          tipeKamarList = List<Map<String, dynamic>>.from(responses[0]['data']);
        }
        if (responses[1]['status']) {
          fasilitasList = List<Map<String, dynamic>>.from(responses[1]['data']);
        }
        if (responses[2]['status']) {
          peraturanList = List<Map<String, dynamic>>.from(responses[2]['data']);
        }
        isLoadingMasterData = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMasterData = false;
      });
      Get.snackbar(
        'Error',
        'Gagal memuat data master: $e',
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
      // Upload new images if any
      List<String> finalFotoKost = List.from(existingFotoKost);
      String? finalQrisImage = existingFotoQris;

      if (newFotoKost.isNotEmpty || newFotoQris != null) {
        final uploadThing = UploadThing(
          "sk_live_08e0250b1aab76a8067be159691359dfb45a15f5fb0906fbacf6859866f1e199",
        );

        // Upload new kost photos
        if (newFotoKost.isNotEmpty) {
          var uploadSuccess = await uploadThing.uploadFiles(newFotoKost);
          if (uploadSuccess) {
            for (var fileData in uploadThing.uploadedFilesData) {
              if (fileData["url"] != null) {
                finalFotoKost.add(fileData["url"]);
              }
            }
          }
        }

        // Upload new QRIS image
        if (newFotoQris != null) {
          var uploadSuccess = await uploadThing.uploadFiles([newFotoQris!]);
          if (uploadSuccess && uploadThing.uploadedFilesData.isNotEmpty) {
            finalQrisImage = uploadThing.uploadedFilesData.first["url"];
          }
        }
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'nama_kost': _namaKostController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'deskripsi': _deskripsiController.text.trim().isEmpty 
            ? null 
            : _deskripsiController.text.trim(),
        'tipe_id': selectedTipeKamar!,
        'harga_bulanan': double.parse(_hargaBulananController.text),
        'deposit': _depositController.text.isNotEmpty 
            ? double.parse(_depositController.text) 
            : null,
        'biaya_tambahan': _biayaTambahanController.text.isNotEmpty 
            ? double.parse(_biayaTambahanController.text) 
            : null,
        'harga_final': _calculateHargaFinal(),
        'total_kamar': int.parse(_totalKamarController.text),
        'daya_listrik': _dayaListrikController.text.trim().isEmpty 
            ? null 
            : _dayaListrikController.text.trim(),
        'sumber_air': _sumberAirController.text.trim().isEmpty 
            ? null 
            : _sumberAirController.text.trim(),
        'wifi_speed': _wifiSpeedController.text.trim().isEmpty 
            ? null 
            : _wifiSpeedController.text.trim(),
        'jam_survey': _jamSurveyController.text.trim().isEmpty 
            ? null 
            : _jamSurveyController.text.trim(),
        'kapasitas_parkir_motor': int.parse(_kapasitasParkirMotorController.text),
        'kapasitas_parkir_mobil': int.parse(_kapasitasParkirMobilController.text),
        'foto_kost': finalFotoKost,
        'qris_image': finalQrisImage,
        'rekening_info': _buildRekeningInfo(),
        'fasilitas_ids': selectedFasilitas.toList(),
        'peraturan_data': selectedPeraturan,
      };

      final response = await PengelolaService.updateKost(
        widget.kostData['kost_id'],
        updateData,
      );

      if (response['status']) {
        Get.back(result: true); // Back to detail screen with refresh indicator
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

  double _calculateHargaFinal() {
    final hargaBulanan = double.tryParse(_hargaBulananController.text) ?? 0;
    final biayaTambahan = double.tryParse(_biayaTambahanController.text) ?? 0;
    return hargaBulanan + biayaTambahan;
  }

  Map<String, dynamic>? _buildRekeningInfo() {
    if (_bankController.text.trim().isEmpty &&
        _nomorRekeningController.text.trim().isEmpty &&
        _namaPemilikController.text.trim().isEmpty) {
      return null;
    }

    return {
      'bank': _bankController.text.trim(),
      'nomor': _nomorRekeningController.text.trim(),
      'nama': _namaPemilikController.text.trim(),
    };
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
        iconTheme: const IconThemeData(color: Colors.black87),
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
      body: isLoadingMasterData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Informasi Dasar', [
                      _buildTextField(
                        controller: _namaKostController,
                        label: 'Nama Kost',
                        validator: (value) =>
                            value?.isEmpty == true ? 'Nama kost harus diisi' : null,
                      ),
                      _buildTextField(
                        controller: _alamatController,
                        label: 'Alamat',
                        maxLines: 2,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Alamat harus diisi' : null,
                      ),
                      _buildTipeKamarDropdown(),
                      _buildTextField(
                        controller: _deskripsiController,
                        label: 'Deskripsi',
                        maxLines: 3,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _buildSection('Harga & Kapasitas', [
                      _buildTextField(
                        controller: _hargaBulananController,
                        label: 'Harga Bulanan',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Harga bulanan harus diisi' : null,
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
                        validator: (value) =>
                            value?.isEmpty == true ? 'Total kamar harus diisi' : null,
                      ),
                    ]),

                    const SizedBox(height: 24),

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

                    const SizedBox(height: 24),

                    _buildSection('Rekening Bank', [
                      _buildTextField(
                        controller: _bankController,
                        label: 'Nama Bank (misal: BCA)',
                      ),
                      _buildTextField(
                        controller: _nomorRekeningController,
                        label: 'Nomor Rekening',
                      ),
                      _buildTextField(
                        controller: _namaPemilikController,
                        label: 'Nama Pemilik Rekening',
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _buildFasilitasSection(),

                    const SizedBox(height: 24),

                    _buildPeraturanSection(),

                    const SizedBox(height: 24),

                    _buildImageSection(),

                    const SizedBox(height: 24),

                    _buildQrisSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(bottom: 16),
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
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildTipeKamarDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: tipeKamarList.map((tipe) {
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

  Widget _buildFasilitasSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Fasilitas',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fasilitasList.map((fasilitas) {
              final isSelected = selectedFasilitas.contains(fasilitas['fasilitas_id']);
              return FilterChip(
                label: Text(fasilitas['nama_fasilitas']),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedFasilitas.add(fasilitas['fasilitas_id']);
                    } else {
                      selectedFasilitas.remove(fasilitas['fasilitas_id']);
                    }
                  });
                },
                selectedColor: Colors.green.withOpacity(0.3),
                checkmarkColor: Colors.green,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeraturanSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Peraturan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...peraturanList.map((peraturan) {
            final existingPeraturan = selectedPeraturan.firstWhere(
              (p) => p['peraturan_id'] == peraturan['peraturan_id'],
              orElse: () => {},
            );
            final isSelected = existingPeraturan.isNotEmpty;
            final keteranganController = TextEditingController(
              text: existingPeraturan['keterangan_tambahan'] ?? '',
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text(peraturan['nama_peraturan']),
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          selectedPeraturan.add({
                            'peraturan_id': peraturan['peraturan_id'],
                            'keterangan_tambahan': '',
                          });
                        } else {
                          selectedPeraturan.removeWhere(
                            (p) => p['peraturan_id'] == peraturan['peraturan_id'],
                          );
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: keteranganController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan Tambahan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        final index = selectedPeraturan.indexWhere(
                          (p) => p['peraturan_id'] == peraturan['peraturan_id'],
                        );
                        if (index != -1) {
                          selectedPeraturan[index]['keterangan_tambahan'] = value;
                        }
                      },
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Tambah Foto'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          existingFotoKost[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          newFotoKost[index],
                          width: double.infinity,
                          height: double.infinity,
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
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada foto',
                      style: TextStyle(color: Colors.grey),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QRIS Payment',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _pickQrisImage,
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('Upload QRIS'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (newFotoQris != null) ...[
            Text(
              'QRIS Baru:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(newFotoQris!, fit: BoxFit.contain),
              ),
            ),
          ] else if (existingFotoQris != null) ...[
            Text(
              'QRIS Saat Ini:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  existingFotoQris!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.error, size: 40)),
                    );
                  },
                ),
              ),
            ),
          ] else ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada QRIS',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    _bankController.dispose();
    _nomorRekeningController.dispose();
    _namaPemilikController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
