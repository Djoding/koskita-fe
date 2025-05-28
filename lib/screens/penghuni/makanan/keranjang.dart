import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_Penghuni.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  List<Map<String, dynamic>> pesanan = [
    {
      'image': 'assets/food6.png',
      'nama': 'Indomie Kuah Special',
      'harga': 8000,
      'jumlah': 1,
    },
    {
      'image': 'assets/drink5.png',
      'nama': 'Es Teh',
      'harga': 4000,
      'jumlah': 1,
    },
  ];

  int get totalHarga => pesanan.fold(
    0,
    (int sum, item) => sum + (item['harga'] as int) * (item['jumlah'] as int),
  );
  int get totalItem =>
      pesanan.fold(0, (int sum, item) => sum + (item['jumlah'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Header
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
                      const SizedBox(width: 16),
                      const Text(
                        'Keranjang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daftar Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: pesanan.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = pesanan[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item['image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rp ${item['harga'].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (item['jumlah'] > 1)
                                              item['jumlah']--;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4CAF50),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '${item['jumlah']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            item['jumlah']++;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4CAF50),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFFCCCCCC),
                                size: 32,
                              ),
                              onPressed: () {
                                setState(() {
                                  pesanan.removeAt(index);
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF119DB1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah Item',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        '$totalItem item',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pesanan',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        'Rp ${totalHarga.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => MenuPembayaranPenghuni());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF119DB1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Pesan Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
