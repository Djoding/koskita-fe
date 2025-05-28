import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/tamu/reservasi/detail_kos_tamu.dart';

class DashboardReservasiTamu extends StatelessWidget {
  DashboardReservasiTamu({super.key});

  final List<Map<String, String>> kostList = [
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Kapling40',
      'alamat': 'Jalan hj Umayah II, Citereup Bandung',
      'harga': 'Rp 12.000.000',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Kapling40',
      'alamat': 'Jalan hj Umayah II, Citereup Bandung',
      'harga': 'Rp 12.000.000',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Kapling40',
      'alamat': 'Jalan hj Umayah II, Citereup Bandung',
      'harga': 'Rp 12.000.000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Tombol back
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari Kost',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // List Kost
              Expanded(
                child: ListView.separated(
                  itemCount: kostList.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final kost = kostList[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Get.to(() => const DetailKosTamu());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  kost['image']!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kost['nama']!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Color(0xFF119DB1),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            kost['alamat']!,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: const [
                                        Text(
                                          'Rp 12.000.000',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '/Tahun',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
