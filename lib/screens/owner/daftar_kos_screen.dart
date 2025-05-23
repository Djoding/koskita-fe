import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosan_euy/services/kost_service.dart';
import 'dart:io';

import 'package:kosan_euy/widgets/dialog_utils.dart';
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
  List<XFile> _imageFiles = [];
  List<String> _uploadedImageUrls = [];

  final TextEditingController _namaPemilikController = TextEditingController();
  final TextEditingController _namaKostController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _jenisKostController = TextEditingController();
  final TextEditingController _jumlahKamarController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _fasilitasKamarController = TextEditingController();
  final TextEditingController _fasilitasKamarMandiController = TextEditingController();
  final TextEditingController _kebijakanPropertiController = TextEditingController();
  final TextEditingController _kebijakanFasilitasController = TextEditingController();
  final TextEditingController _deskripsiPropertiController = TextEditingController();
  final TextEditingController _informasiJarakController = TextEditingController();

  @override
  void dispose() {
    _namaPemilikController.dispose();
    _namaKostController.dispose();
    _lokasiController.dispose();
    _jenisKostController.dispose();
    _jumlahKamarController.dispose();
    _hargaController.dispose();
    _fasilitasKamarController.dispose();
    _fasilitasKamarMandiController.dispose();
    _kebijakanPropertiController.dispose();
    _kebijakanFasilitasController.dispose();
    _deskripsiPropertiController.dispose();
    _informasiJarakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF90CAF9), // Light blue background
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
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
                  _buildTextField('Nama Pemilik Kost', _namaPemilikController),
                  const SizedBox(height: 12),
                  _buildTextField('Nama Kost', _namaKostController),
                  const SizedBox(height: 12),
                  _buildTextField('Lokasi Alamat Kost', _lokasiController),
                  const SizedBox(height: 12),
                  _buildTextField('Jenis Kost', _jenisKostController),
                  const SizedBox(height: 12),
                  _buildTextField('Jumlah Kamar', _jumlahKamarController),
                  const SizedBox(height: 12),
                  _buildTextField('Harga Kost Pertahun', _hargaController),
                  const SizedBox(height: 12),
                  _buildTextField('Fasilitas Kamar', _fasilitasKamarController),
                  const SizedBox(height: 12),
                  _buildTextField('Fasilitas Kamar Mandi', _fasilitasKamarMandiController),
                  const SizedBox(height: 12),
                  _buildTextField('Kebijakan Properti', _kebijakanPropertiController),
                  const SizedBox(height: 12),
                  _buildTextField('Kebijakan Fasilitas', _kebijakanFasilitasController),
                  const SizedBox(height: 12),
                  _buildTextField('Deskripsi Properti', _deskripsiPropertiController),
                  const SizedBox(height: 12),
                  _buildTextField('Informasi Jarak', _informasiJarakController),
                  const SizedBox(height: 12),
                  _buildUploadButton(),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Upload Bangunan Kost',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.upload,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_imageFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Selected Images:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _uploadImagesAndForm();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26A69A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Daftar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
      // Handle any errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _uploadImagesAndForm() async {
    final uploadThing = UploadThing("sk_live_08e0250b1aab76a8067be159691359dfb45a15f5fb0906fbacf6859866f1e199");

    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    DialogUtils.showLoadingDialog(context, true);

    try {
      List<File> files = _imageFiles.map((xFile) => File(xFile.path)).toList();

      var uploadSuccess = await uploadThing.uploadFiles(files);

      if (uploadSuccess) {
        var uploadedFilesData = uploadThing.uploadedFilesData;
        debugPrint("FILE UPLOADED $uploadedFilesData");

        _uploadedImageUrls = [];
        for (var fileData in uploadedFilesData) {
          if (fileData["url"] != null) {
            _uploadedImageUrls.add(fileData["url"]);
          }
        }
        await _sendFormDataToApi();
      } else {
        // Upload failed
        if(!mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload images')),
        );
      }
    } catch (e) {
      // Close loading dialog
      if(!mounted) return;
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _sendFormDataToApi() async {
    final Map<String, dynamic> formData = {
      'namaPemilik': _namaPemilikController.text,
      'namaKost': _namaKostController.text,
      'lokasi': _lokasiController.text,
      'jenisKost': _jenisKostController.text,
      'jumlahKamar': _jumlahKamarController.text,
      'harga': _hargaController.text,
      'fasilitasKamar': _fasilitasKamarController.text,
      'fasilitasKamarMandi': _fasilitasKamarMandiController.text,
      'kebijakanProperti': _kebijakanPropertiController.text,
      'kebijakanFasilitas': _kebijakanFasilitasController.text,
      'deskripsiProperti': _deskripsiPropertiController.text,
      'informasiJarak': _informasiJarakController.text,
      'imageUrls': _uploadedImageUrls,
    };

    debugPrint("Sending form data to API: $formData");

    try {
      final response = await KostService.createKost(formData);
      if(!mounted) return;
      Navigator.of(context).pop();
      if (response['status']) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessScreen(title: 'Kost Berhasil di Daftarkan', subtitle: 'Tunggu Persetujuan Dari Admin'))
        );
        return;
      }
      debugPrint("SINI 3");
    } catch (e) {
      debugPrint("Error sending form data: $e");
      throw Exception('Error sending form data: $e');
    }
  }
}
