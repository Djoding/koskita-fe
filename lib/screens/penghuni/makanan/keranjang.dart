import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/penghuni/pembayaran/menu_pembayaran_order.dart';

class KeranjangScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? selectedItems;
  final String cateringId;
  final String reservasiId;
  final String? qrisImage;
  final Map<String, dynamic>? rekeningInfo;

  const KeranjangScreen({
    super.key,
    this.selectedItems,
    required this.cateringId,
    required this.reservasiId,
    this.qrisImage, // TAMBAH INI
    this.rekeningInfo, // TAMBAH INI
  }) : assert(true, 'A cateringId (or laundryId) must be provided.');

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  List<Map<String, dynamic>> pesanan = [];

  // Variabel untuk menyimpan ID dan info pembayaran
  late String _currentCateringId;
  late String _currentReservasiId;
  String? _currentQrisImage; // TAMBAH INI
  Map<String, dynamic>? _currentRekeningInfo; // TAMBAH INI
  // String? _currentLaundryId; // Jika relevan

  @override
  void initState() {
    super.initState();

    _currentCateringId = widget.cateringId;
    _currentReservasiId = widget.reservasiId;
    _currentQrisImage = widget.qrisImage; // INISIALISASI
    _currentRekeningInfo = widget.rekeningInfo; // INISIALISASI
    // _currentLaundryId = widget.laundryId; // Jika relevan

    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      for (var newItem in widget.selectedItems!) {
        final existingItemIndex = pesanan.indexWhere(
          (p) => p['menu_id'] == newItem['menu_id'],
        );

        if (existingItemIndex != -1) {
          pesanan[existingItemIndex]['jumlah'] =
              (pesanan[existingItemIndex]['jumlah'] as int) +
              (newItem['jumlah'] as int);
        } else {
          pesanan.add(Map<String, dynamic>.from(newItem));
        }
      }
      debugPrint('KeranjangScreen received items: ${pesanan.length}');
      debugPrint(
        'Catering ID: $_currentCateringId, Reservasi ID: $_currentReservasiId',
      );
      debugPrint(
        'QRIS Image: $_currentQrisImage, Rekening Info: $_currentRekeningInfo',
      );
    } else {
      // Default mock data (sesuaikan dengan format baru, termasuk 'menu_id' dan harga double)
      pesanan = [
        {
          'menu_id': 'mock_indomie_id',
          'image': 'assets/food6.png',
          'nama': 'Indomie Kuah Special',
          'harga': 8000.0,
          'jumlah': 1,
          'kategori': 'MAKANAN_BERAT',
        },
        {
          'menu_id': 'mock_esteh_id',
          'image': 'assets/drink5.png',
          'nama': 'Es Teh',
          'harga': 4000.0,
          'jumlah': 1,
          'kategori': 'MINUMAN',
        },
        {
          'menu_id': 'mock_midog_id',
          'image': 'assets/food1.png',
          'nama': 'Midog',
          'harga': 5000.0,
          'jumlah': 2,
          'kategori': 'MAKANAN_BERAT',
        },
      ];
      debugPrint('KeranjangScreen using mock data.');
      // Untuk mock data, set juga info pembayaran dummy
      _currentQrisImage = 'https://i.stack.imgur.com/yvS1s.png';
      _currentRekeningInfo = {
        'bank': 'Dummy Bank',
        'nomor': '123456',
        'atas_nama': 'Dummy A/N',
      };
    }
  }

  double get totalHarga => pesanan.fold(
    0.0,
    (double sum, item) =>
        sum + (item['harga'] as double) * (item['jumlah'] as int),
  );

  int get totalItem =>
      pesanan.fold(0, (int sum, item) => sum + (item['jumlah'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF89B3DE), Color(0xFF6B9EDD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildOrderListTitle(),
              const SizedBox(height: 12),
              Expanded(
                child:
                    pesanan.isEmpty
                        ? _buildEmptyCartState()
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: pesanan.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = pesanan[index];
                            return _CartItemCard(
                              item: item,
                              onQuantityChanged: (change) {
                                setState(() {
                                  item['jumlah'] =
                                      (item['jumlah'] as int) + change;
                                  if (item['jumlah'] <= 0) {
                                    pesanan.removeAt(index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item['nama']} dihapus dari keranjang.',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  pesanan.removeAt(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item['nama']} dihapus dari keranjang.',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                });
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSummary(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF119DB1).withAlpha((0.9 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF119DB1).withAlpha((0.9 * 255).toInt()),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Keranjang Anda',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3.0,
                  color: const Color(0xFF119DB1).withAlpha((0.9 * 255).toInt()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Daftar Pesanan',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          shadows: [
            Shadow(
              offset: const Offset(0.5, 0.5),
              blurRadius: 2.0,
              color: const Color(0xFF119DB1).withAlpha((0.9 * 255).toInt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: const Color(0xFF119DB1).withAlpha((0.9 * 255).toInt()),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjang Anda kosong!',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFFFFF).withAlpha((0.8 * 255).toInt()),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 2.0,
                    color: const Color(
                      0xFF000000,
                    ).withAlpha((0.1 * 255).toInt()),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tambahkan makanan atau minuman untuk memulai pesanan.',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFFFFF).withAlpha((0.7 * 255).toInt()),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4D9DAB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                elevation: 5,
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(
                'Mulai Belanja',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF119DB1).withAlpha((0.9 * 255).toInt()),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).toInt()),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah Item',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
              Text(
                '$totalItem item',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pesanan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700, // Make total price bolder
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (pesanan.isEmpty) {
                  Get.snackbar(
                    'Keranjang Kosong',
                    'Tambahkan item ke keranjang sebelum melanjutkan pembayaran.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orangeAccent.withAlpha(
                      (0.9 * 255).toInt(),
                    ),
                    colorText: Colors.white,
                  );
                } else {
                  debugPrint(
                    '--- KeranjangScreen sending to OrderPaymentScreen ---',
                  );
                  for (var item in pesanan) {
                    debugPrint(
                      '  Menu ID: ${item['menu_id']}, Nama: ${item['nama']}, Jumlah: ${item['jumlah']} (Tipe: ${item['jumlah']?.runtimeType})',
                    );
                  }
                  debugPrint(
                    '----------------------------------------------------',
                  );
                  Get.to(
                    () => OrderPaymentScreen(
                      reservasiId: _currentReservasiId,
                      cateringId: _currentCateringId,
                      orderItems: pesanan,
                      totalAmount: totalHarga,
                      qrisImage: _currentQrisImage,
                      rekeningInfo: _currentRekeningInfo,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF119DB1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: Colors.black.withAlpha((0.2 * 255).toInt()),
              ),
              child: Text(
                'Pesan Sekarang',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: const Color(0xFF4D9DAB).withAlpha((0.1 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  item['image'].startsWith('http')
                      ? Image.network(
                        item['image'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: const Color(0xFF4D9DAB),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                size: 45,
                                color: Colors.grey[400],
                              ),
                            ),
                      )
                      : Image.asset(
                        item['image'],
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                size: 45,
                                color: Colors.grey[400],
                              ),
                            ),
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama'],
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${item['harga'].toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4D9DAB),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantityButton(
                          Icons.remove,
                          () => onQuantityChanged(-1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${item['jumlah']}',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          Icons.add,
                          () => onQuantityChanged(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.delete_forever,
                color: Colors.red.shade400,
                size: 32,
              ),
              onPressed: onDelete,
              splashRadius: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF4D9DAB).withAlpha((0.1 * 255).toInt()),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF4D9DAB), size: 20),
      ),
    );
  }
}
