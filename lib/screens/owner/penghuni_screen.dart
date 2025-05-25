import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/add_penghuni_screen.dart';
import 'package:kosan_euy/widgets/profile_section.dart';
import 'package:kosan_euy/widgets/top_bar.dart';
import 'package:get/get.dart';

class PenghuniScreen extends StatefulWidget {
  const PenghuniScreen({super.key});

  @override
  State<PenghuniScreen> createState() => _PenghuniScreenState();
}

class _PenghuniScreenState extends State<PenghuniScreen> {
  final List<Map<String, String>> penghuni = [
    {
      "nama": "Nella Aprilia",
      "kamar": "Kamar No 10",
      "masuk": "1 Mei 2024",
      "keluar": "1 Mei 2025",
    },
    {
      "nama": "Angelica Sharon",
      "kamar": "Kamar No 15",
      "masuk": "10 Juni 2023",
      "keluar": "10 Juni 2024",
    },
    {
      "nama": "Putri Ayu",
      "kamar": "Kamar No 5",
      "masuk": "5 Maret 2024",
      "keluar": "5 Maret 2025",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (Notification & Settings)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  TopBar(),
                ],
              ),
              const SizedBox(height: 40),
              ProfileSection(),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Data Diri Penghuni Kost",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ListView Harus dalam Expanded biar nggak error
              Expanded(
                // flex: 10,
                child: ListView.builder(
                  itemCount: penghuni.length,
                  itemBuilder: (context, index) {
                    return _buildPenghuniCard(penghuni[index]);
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPenghuniScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Tambah Penghuni',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPenghuniCard(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(211, 234, 255, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            data["nama"] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data["kamar"] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Masuk: ${data["masuk"] ?? ''}",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          Text(
            "Keluar: ${data["keluar"] ?? ''}",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              //Sunting button
              IconButton(
                onPressed: () {
                  // Routing ke edit_user.dart, parsing data dari card
                  Get.toNamed(
                    '/edit-user',
                    arguments: {
                      'nama': data['nama'] ?? '',
                      'kamar': data['kamar'] ?? '',
                      'masuk': data['masuk'] ?? '',
                      'keluar': data['keluar'] ?? '',
                      'alamat': 'Jalan hj Umayah II, Citereup Bandung',
                    },
                  );
                },
                icon: const Icon(Icons.edit, size: 24),
              ),
              IconButton(
                //Delete button
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: Text(
                            'Apakah Anda yakin ingin menghapus ${data["nama"]}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Tidak'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Routing ke delete_user.dart pakai GetX, parsing nama dari data card
                                Get.offAllNamed(
                                  '/delete-user',
                                  arguments: {'nama': data['nama'] ?? ''},
                                );
                              },
                              child: const Text('Ya'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.delete, size: 24, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
