// lib/screens/owner/makanan/layanan_makanan/edit_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/services/catering_menu_service.dart'; // Import service
import 'package:kosan_euy/models/catering_model.dart'; // Import models
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts

class EditFoodScreen extends StatefulWidget {
  const EditFoodScreen({super.key});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late CateringMenuItem _menuItem;
  late String _cateringId;

  final TextEditingController _namaMenuController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  String? _selectedKategori;
  bool _isAvailable = true;
  File? _imageFile; // For new image upload
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Retrieve arguments
    if (Get.arguments != null) {
      _cateringId = Get.arguments['cateringId'];
      _menuItem = Get.arguments['menuItem'];

      _namaMenuController.text = _menuItem.namaMenu;
      _hargaController.text = _menuItem.harga.toStringAsFixed(0);
      _selectedKategori = _menuItem.kategori;
      _isAvailable = _menuItem.isAvailable;
    } else {
      Get.snackbar('Error', 'Menu item data not found.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
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

  Future<void> _updateMenuItem() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Peringatan',
        'Harap perbaiki kesalahan input pada field yang ditandai.', // Changed message
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await CateringMenuService.updateCateringMenuItem(
        cateringId: _cateringId,
        menuId: _menuItem.menuId,
        namaMenu: _namaMenuController.text.trim(),
        kategori: _selectedKategori,
        harga: double.parse(_hargaController.text.replaceAll('.', '')),
        newFotoMenu: _imageFile,
        existingFotoMenuUrl:
            _menuItem.fotoMenu, // Pass the original relative path
        isAvailable: _isAvailable,
      );

      if (response['status']) {
        Get.back(
          result: true,
        ); // Pass true to signal refresh on previous screen
        Get.snackbar(
          'Sukses',
          response['message'] ?? 'Menu berhasil diperbarui!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal memperbarui menu.',
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
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
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
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Edit Makanan/Minuman',
                      style: GoogleFonts.poppins(
                        // Use GoogleFonts
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Nama Menu
                  TextFormField(
                    controller: _namaMenuController,
                    decoration: InputDecoration(
                      // Removed RichText for asterisk, as fields are not strictly required in edit
                      labelText: 'Nama Makanan/Minuman',
                      labelStyle: GoogleFonts.poppins(
                        // Use GoogleFonts
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF4A99BD),
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
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
                      // Removed RichText for asterisk
                      labelText: 'Kategori',
                      labelStyle: GoogleFonts.poppins(
                        // Use GoogleFonts
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF4A99BD),
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
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
                    controller: _hargaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      // Removed RichText for asterisk
                      labelText: 'Harga',
                      labelStyle: GoogleFonts.poppins(
                        // Use GoogleFonts
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF4A99BD),
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      final cleanedValue = value.replaceAll(
                        '.',
                        '',
                      ); // Remove dots for parsing
                      final price = double.tryParse(cleanedValue);

                      if (price == null) {
                        return 'Harga harus berupa angka yang valid';
                      }
                      if (price <= 0) {
                        return 'Harga harus lebih dari 0';
                      }
                      const double maxAllowedPrice =
                          999999.99; // Adjust based on your DB precision, e.g., DECIMAL(8,2)
                      if (price > maxAllowedPrice) {
                        // Format the max allowed price for the message
                        final formattedMaxPrice = maxAllowedPrice
                            .toInt()
                            .toString()
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]}.',
                            );
                        return 'Harga terlalu besar. Maksimum Rp $formattedMaxPrice.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Status Ketersediaan
                  Row(
                    children: [
                      Text(
                        'Tersedia:',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ), // Use GoogleFonts
                      ),
                      Switch(
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.grey,
                      ),
                    ],
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
                                  ? 'Upload Foto Makanan/Minuman Baru'
                                  : 'Foto Baru Terpilih: ${_imageFile!.path.split('/').last}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                              ), // Use GoogleFonts
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
                  if (_imageFile != null) // Preview new image
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
                    )
                  else if (_menuItem.fotoMenuUrl != null) // Show existing image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(_menuItem.fotoMenuUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Foto Existing',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      ), // Use GoogleFonts
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
                                : const Color(0xFF119DB0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _updateMenuItem,
                      child:
                          _isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Perbarui',
                                style: GoogleFonts.poppins(
                                  // Use GoogleFonts
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
