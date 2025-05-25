import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditKosScreen extends StatelessWidget {
  const EditKosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol back
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(top: 8),
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
              const SizedBox(height: 12),
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
              _buildField('Nama Pemilik Kost', 'Mumu Natapriatna'),
              _buildField('Nama Kost', 'Kapling40@gmail.com'),
              _buildField(
                'Lokasi Alamat Kost',
                'Jalan hj Umayah II, Citereup Bandung',
              ),
              _buildField('Jenis Kost', 'Isi Sendiri'),
              _buildField('Jumlah Kamar', 'Isi sendiri'),
              _buildField('Harga Kost Pertahun', 'Isi sendiri'),
              _buildField('Fasilitas Kamar', 'Isi sendiri'),
              _buildField('Fasilitas Kamar Mandi', 'Isi Sendiri'),
              _buildField('Kebijakan Properti', 'Isi Sendiri'),
              _buildField('Kebijakan Fasilitas', 'Isi Sendiri'),
              _buildField('Deskripsi Properti', 'Isi Sendiri'),
              _buildField('Informasi Jarak', 'Isi Sendiri'),
              _buildUploadField(),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 240,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAll(() => const EditBerhasilScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF119DB1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Perbarui',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: hint,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF119DB1), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF119DB1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Upload Bangunan Kost',
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF119DB1), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF119DB1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: const Icon(Icons.upload, color: Colors.black, size: 28),
        ),
      ),
    );
  }
}

// Screen sukses edit
class EditBerhasilScreen extends StatelessWidget {
  const EditBerhasilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFE066), Color(0xFFFFC300)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.green, size: 140),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Data Kost Berhasil Diperbarui',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 28),
                  onPressed: () {
                    Get.offAllNamed('/dashboard-owner');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
