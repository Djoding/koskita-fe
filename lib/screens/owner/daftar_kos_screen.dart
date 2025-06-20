import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosan_euy/services/pengelola_service.dart';
import 'dart:io';
import 'package:kosan_euy/widgets/success_screen.dart';
import 'package:uploadthing/uploadthing.dart';

class DaftarKosScreen extends StatefulWidget {
  const DaftarKosScreen({super.key});

  @override
  State<DaftarKosScreen> createState() => _DaftarKosScreenState();
}

class _DaftarKosScreenState extends State<DaftarKosScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _imageFiles = [];
  final List<XFile> _qrisFiles = [];
  List<String> _uploadedImageUrls = [];
  String? _uploadedQrisUrl;
  bool _isSubmitting = false;

  // Form controllers
  final TextEditingController _namaKostController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _totalKamarController = TextEditingController();
  final TextEditingController _gmapsLinkController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _kapasitasParkirMotorController =
      TextEditingController(text: '0');
  final TextEditingController _kapasitasParkirMobilController =
      TextEditingController(text: '0');
  final TextEditingController _biayaTambahanController = TextEditingController(
    text: '0',
  );
  final TextEditingController _dayaListrikController = TextEditingController();
  final TextEditingController _sumberAirController = TextEditingController();
  final TextEditingController _wifiSpeedController = TextEditingController();
  final TextEditingController _jamSurveyController = TextEditingController();
  final TextEditingController _hargaBulananController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _hargaFinalController = TextEditingController();

  // Rekening info controllers
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _nomorRekeningController =
      TextEditingController();
  final TextEditingController _namaPemilikController = TextEditingController();

  // Dropdown values dan state untuk fasilitas & peraturan
  List<Map<String, dynamic>> _tipeKamarList = [];
  List<Map<String, dynamic>> _fasilitasList = [];
  List<Map<String, dynamic>> _peraturanList = [];
  String? _selectedTipeId;
  Set<String> _selectedFasilitas = {};
  List<Map<String, dynamic>> _selectedPeraturan = [];
  bool _loadingTipeKamar = true;
  bool _loadingMasterData = true;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
    _setupCalculation();
  }

  void _setupCalculation() {
    // Auto calculate harga_final when harga_bulanan or biaya_tambahan changes
    _hargaBulananController.addListener(_calculateHargaFinal);
    _biayaTambahanController.addListener(_calculateHargaFinal);
  }

  void _calculateHargaFinal() {
    final hargaBulanan =
        double.tryParse(_hargaBulananController.text.replaceAll('.', '')) ?? 0;
    final biayaTambahan =
        double.tryParse(_biayaTambahanController.text.replaceAll('.', '')) ?? 0;
    final hargaFinal = hargaBulanan + biayaTambahan;

    _hargaFinalController.text = _formatNumber(hargaFinal.toInt());
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _loadMasterData() async {
    setState(() {
      _loadingMasterData = true;
    });

    try {
      final responses = await Future.wait([
        PengelolaService.getTipeKamar(),
        PengelolaService.getFasilitas(),
        PengelolaService.getPeraturan(),
      ]);

      setState(() {
        if (responses[0]['status']) {
          _tipeKamarList = List<Map<String, dynamic>>.from(responses[0]['data']);
        }
        if (responses[1]['status']) {
          _fasilitasList = List<Map<String, dynamic>>.from(responses[1]['data']);
        }
        if (responses[2]['status']) {
          _peraturanList = List<Map<String, dynamic>>.from(responses[2]['data']);
        }
        _loadingTipeKamar = false;
        _loadingMasterData = false;
      });
    } catch (e) {
      setState(() {
        _loadingTipeKamar = false;
        _loadingMasterData = false;
      });
    }
  }

  @override
  void dispose() {
    _namaKostController.dispose();
    _alamatController.dispose();
    _totalKamarController.dispose();
    _gmapsLinkController.dispose();
    _deskripsiController.dispose();
    _kapasitasParkirMotorController.dispose();
    _kapasitasParkirMobilController.dispose();
    _biayaTambahanController.dispose();
    _dayaListrikController.dispose();
    _sumberAirController.dispose();
    _wifiSpeedController.dispose();
    _jamSurveyController.dispose();
    _hargaBulananController.dispose();
    _depositController.dispose();
    _hargaFinalController.dispose();
    _bankController.dispose();
    _nomorRekeningController.dispose();
    _namaPemilikController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMasterData) {
      return Scaffold(
        backgroundColor: const Color(0xFF90CAF9),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF90CAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Silahkan Isi Data Kost Anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informasi Dasar
                  _buildSectionTitle('Informasi Dasar'),
                  _buildTextField(
                    'Nama Kost*',
                    _namaKostController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Alamat Lengkap*',
                    _alamatController,
                    isRequired: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Total Kamar*',
                    _totalKamarController,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTipeKamarDropdown(),
                  const SizedBox(height: 12),
                  _buildTextField('Link Google Maps', _gmapsLinkController),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Deskripsi Kost',
                    _deskripsiController,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 20),

                  // Fasilitas & Spesifikasi
                  _buildSectionTitle('Fasilitas & Spesifikasi'),
                  _buildTextField(
                    'Daya Listrik',
                    _dayaListrikController,
                    hintText: 'Contoh: 1300 VA',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Sumber Air',
                    _sumberAirController,
                    hintText: 'Contoh: PDAM',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Kecepatan WiFi',
                    _wifiSpeedController,
                    hintText: 'Contoh: 30 Mbps',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Kapasitas Parkir Motor',
                    _kapasitasParkirMotorController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Kapasitas Parkir Mobil',
                    _kapasitasParkirMobilController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Jam Survey',
                    _jamSurveyController,
                    hintText: 'Contoh: 08:00 - 16:00',
                  ),

                  const SizedBox(height: 20),

                  // Informasi Harga
                  _buildSectionTitle('Informasi Harga'),
                  _buildTextField(
                    'Harga Bulanan*',
                    _hargaBulananController,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    hintText: 'Contoh: 800000',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Deposit',
                    _depositController,
                    keyboardType: TextInputType.number,
                    hintText: 'Contoh: 500000',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Biaya Tambahan',
                    _biayaTambahanController,
                    keyboardType: TextInputType.number,
                    hintText: 'Biaya admin, kebersihan, dll',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Harga Final',
                    _hargaFinalController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    hintText: 'Otomatis terhitung',
                  ),

                  const SizedBox(height: 20),

                  // Informasi Rekening
                  _buildSectionTitle('Informasi Rekening'),
                  _buildTextField(
                    'Nama Bank',
                    _bankController,
                    hintText: 'Contoh: BCA',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Nomor Rekening', _nomorRekeningController),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Nama Pemilik Rekening',
                    _namaPemilikController,
                  ),

                  const SizedBox(height: 20),

                  // Fasilitas Selection
                  _buildFasilitasSection(),

                  const SizedBox(height: 20),

                  // Peraturan Selection
                  _buildPeraturanSection(),

                  const SizedBox(height: 20),

                  // Upload Files
                  _buildSectionTitle('Upload Foto'),
                  _buildUploadButton(),
                  const SizedBox(height: 12),
                  _buildQrisUploadButton(),

                  const SizedBox(height: 24),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType? keyboardType,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label tidak boleh kosong';
              }
              if (label.contains('Total Kamar') &&
                  int.tryParse(value) == null) {
                return 'Total kamar harus berupa angka';
              }
              if (label.contains('Harga') &&
                  double.tryParse(value.replaceAll('.', '')) == null) {
                return 'Harga harus berupa angka';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 12),
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildTipeKamarDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedTipeId,
      decoration: InputDecoration(
        labelText: 'Tipe Kamar*',
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tipe kamar harus dipilih';
        }
        return null;
      },
      items: _tipeKamarList.map((tipe) {
        return DropdownMenuItem<String>(
          value: tipe['tipe_id'],
          child: Text(
            '${tipe['nama_tipe']} - ${tipe['ukuran'] ?? ''} (${tipe['kapasitas']} orang)',
            style: TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: _isSubmitting
          ? null
          : (value) {
              setState(() {
                _selectedTipeId = value;
              });
            },
      hint: _loadingTipeKamar
          ? Text('Memuat tipe kamar...')
          : Text('Pilih tipe kamar'),
    );
  }

  Widget _buildFasilitasSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fasilitas',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fasilitasList.map((fasilitas) {
              final isSelected = _selectedFasilitas.contains(fasilitas['fasilitas_id']);
              return FilterChip(
                label: Text(fasilitas['nama_fasilitas']),
                selected: isSelected,
                onSelected: _isSubmitting
                    ? null
                    : (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFasilitas.add(fasilitas['fasilitas_id']);
                          } else {
                            _selectedFasilitas.remove(fasilitas['fasilitas_id']);
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peraturan',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._peraturanList.map((peraturan) {
            final existingPeraturan = _selectedPeraturan.firstWhere(
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
                    onChanged: _isSubmitting
                        ? null
                        : (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedPeraturan.add({
                                  'peraturan_id': peraturan['peraturan_id'],
                                  'keterangan_tambahan': '',
                                });
                              } else {
                                _selectedPeraturan.removeWhere(
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
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan Tambahan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        final index = _selectedPeraturan.indexWhere(
                          (p) => p['peraturan_id'] == peraturan['peraturan_id'],
                        );
                        if (index != -1) {
                          _selectedPeraturan[index]['keterangan_tambahan'] = value;
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

  Widget _buildUploadButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isSubmitting ? null : _pickImages,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: _isSubmitting ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Upload Foto Kost',
                    style: TextStyle(
                      color: _isSubmitting ? Colors.grey[600] : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.upload,
                    color: _isSubmitting ? Colors.grey[600] : Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_imageFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Foto Kost Terpilih:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_imageFiles[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (!_isSubmitting)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageFiles.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQrisUploadButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isSubmitting ? null : _pickQrisImage,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: _isSubmitting ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Upload QRIS (Opsional)',
                    style: TextStyle(
                      color: _isSubmitting ? Colors.grey[600] : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.qr_code,
                    color: _isSubmitting ? Colors.grey[600] : Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_qrisFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'QRIS Terpilih:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_qrisFiles.first.path),
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  _submitForm();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isSubmitting ? Colors.grey : const Color(0xFF26A69A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Menyimpan...'),
                ],
              )
            : const Text(
                'Daftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _imageFiles.addAll(pickedFiles);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih gambar: $e')),
      );
    }
  }

  Future<void> _pickQrisImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _qrisFiles.clear();
          _qrisFiles.add(pickedFile);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih gambar QRIS: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      List<String> imageUrls = [];
      String? qrisUrl;

      // Upload images if any
      if (_imageFiles.isNotEmpty || _qrisFiles.isNotEmpty) {
        final uploadThing = UploadThing(
          "sk_live_08e0250b1aab76a8067be159691359dfb45a15f5fb0906fbacf6859866f1e199",
        );

        // Upload kost images
        if (_imageFiles.isNotEmpty) {
          List<File> files =
              _imageFiles.map((xFile) => File(xFile.path)).toList();
          var uploadSuccess = await uploadThing.uploadFiles(files);

          if (uploadSuccess) {
            var uploadedFilesData = uploadThing.uploadedFilesData;
            for (var fileData in uploadedFilesData) {
              if (fileData["url"] != null) {
                imageUrls.add(fileData["url"]);
              }
            }
          }
        }

        // Upload QRIS image
        if (_qrisFiles.isNotEmpty) {
          List<File> qrisFileList = [File(_qrisFiles.first.path)];
          var uploadSuccess = await uploadThing.uploadFiles(qrisFileList);

          if (uploadSuccess) {
            var uploadedFilesData = uploadThing.uploadedFilesData;
            if (uploadedFilesData.isNotEmpty &&
                uploadedFilesData.last["url"] != null) {
              qrisUrl = uploadedFilesData.last["url"];
            }
          }
        }
      }

      // Prepare form data according to API format
      final Map<String, dynamic> formData = {
        'nama_kost': _namaKostController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'total_kamar': int.tryParse(_totalKamarController.text.trim()) ?? 1,
        'gmaps_link':
            _gmapsLinkController.text.trim().isEmpty
                ? null
                : _gmapsLinkController.text.trim(),
        'deskripsi':
            _deskripsiController.text.trim().isEmpty
                ? null
                : _deskripsiController.text.trim(),
        'kapasitas_parkir_motor':
            int.tryParse(_kapasitasParkirMotorController.text.trim()) ?? 0,
        'kapasitas_parkir_mobil':
            int.tryParse(_kapasitasParkirMobilController.text.trim()) ?? 0,
        'biaya_tambahan':
            double.tryParse(
              _biayaTambahanController.text.replaceAll('.', ''),
            ) ??
            0,
        'daya_listrik':
            _dayaListrikController.text.trim().isEmpty
                ? null
                : _dayaListrikController.text.trim(),
        'sumber_air':
            _sumberAirController.text.trim().isEmpty
                ? null
                : _sumberAirController.text.trim(),
        'wifi_speed':
            _wifiSpeedController.text.trim().isEmpty
                ? null
                : _wifiSpeedController.text.trim(),
        'jam_survey':
            _jamSurveyController.text.trim().isEmpty
                ? null
                : _jamSurveyController.text.trim(),
        'foto_kost': imageUrls,
        'qris_image': qrisUrl,
        'rekening_info': _buildRekeningInfo(),
        'tipe_id': _selectedTipeId,
        'harga_bulanan':
            double.tryParse(_hargaBulananController.text.replaceAll('.', '')) ??
            0,
        'deposit':
            _depositController.text.trim().isEmpty
                ? null
                : double.tryParse(_depositController.text.replaceAll('.', '')),
        'harga_final':
            double.tryParse(_hargaFinalController.text.replaceAll('.', '')) ??
            0,
        // Tambahan field yang ada di edit_kos
        'fasilitas_ids': _selectedFasilitas.toList(),
        'peraturan_data': _selectedPeraturan,
      };

      // Submit to API
      final response = await PengelolaService.createKost(formData);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (response['status']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => const SuccessScreen(
                  title: 'Kost Berhasil Didaftarkan',
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal mendaftarkan kost'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
}
