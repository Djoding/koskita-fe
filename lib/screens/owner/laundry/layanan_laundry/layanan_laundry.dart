import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/laundry/layanan_laundry/add_laundry.dart';
import 'package:kosan_euy/screens/owner/laundry/layanan_laundry/edit_layanan_laundry.dart';
import 'package:kosan_euy/widgets/success_delete_screen.dart';

class LayananLaundryScreen extends StatelessWidget {
  const LayananLaundryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> laundryList = [
      {
        'name': '1 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 6.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '2 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 12.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '3 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 18.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '4 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 24.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '5 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 30.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '6 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 36.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '7 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 42.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '8 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 48.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '9 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 54.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': '10 Kg',
        'service': 'Cuci & Gosok',
        'price': 'RP 60.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': 'Sprei',
        'service': 'Cuci & Gosok',
        'price': 'RP 15.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': 'Bedcover',
        'service': 'Cuci & Gosok',
        'price': 'RP 25.000',
        'image': 'assets/laundry.png',
      },
      {
        'name': 'Karpet',
        'service': 'Cuci & Gosok',
        'price': 'RP 20.000',
        'image': 'assets/laundry.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Layanan Laundry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cuci & Gosok',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            Get.to(() => const AddLayananLaundryScreen());
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          'assets/icon_laundry.png',
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.local_laundry_service,
                                color: Colors.grey,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // List layanan laundry
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                itemCount: laundryList.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = laundryList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Layanan:  ${item['service']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['price'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16.0,
                              left: 4,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.asset(
                                    item['image'],
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: const Text(
                                            'Konfirmasi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            'Apakah anda yakin ingin menghapus laundry ${item['name'].toString().toLowerCase()}?',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: const Text('Tidak'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Get.to(
                                                  () => SuccessDeleteScreen(
                                                    title:
                                                        'Layanan Laundry Berhasil Dihapus',
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Iya',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Tombol Edit
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const EditLayananLaundryScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF119DB0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
