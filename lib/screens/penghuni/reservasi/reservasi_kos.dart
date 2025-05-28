import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class ReservasiKosScreen extends StatefulWidget {
  const ReservasiKosScreen({super.key});

  @override
  State<ReservasiKosScreen> createState() => _ReservasiKosScreenState();
}

class _ReservasiKosScreenState extends State<ReservasiKosScreen> {
  int _currentIndex = 0;
  int _jumlah = 1;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final TextEditingController masukController = TextEditingController();
  final TextEditingController keluarController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  final List<String> imageList = [
    "assets/kapling40.png",
    "assets/unsplash2.jpg",
    "assets/unsplash3.jpg",
  ];

  @override
  void dispose() {
    masukController.dispose();
    keluarController.dispose();
    namaController.dispose();
    teleponController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel Gambar
            Stack(
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  items:
                      imageList.map((imageUrl) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                          ),
                        );
                      }).toList(),
                  options: CarouselOptions(
                    height: 220,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                // Dot Indicator
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imageList.length, (index) {
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(index),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentIndex == index
                                    ? Colors.white
                                    : Colors.white54,
                            border: Border.all(color: Colors.black12),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Tombol Back
                Positioned(
                  top: 32,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ],
            ),
            // Card Putih
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama, Alamat, Info, Harga
                  Text(
                    "Kost Kapling40",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF119DB1),
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "Jalan hj Umayah II, Citereup Bandung",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "Kost wanita, 3 Tersedia",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text(
                        "Rp 12.000.000",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "/Per tahun",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Form
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, masukController),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: masukController,
                              decoration: InputDecoration(
                                labelText: "Masuk",
                                hintText: "tgl/bln/thn",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, keluarController),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: keluarController,
                              decoration: InputDecoration(
                                labelText: "Keluar",
                                hintText: "tgl/bln/thn",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: namaController,
                    decoration: InputDecoration(
                      hintText: "Nama Lengkap",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Nomor Telepon",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate(context, tanggalController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: tanggalController,
                        decoration: InputDecoration(
                          hintText: "Tanggal Pemesanan",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Color(0xFF4CAF50),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_jumlah > 1) _jumlah--;
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_jumlah',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF4CAF50)),
                        onPressed: () {
                          setState(() {
                            _jumlah++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Rincian Harga
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Rincian Harga",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Kost 1 Tahun",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "Rp 12.000.000",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Harga",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Rp 12.000.000",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tombol Selanjutnya
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Aksi selanjutnya
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF119DB1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Selanjutnya',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
