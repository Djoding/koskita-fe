import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/dashboard_owner_screen.dart';
// import 'package:kosan_euy/screens/tamu/pembayaran/pembayaran_tamu_selesai.dart';
import 'package:kosan_euy/widgets/success_delete_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:kosan_euy/widgets/success_screen.dart';

class AddPembayaran extends StatefulWidget {
  const AddPembayaran({super.key});

  @override
  State<AddPembayaran> createState() => _AddPembayaranState();
}

class _AddPembayaranState extends State<AddPembayaran> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _showUploadDialog();
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unggah Gambar'),
            content:
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 180)
                    : const Text('Tidak ada gambar terpilih'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF119DB1),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(
                    () => SuccessScreen(
                      title: 'menu pembayaran berhasil ditambah',
                    ),
                  );
                },
                child: const Text('Unggah'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Judul
            Text(
              'Pilih Metode Pembayaran\nDibawah Ini...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // card bank mandiri
            Center(
              child: Image.asset('assets/mandiri.png', fit: BoxFit.contain),
            ),

            const SizedBox(height: 24),
            const SizedBox(height: 24),
            // Gambar QRIS
            Center(
              child: Image.asset(
                'assets/qris.png',
                width: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Spacer(),
            // Tombol Edit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => DashboardOwnerScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF119DB1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
