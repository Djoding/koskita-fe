import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/penghuni/laundry/order_laundry_history.dart';
import 'package:kosan_euy/screens/penghuni/laundry/pemesanan_laundry.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class LaundryPenghuni extends StatefulWidget {
  final String laundryId;
  final String reservasiId;

  const LaundryPenghuni({
    super.key,
    required this.laundryId,
    required this.reservasiId,
  });

  @override
  State<LaundryPenghuni> createState() => _LaundryPenghuniState();
}

class _LaundryPenghuniState extends State<LaundryPenghuni>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allLaundryServices = [];
  Map<String, dynamic>? _laundryInfo;
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, Map<String, dynamic>> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadLaundryServices();
  }

  Future<void> _loadLaundryServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await LaundryService.getLaundryServices(widget.laundryId);
      if (result['status'] == true) {
        setState(() {
          final Map<String, dynamic>? rawData =
              result['data'] as Map<String, dynamic>?;

          if (rawData == null) {
            _errorMessage = 'Data tidak ditemukan.';
            _isLoading = false;
            return;
          }

          _laundryInfo =
              rawData['laundry'] != null
                  ? Map<String, dynamic>.from(rawData['laundry'])
                  : null;
          if (_laundryInfo == null) {
            _errorMessage = 'Informasi penyedia laundry tidak ditemukan.';
            _isLoading = false;
            return;
          }

          final List<dynamic>? servicesData =
              rawData['services'] as List<dynamic>?;
          if (servicesData == null || servicesData.isEmpty) {
            _allLaundryServices = [];
            _errorMessage = 'Tidak ada daftar layanan yang tersedia.';
            _isLoading = false;
            return;
          }

          _allLaundryServices =
              servicesData
                  .map((dynamic item) {
                    final double harga =
                        double.tryParse(
                          item['harga_per_satuan']?.toString() ?? '',
                        ) ??
                        0.0;

                    return {
                      'harga_id': item['harga_id'] as String?,
                      'laundry_id': item['laundry_id'] as String?,
                      'layanan_id': item['layanan_id'] as String?,
                      'harga_per_satuan': harga,
                      'is_available': item['is_available'] as bool?,
                      'created_at': item['created_at'] as String?,
                      'updated_at': item['updated_at'] as String?,
                      'layanan':
                          item['layanan'] != null
                              ? Map<String, dynamic>.from(item['layanan'])
                              : null,
                    }..removeWhere((key, value) => value == null);
                  })
                  .cast<Map<String, dynamic>>()
                  .toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat layanan laundry.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading laundry services: $e");
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleAddToCart(
    String hargaId,
    String layananId,
    String serviceName,
    double hargaPerSatuan,
    String satuan,
  ) {
    int quantity = 1;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Kuantitas untuk $serviceName ($satuan)',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () {
                        if (quantity > 1) {
                          setModalState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        setModalState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D9DAB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  setState(() {
                    if (_selectedItems.containsKey(hargaId)) {
                      _selectedItems.update(hargaId, (value) {
                        value['jumlah'] += quantity;
                        return value;
                      });
                    } else {
                      _selectedItems[hargaId] = {
                        'harga_id': hargaId,
                        'layanan_id': layananId,
                        'nama': '$serviceName ($satuan)',
                        'harga': hargaPerSatuan,
                        'jumlah': quantity,
                        'satuan': satuan,
                      };
                    }
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$quantity x $serviceName ($satuan) berhasil ditambahkan!',
                        ),
                        backgroundColor: const Color(0xFF0B8FAC),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  });
                },
                child: Text(
                  'Tambahkan ke Keranjang',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            children: [
              _buildHeader(context),
              if (_laundryInfo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    'Layanan dari ${_laundryInfo!['nama_laundry'] ?? 'Laundry'}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : _errorMessage != null
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error: $_errorMessage',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadLaundryServices,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                        : _allLaundryServices.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: _allLaundryServices.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final serviceItem = _allLaundryServices[index];
                            final String namaLayanan =
                                serviceItem['layanan']?['nama_layanan'] ??
                                'Layanan';
                            final String satuan =
                                serviceItem['layanan']?['satuan'] ?? 'unit';
                            final double hargaPerSatuan =
                                serviceItem['harga_per_satuan'] as double;

                            return _LaundryItemCard(
                              hargaId: serviceItem['harga_id'] as String,
                              layananId: serviceItem['layanan_id'] as String,
                              name: namaLayanan,
                              service: 'Harga per $satuan',
                              price: hargaPerSatuan.toStringAsFixed(0),
                              satuan: satuan,
                              onAddToCart:
                                  (
                                    hargaId,
                                    layananId,
                                    serviceName,
                                    hargaPerSatuan,
                                    satuan,
                                  ) => _handleAddToCart(
                                    hargaId,
                                    layananId,
                                    serviceName,
                                    hargaPerSatuan,
                                    satuan,
                                  ),
                            );
                          },
                        ),
              ),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Layanan Laundry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (_laundryInfo != null)
                    ? _laundryInfo!['nama_laundry'] ?? 'Memuat...'
                    : 'Memuat...', // Akses sebagai Map
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () {
                    Get.to(
                      () => LaundryOrderHistoryScreen(
                        reservasiId: widget.reservasiId,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/icon_laundry.png',
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.local_laundry_service,
                        color: Colors.white,
                        size: 40,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_laundry_service,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak ada layanan laundry tersedia saat ini.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: const Offset(0.5, 0.5),
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Silakan coba lagi nanti atau hubungi pengelola.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            final List<Map<String, dynamic>> itemsToSend =
                _selectedItems.values.toList();

            if (itemsToSend.isEmpty) {
              Get.snackbar(
                'Keranjang Kosong',
                'Tambahkan layanan laundry ke keranjang sebelum melanjutkan.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orangeAccent,
                colorText: Colors.white,
              );
              return;
            }

            Get.to(
              () => PemesananLaundryScreen(
                reservasiId: widget.reservasiId,
                laundryId: widget.laundryId,
                orderItems: itemsToSend,
                totalAmount: itemsToSend.fold(
                  0.0,
                  (sum, item) =>
                      sum + (item['harga'] as double) * (item['jumlah'] as int),
                ),
                qrisImage: _laundryInfo?['qris_image'] as String?,
                rekeningInfo:
                    _laundryInfo?['rekening_info'] as Map<String, dynamic>?,
              ),
            );
            // ------------------------------------------------
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF119DB0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
          child: Text(
            'Lanjutkan Pemesanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// --- Laundry Item Card Widget ---
class _LaundryItemCard extends StatelessWidget {
  final String hargaId;
  final String layananId;
  final String name;
  final String service;
  final String price;
  final String satuan;
  // imagePath dihilangkan dari konstruktor

  final Function(
    String hargaId,
    String layananId,
    String serviceName,
    double hargaPerSatuan,
    String satuan,
  )
  onAddToCart;

  const _LaundryItemCard({
    required this.hargaId,
    required this.layananId,
    required this.name,
    required this.service,
    required this.price,
    required this.satuan,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Kontainer untuk ikon generik
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey[200], // Background abu-abu
                child: Icon(
                  Icons.local_laundry_service,
                  size: 40,
                  color: Colors.grey[600],
                ), // Ikon generik
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Layanan: $service',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${price.replaceAll('RP ', '')}', // Format price
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4D9DAB),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4D9DAB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF4D9DAB), size: 24),
                onPressed: () {
                  onAddToCart(
                    hargaId,
                    layananId,
                    name,
                    double.parse(
                      price.replaceAll('Rp ', '').replaceAll('.', ''),
                    ),
                    satuan,
                  );
                },
                splashRadius: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
