import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReservasiScreen extends StatefulWidget {
  const ReservasiScreen({super.key});

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  final LatLng _kostLocation = LatLng(-6.9731, 107.6291);
  bool isLoved = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();


  final List<String> imageList = [
    "assets/unsplash1.jpg",
    "assets/unsplash2.jpg",
    "assets/unsplash3.jpg",
  ];

  @override
  void dispose(){
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    super.dispose();
  }


  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField("Nama Lengkap", nameController, keyboardType: TextInputType.text),
                    SizedBox(height: 16),
                    _buildInputField("Nomor Telepon", phoneController, keyboardType: TextInputType.phone),
                    SizedBox(height: 16),
                    _buildDatePickerField(context, "Tanggal Pemesanan", dateController),
                    SizedBox(height: 16),
                    _buildPriceDetails(),
                    SizedBox(height: 16),
                    Text(
                      "Pilih Metode Pembayaran",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildPaymentOption(context, "Transfer Bank"),
                        _buildPaymentOption(context, "E-Wallet"),
                        _buildPaymentOption(context, "Kartu Kredit"),
                        _buildPaymentOption(context, "Virtual Account"),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildSubmitButton(context)
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildPaymentOption(BuildContext context, String method) {
    return ListTile(
      title: Text(method),
      onTap: () {
        Navigator.pop(context);
        // TODO: Lakukan sesuatu dengan pilihan yang dipilih
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  // Widget untuk Date Picker
  Widget _buildDatePickerField(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              });
            }
          },
        ),
      ],
    );
  }

  // Widget untuk Rincian Harga
  Widget _buildPriceDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rincian Harga", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Kost 1 Tahun"),
              Text("Rp 12.000.000", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Harga"),
              Text("Rp 12.000.000", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk Tombol Submit
  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[300],
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {},
        child: Text("Tambah/Edit", style: TextStyle(color: Colors.white)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar Kosan (Carousel)
            Stack(
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 250,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: imageList.map((imageUrl) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
                ),

                //Carousel slider/dot
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imageList.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          _carouselController.animateToPage(index);
                        },
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                //Tombol Back dan Share
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Back
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Tombol Share
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 20,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            isLoved = !isLoved;
                          });
                        },
                        icon: Icon(
                          isLoved ? Icons.favorite : Icons.add,
                          color: isLoved ? Colors.red : Colors.black,
                        ),
                    ),
                  ),
                )
              ],
            ),

            // Detail Kosan
            Container(
              padding: const EdgeInsets.all(20),
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
                  // Nama & Lokasi Kosan
                  Text(
                    "Kost Kapling40",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 5),
                      Text("Jalan hj Umayah II, Citereup Bandung"),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 5),
                      Text("Kost wanita, 4 tersedia"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Harga
                  Text(
                    "Rp 12.000.000 / Per Tahun",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fasilitas
                  const Text(
                    "Fasilitas Kamar:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("1. Meja\n2. Lemari baju\n3. Tempat tidur\n4. Kursi\n5. Cermin"),
                  const SizedBox(height: 10),

                  const Text(
                    "Fasilitas Kamar Mandi:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("1. Kamar mandi dalam\n2. Gayung\n3. Kloset jongkok\n4. Ember"),
                  const SizedBox(height: 10),

                  // Kebijakan Properti
                  const Text(
                    "Kebijakan Properti:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("1. Tipe ini hanya diisi 1 orang\n2. Teman menginap dikenakan biaya\n3. Tidak ada jam malam\n4. Sampah dibuang setiap pagi"),

                  const SizedBox(height: 10),

                  // Kebijakan Fasilitas
                  const Text(
                    "Kebijakan Fasilitas:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("1. Sumber air: PAM\n2. Kapasitas parkir: 10 motor\n3. Sudah termasuk listrik"),

                  const SizedBox(height: 10),

                  // Deskripsi Properti
                  const Text(
                    "Deskripsi Properti:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("1. 4 x 3 meter\n2. Termasuk listrik"),

                  const SizedBox(height: 10),

                  // Detail Lokasi
                  const Text(
                    "Detail Lokasi:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("Jalan hj Umayah II, kosan kapling40, kawasan STT Telkom, Dayeuh Kolot, Kabupaten Bandung, Jawa Barat, kode pos 40257"),
                  const SizedBox(height: 10),

                  // Map Dummy (Ganti dengan Google Maps API jika perlu)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      // image: const DecorationImage(
                      //   image: NetworkImage("https://via.placeholder.com/300x150"), // Ganti dengan map asli
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _kostLocation,
                        initialZoom: 15.0
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: _kostLocation,
                              child: Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Informasi Jarak
                  const Text(
                    "Informasi Jarak:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("Kost ini 2 menit sampai ke Telkom University, dekat dengan Alfamart, Indomart."),

                  const SizedBox(height: 20),

                  // Tombol Tambah/Edit
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      _showPaymentMethods(context);
                    },
                    child: const Text(
                      "Tambah/Edit",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}



