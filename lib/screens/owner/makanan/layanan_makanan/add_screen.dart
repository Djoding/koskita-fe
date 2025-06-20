// lib/screens/owner/makanan/layanan_makanan/add_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/services/catering_menu_service.dart'; // Import service

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaMenuController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  String? _selectedKategori;
  bool _isSubmitting = false;

  String? _cateringId; // Will be passed as argument

  @override
  void initState() {
    super.initState();
    // Retrieve cateringId from arguments
    if (Get.arguments != null && Get.arguments['cateringId'] != null) {
      _cateringId = Get.arguments['cateringId'];
    } else {
      // Handle case where cateringId is not passed (e.g., show error, pop screen)
      Get.snackbar(
        'Error',
        'Catering ID tidak ditemukan. Kembali ke daftar menu.',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back(); // Pop if no cateringId
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Error picking image: $e');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri Foto'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addMenuItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cateringId == null) {
      Get.snackbar('Error', 'Catering ID tidak ditemukan.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await CateringMenuService.addCateringMenuItem(
        cateringId: _cateringId!,
        namaMenu: _namaMenuController.text.trim(),
        kategori: _selectedKategori!,
        harga: double.parse(
          _hargaController.text.replaceAll('.', ''),
        ), // Remove dots for parsing
        fotoMenu: _imageFile,
        isAvailable: true, // Default to available
      );

      if (response['status']) {
        Get.back(); // Go back to previous screen (menu list)
        Get.snackbar(
          'Sukses',
          response['message'] ?? 'Menu berhasil ditambahkan!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal menambahkan menu.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _namaMenuController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Added SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              // Added Form widget
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Silahkan Isi Data Makanan/Minuman',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nama Makanan/Minuman
                  TextFormField(
                    // Changed to TextFormField
                    controller: _namaMenuController,
                    decoration: InputDecoration(
                      hintText: 'Nama Makanan/Minuman',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 18, // Adjusted vertical padding
                      ),
                      border: OutlineInputBorder(
                        // Added border
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama menu tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Kategori Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedKategori,
                    decoration: InputDecoration(
                      hintText: 'Pilih Kategori',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 18, // Adjusted vertical padding
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'MAKANAN_BERAT',
                        child: Text('Makanan Berat'),
                      ),
                      DropdownMenuItem(value: 'SNACK', child: Text('Snack')),
                      DropdownMenuItem(
                        value: 'MINUMAN',
                        child: Text('Minuman'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedKategori = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Harga
                  TextFormField(
                    // Changed to TextFormField
                    controller: _hargaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Harga',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 18, // Adjusted vertical padding
                      ),
                      border: OutlineInputBorder(
                        // Added border
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      if (double.tryParse(value.replaceAll('.', '')) == null) {
                        return 'Harga harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Upload Foto
                  GestureDetector(
                    onTap: () {
                      _showImageSourceActionSheet(context);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _imageFile == null
                                  ? 'Upload Foto Makanan/Minuman'
                                  : 'Foto Terpilih: ${_imageFile!.path.split('/').last}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            const Icon(
                              Icons.file_download_outlined,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_imageFile != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSubmitting
                                ? Colors.grey
                                : const Color(0xFF4D9DAB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _addMenuItem,
                      child:
                          _isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
