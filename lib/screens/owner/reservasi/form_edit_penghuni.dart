import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FormEditPenghuniScreen extends StatefulWidget {
  const FormEditPenghuniScreen({super.key});

  @override
  State<FormEditPenghuniScreen> createState() => _FormEditPenghuniScreenState();
}

class _FormEditPenghuniScreenState extends State<FormEditPenghuniScreen> {
  late TextEditingController _namaController;
  late TextEditingController _kamarController;
  late TextEditingController _masukController;
  late TextEditingController _keluarController;
  late TextEditingController _alamatController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    _namaController = TextEditingController(text: args['nama'] ?? '');
    _kamarController = TextEditingController(text: args['kamar'] ?? '');
    _masukController = TextEditingController(text: args['masuk'] ?? '');
    _keluarController = TextEditingController(text: args['keluar'] ?? '');
    _alamatController = TextEditingController(text: args['alamat'] ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kamarController.dispose();
    _masukController.dispose();
    _keluarController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button & title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Edit Data Diri Penghuni kost',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildField('Nama Penghuni Kost', _namaController),
                const SizedBox(height: 16),
                _buildField('No Kamar', _kamarController),
                const SizedBox(height: 16),
                _buildField('Masuk', _masukController),
                const SizedBox(height: 16),
                _buildField('Keluar', _keluarController),
                const SizedBox(height: 16),
                _buildField('Lokasi Alamat Kost', _alamatController),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Tampilkan screen edit berhasil
                        Get.to(() => const EditBerhasilScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF119DB1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Perbarui',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF119DB1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF119DB1)),
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
      ],
    );
  }
}

// Screen EditBerhasilScreen
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
                      child: Icon(Icons.check, color: Colors.green, size: 120),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Data Penghuni Kost Berhasil Diperbarui',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
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
                  onPressed: () => Get.offAllNamed('/dashboard-owner'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
