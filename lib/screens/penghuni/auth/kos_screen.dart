import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/dashboard_tenant_screen.dart';

class KosScreen extends StatelessWidget {
  KosScreen({super.key});

  final List<Map<String, String>> kostList = [
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Kapling40',
      'alamat': 'Jalan hj Umayah II, Citereup Bandung',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Kapling40',
      'alamat': 'Jalan hj Umayah II, Citereup Bandung',
    },
    {
      'image': 'assets/kapling40.png',
      'nama': 'Kost Kapling40',
      'alamat': 'Jalan hj Umayah II, Citereup Bandung',
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
              const SizedBox(height: 24),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari kost  Anda',
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
                      (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final kost = kostList[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Get.to(() => const DashboardTenantScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF91B7DE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      kost['alamat']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
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
