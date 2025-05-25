import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditPenghuniScreen extends StatefulWidget {
  final String penghuniId;
  const EditPenghuniScreen({super.key, this.penghuniId = ''});

  @override
  State<EditPenghuniScreen> createState() => _EditPenghuniScreenState();
}

class _EditPenghuniScreenState extends State<EditPenghuniScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaPenghuniController = TextEditingController();
  final TextEditingController _noKamarController = TextEditingController();
  final TextEditingController _masukKosController = TextEditingController();
  final TextEditingController _keluarKosController = TextEditingController();
  final TextEditingController _alamatKosController = TextEditingController();

  @override
  void dispose() {
    _namaPenghuniController.dispose();
    _noKamarController.dispose();
    _masukKosController.dispose();
    _keluarKosController.dispose();
    _alamatKosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _buildTextField(
                    'Nama Penghuni Kost',
                    _namaPenghuniController,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Nomor Kamar', _noKamarController),
                  const SizedBox(height: 12),
                  _buildTextField('Masuk', _masukKosController),
                  const SizedBox(height: 12),
                  _buildTextField('Keluar', _keluarKosController),
                  const SizedBox(height: 12),
                  _buildTextField('Lokasi Alamat Kost', _alamatKosController),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Routing ke form_edit_penghuni.dart, parsing data dari field
                          Get.toNamed(
                            '/form-edit-penghuni',
                            arguments: {
                              'nama': _namaPenghuniController.text,
                              'kamar': _noKamarController.text,
                              'masuk': _masukKosController.text,
                              'keluar': _keluarKosController.text,
                              'alamat': _alamatKosController.text,
                            },
                          );
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
                        'Perbarui',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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
    );
  }
}
