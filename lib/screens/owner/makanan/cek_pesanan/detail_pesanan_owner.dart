// lib/screens/owner/makanan/cek_pesanan/detail_pesanan_owner.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/services/catering_menu_service.dart'; // Import service
import 'package:kosan_euy/routes/app_pages.dart'; // For navigation
import 'package:intl/intl.dart'; // For date formatting

class DetailPesananOwner extends StatefulWidget {
  const DetailPesananOwner({super.key});

  @override
  State<DetailPesananOwner> createState() => _DetailPesananOwnerState();
}

class _DetailPesananOwnerState extends State<DetailPesananOwner> {
  Map<String, dynamic>? _orderDetail; // Raw map from backend
  bool _isLoading = true;
  String _errorMessage = '';
  String? _orderId;
  String? _pengelolaId;

  @override
  void initState() {
    super.initState();
    // Perbaikan handling arguments
    final arguments = Get.arguments;
    if (arguments != null &&
        arguments is Map<String, dynamic> &&
        arguments['orderId'] != null &&
        arguments['pengelolaId'] != null) {
      _orderId = arguments['orderId'];
      _pengelolaId = arguments['pengelolaId'];
      _fetchOrderDetail();
    } else {
      _errorMessage = 'Order ID or Pengelola ID not found.';
      _isLoading = false;
    }
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await CateringMenuService.getCateringOrderDetail(
        orderId: _orderId!,
        pengelolaId: _pengelolaId!,
      );
      if (response['status']) {
        setState(() {
          _orderDetail = response['data'];
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load order detail.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error fetching order detail: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    double value;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    } else if (amount is num) {
      value = amount.toDouble();
    } else {
      return '0';
    }
    return 'Rp ${NumberFormat.decimalPattern('id_ID').format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF91B7DE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty || _orderDetail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF91B7DE),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (_orderDetail ==
                  null) // Show refresh button only if data is truly null
                ElevatedButton(
                  onPressed: _fetchOrderDetail,
                  child: const Text('Coba Lagi'),
                ),
            ],
          ),
        ),
      );
    }

    // Parse dates safely
    final DateTime createdAt = DateTime.parse(_orderDetail!['created_at']);
    // Assuming backend does not have specific pick-up/delivery times
    final String formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(createdAt);
    final String formattedTime = DateFormat('HH:mm').format(createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
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
                    const Text(
                      'Detail Pesanan', // Changed title
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Informasi Pemesan
              const Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                  'Informasi Pemesan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.06 * 255).toInt()),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('Nama Pemesan')),
                            Text(
                              _orderDetail!['user']?['full_name'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(child: Text('Email')),
                            Text(
                              _orderDetail!['user']?['email'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(child: Text('Status Pesanan')),
                            Text(
                              _orderDetail!['status'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(child: Text('Tanggal Pesanan')),
                            Text(formattedDate),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(child: Text('Jam Pesanan')),
                            Text('$formattedTime WIB'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(child: Text('Catatan')),
                            Expanded(
                              child: Text(
                                _orderDetail!['catatan'] ?? 'Tidak ada',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(child: Text('Metode Bayar')),
                            Text(
                              _orderDetail!['pembayaran']?['metode'] ?? 'N/A',
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Add Bukti Bayar if available
                        if (_orderDetail!['pembayaran']?['bukti_bayar_url'] !=
                            null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bukti Bayar:'),
                                const SizedBox(height: 4),
                                Image.network(
                                  _orderDetail!['pembayaran']['bukti_bayar_url'],
                                  height: 150,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Text(
                                            'Gagal memuat bukti bayar',
                                          ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Daftar Pesanan
              const Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                  'Daftar Menu Pesanan', // Changed title
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha((0.5 * 255).toInt()),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.06 * 255).toInt()),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...(_orderDetail!['detail_pesanan'] as List).map((
                          item,
                        ) {
                          // Extract menu data from detail_pesanan
                          final menu = item['menu'];
                          final String menuName =
                              menu?['nama_menu'] ?? 'Menu Tidak Dikenal';
                          final double hargaSatuan =
                              item['harga_satuan']?.toDouble() ?? 0.0;
                          final int jumlahPorsi = item['jumlah_porsi'] ?? 0;
                          final double totalItemHarga =
                              hargaSatuan * jumlahPorsi;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    menu?['foto_menu_url'] ??
                                        'https://via.placeholder.com/80', // Use menu image URL
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        menuName,
                                        style: const TextStyle(
                                          color:
                                              Colors.black, // Changed to black
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${jumlahPorsi}x ${_formatCurrency(hargaSatuan)}',
                                        style: const TextStyle(
                                          color: Colors.grey, // Changed to grey
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          _formatCurrency(totalItemHarga),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(
                          color: Colors.black,
                          thickness: 0.7,
                        ), // Changed to black
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'TOTAL HARGA',
                                style: TextStyle(
                                  color: Colors.black, // Changed to black
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(_orderDetail!['total_harga']),
                              style: const TextStyle(
                                color: Colors.black, // Changed to black
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        // Action button to change status
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(
                                Routes
                                    .editCateringOrderStatus, // Gunakan routes yang sudah didefinisikan
                                arguments: {
                                  'orderId': _orderDetail!['pesanan_id'],
                                  'currentStatus': _orderDetail!['status'],
                                  'pengelolaId': _pengelolaId,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF119DB0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Ubah Status Pesanan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
