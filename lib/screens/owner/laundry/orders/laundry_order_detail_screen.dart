// lib/screens/owner/laundry/orders/laundry_order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class LaundryOrderDetailScreen extends StatefulWidget {
  const LaundryOrderDetailScreen({super.key});

  @override
  State<LaundryOrderDetailScreen> createState() =>
      _LaundryOrderDetailScreenState();
}

class _LaundryOrderDetailScreenState extends State<LaundryOrderDetailScreen> {
  String? orderId;
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  String errorMessage = '';

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      orderId = arguments['order_id']?.toString();
      orderData = arguments['order_data']; // Optional cached data
    }

    if (orderData != null) {
      setState(() {
        isLoading = false;
      });
    } else {
      _loadOrderDetail();
    }
  }

  Future<void> _loadOrderDetail() async {
    if (orderId == null) {
      setState(() {
        errorMessage = 'ID pesanan tidak ditemukan';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await LaundryService.getLaundryOrderDetail(orderId!);

      if (response['status']) {
        setState(() {
          orderData = response['data'];
          isLoading = false;

          // Debug: Print data structure
          print('Order Data: ${orderData.toString()}');
          if (orderData!['items'] != null) {
            print('Items: ${orderData!['items']}');
          }
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat detail pesanan';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order detail: $e'); // Debug
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    if (orderId == null) return;

    try {
      final response = await LaundryService.updateLaundryOrderStatus(orderId!, {
        'status': newStatus,
      });

      if (response['status']) {
        Get.snackbar(
          'Berhasil',
          'Status pesanan berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Update local data
        if (orderData != null) {
          setState(() {
            orderData!['status'] = newStatus;
          });
        }

        // Return true to indicate changes
        Get.back(result: true);
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal memperbarui status',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showStatusUpdateDialog() {
    if (orderData == null) return;

    final currentStatus = orderData!['status'] ?? '';
    final availableStatuses = _getAvailableStatuses(currentStatus);

    if (availableStatuses.isEmpty) {
      Get.snackbar(
        'Info',
        'Tidak ada status yang dapat diubah untuk pesanan ini',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah Status Pesanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              availableStatuses.map((status) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _getStatusDisplayName(status),
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                  onTap: () {
                    Get.back();
                    _updateOrderStatus(status);
                  },
                );
              }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'PENDING':
        return ['DIPROSES'];
      case 'DIPROSES':
        return ['DITERIMA'];
      case 'DITERIMA':
        return [];
      default:
        return ['DIPROSES'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9EBFED),
      body: SafeArea(
        child: Column(
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
                        size: 20,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Detail Pesanan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: _loadOrderDetail,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for status update
      floatingActionButton:
          orderData != null && _canUpdateStatus(orderData!['status'])
              ? FloatingActionButton.extended(
                onPressed: _showStatusUpdateDialog,
                backgroundColor: const Color(0xFF9EBFED),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text(
                  'Update Status',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              )
              : null,
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (orderData == null) {
      return const Center(child: Text('Data pesanan tidak ditemukan'));
    }

    final user = orderData!['user'] as Map<String, dynamic>? ?? {};
    final laundry = orderData!['laundry'] as Map<String, dynamic>? ?? {};
    final items = orderData!['items'] as List? ?? [];
    final payment = orderData!['payment'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderData!['order_id']}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(orderData!['created_at']),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(orderData!['status']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(orderData!['status']),
                      size: 16,
                      color: _getStatusColor(orderData!['status']),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusDisplayName(orderData!['status']),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(orderData!['status']),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Customer Information
          _buildSectionCard('Informasi Customer', Icons.person, Colors.blue, [
            _buildInfoRow('Nama', user['full_name'] ?? 'Tidak diketahui'),
            _buildInfoRow('No. Telepon', user['phone'] ?? 'Tidak diketahui'),
            _buildInfoRow(
              'WhatsApp',
              user['whatsapp_number'] ?? 'Tidak diketahui',
            ),
          ]),
          const SizedBox(height: 20),

          // Laundry Information
          _buildSectionCard(
            'Informasi Laundry',
            Icons.local_laundry_service,
            Colors.green,
            [
              _buildInfoRow(
                'Nama Laundry',
                laundry['nama_laundry'] ?? 'Tidak diketahui',
              ),
              _buildInfoRow('Alamat', laundry['alamat'] ?? 'Tidak diketahui'),
              _buildInfoRow(
                'WhatsApp',
                laundry['whatsapp_number'] ?? 'Tidak diketahui',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Order Items
          _buildSectionCard(
            'Detail Pesanan',
            Icons.shopping_cart,
            Colors.orange,
            [
              if (items.isEmpty)
                const Text('Tidak ada detail pesanan')
              else
                ...items.map((item) => _buildOrderItemDetail(item)).toList(),
            ],
          ),
          const SizedBox(height: 20),

          // Payment Information
          // Di bagian Payment Information, ubah menjadi:
          _buildSectionCard('Informasi Pembayaran', Icons.payment, Colors.purple, [
            _buildInfoRow(
              'Total Estimasi',
              'Rp ${_formatCurrency(_parseDouble(orderData!['total_estimasi']))}',
            ),
            if (orderData!['total_final'] != null)
              _buildInfoRow(
                'Total Final',
                'Rp ${_formatCurrency(_parseDouble(orderData!['total_final']))}',
              ),
            if (orderData!['berat_actual'] != null)
              _buildInfoRow(
                'Berat Aktual',
                '${_parseDouble(orderData!['berat_actual']).toStringAsFixed(1)} kg',
              ),
            if (payment != null) ...[
              _buildInfoRow(
                'Metode Pembayaran',
                payment['metode'] ?? 'Tidak diketahui',
              ),
              _buildInfoRow(
                'Status Pembayaran',
                _getPaymentStatusDisplayName(payment['status']),
              ),
              if (payment['bukti_bayar'] != null &&
                  payment['bukti_bayar'].toString().isNotEmpty)
                _buildInfoRow('Bukti Pembayaran', 'Tersedia'),
              if (payment['verified_at'] != null)
                _buildInfoRow(
                  'Verifikasi',
                  _formatDateTime(payment['verified_at']),
                ),
            ],
          ]),
          const SizedBox(height: 20),

          // Additional Information
          if (orderData!['tanggal_antar'] != null ||
              orderData!['estimasi_selesai'] != null ||
              orderData!['catatan'] != null) ...[
            _buildSectionCard('Informasi Tambahan', Icons.info, Colors.teal, [
              if (orderData!['tanggal_antar'] != null)
                _buildInfoRow(
                  'Tanggal Antar',
                  _formatDateTime(orderData!['tanggal_antar']),
                ),
              if (orderData!['estimasi_selesai'] != null)
                _buildInfoRow(
                  'Estimasi Selesai',
                  _formatDateTime(orderData!['estimasi_selesai']),
                ),
              if (orderData!['catatan'] != null &&
                  orderData!['catatan'].toString().isNotEmpty)
                _buildInfoRow('Catatan', orderData!['catatan']),
            ]),
            const SizedBox(height: 80), // Space for FAB
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemDetail(Map<String, dynamic> item) {
    // Sesuaikan dengan struktur database: detail_pesanan_laundry
    final layananId = item['layanan_id'];

    // Konversi ke double untuk menghindari error tipe data
    final jumlahSatuan = _parseDouble(item['jumlah_satuan']);
    final hargaPerSatuan = _parseDouble(item['harga_per_satuan']);
    final subtotal = jumlahSatuan * hargaPerSatuan;

    // Data layanan dari master_layanan_laundry
    final layanan =
        item['master_layanan_laundry'] as Map<String, dynamic>? ?? {};
    final namaLayanan = layanan['nama_layanan'] ?? 'Cuci';
    final satuan = layanan['satuan'] ?? 'unit';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  namaLayanan,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Rp ${_formatCurrency(subtotal)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Jumlah: ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${jumlahSatuan.toStringAsFixed(0)} $satuan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              
            ],
          ),
          Row(
            children: [
          Text(
            'Harga: ',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            'Rp ${_formatCurrency(hargaPerSatuan)}/$satuan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'DIPROSES':
        return Colors.blue;
      case 'DITERIMA':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'DIPROSES':
        return Icons.autorenew;
      case 'DITERIMA':
        return Icons.check_circle;

      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDisplayName(String? status) {
    switch (status) {
      case 'PENDING':
        return 'Menunggu';
      case 'DIPROSES':
        return 'Diproses';
      case 'DITERIMA':
        return 'Selesai';

      default:
        return 'Tidak Diketahui';
    }
  }

  String _getPaymentStatusDisplayName(String? status) {
    switch (status) {
      case 'PENDING':
        return 'Menunggu Pembayaran';
      case 'VERIFIED':
        return 'Terverifikasi';
      case 'REJECT':
        return 'Gagal';
      default:
        return 'Tidak Diketahui';
    }
  }

  bool _canUpdateStatus(String? status) {
    return status == 'PENDING' || status == 'DIPROSES';
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Tidak diketahui';
    try {
      final date = DateTime.parse(dateTime.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Tidak diketahui';
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';

    double value = _parseDouble(amount);

    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
