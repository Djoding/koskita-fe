import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_Penghuni.dart';

class PemesananLaundryScreen extends StatefulWidget {
  const PemesananLaundryScreen({super.key});

  @override
  State<PemesananLaundryScreen> createState() => _PemesananLaundryScreenState();
}

class _PemesananLaundryScreenState extends State<PemesananLaundryScreen> {
  int selectedTanggalPesan = 1;
  int selectedJamPesan = 1;
  int selectedTanggalKirim = 4;
  int selectedJamKirim = 1;

  final List<String> hariTanggal = [
    'Senin\n23 Des',
    'Selasa\n24 Des',
    'Rabu\n25 Des',
    'Kamis\n26 Des',
    'Jumat\n27 Des',
    'Sabtu\n28 Des',
    'Minggu\n29 Des',
  ];
  final List<String> jamList = [
    '09.00 WIB',
    '10.00 WIB',
    '11.00 WIB',
    '12.00 WIB',
    '14.00 WIB',
    '15.00 WIB',
    '17.00 WIB',
    '19.00 WIB',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
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
                      'Pemesanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Pemesanan Hari/Tanggal
                const Center(
                  child: Text(
                    'Pemesanan\nHari/Tanggal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hariTanggal.length,
                    separatorBuilder: (context, i) => const SizedBox(width: 12),
                    itemBuilder:
                        (context, i) => GestureDetector(
                          onTap: () => setState(() => selectedTanggalPesan = i),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 70,
                              minHeight: 48,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedTanggalPesan == i
                                      ? Colors.white
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                hariTanggal[i],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      selectedTanggalPesan == i
                                          ? const Color(0xFF119DB1)
                                          : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                // Jam Pemesanan
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(
                    jamList.length,
                    (i) => GestureDetector(
                      onTap: () => setState(() => selectedJamPesan = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedJamPesan == i
                                  ? Colors.white
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          jamList[i],
                          style: TextStyle(
                            color:
                                selectedJamPesan == i
                                    ? const Color(0xFF119DB1)
                                    : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Pengiriman Hari/Tanggal
                const Center(
                  child: Text(
                    'Pengiriman\nHari/Tanggal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hariTanggal.length,
                    separatorBuilder: (context, i) => const SizedBox(width: 12),
                    itemBuilder:
                        (context, i) => GestureDetector(
                          onTap: () => setState(() => selectedTanggalKirim = i),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 70,
                              minHeight: 48,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedTanggalKirim == i
                                      ? Colors.white
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                hariTanggal[i],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      selectedTanggalKirim == i
                                          ? const Color(0xFF119DB1)
                                          : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                // Jam Pengiriman
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(
                    jamList.length,
                    (i) => GestureDetector(
                      onTap: () => setState(() => selectedJamKirim = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedJamKirim == i
                                  ? Colors.white
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          jamList[i],
                          style: TextStyle(
                            color:
                                selectedJamKirim == i
                                    ? const Color(0xFF119DB1)
                                    : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Card Laundry
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.08 * 255).toInt()),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 22,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '3 Kg',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Layanan:',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Cuci & Gosok',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'RP 18.000',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/laundry.png',
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Tambah +',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(
                  color: Colors.white,
                  thickness: 1.2,
                  height: 36,
                  indent: 8,
                  endIndent: 8,
                ),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 260,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => MenuPembayaranPenghuni());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF119DB1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Selanjutnya',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
