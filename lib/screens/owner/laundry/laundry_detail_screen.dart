// lib/screens/owner/laundry/laundry_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/laundry/services/laundry_services_screen.dart';
import 'package:kosan_euy/screens/owner/laundry/orders/laundry_orders_screen.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class LaundryDetailScreen extends StatefulWidget {
  const LaundryDetailScreen({super.key});

  @override
  State<LaundryDetailScreen> createState() => _LaundryDetailScreenState();
}

class _LaundryDetailScreenState extends State<LaundryDetailScreen> {
  Map<String, dynamic>? laundryData;
  Map<String, dynamic>? kostData;
  Map<String, dynamic>? servicesData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    laundryData = arguments['laundry_data'];
    kostData = arguments['kost_data'];
    _loadLaundryServices();
  }

  Future<void> _loadLaundryServices() async {
    if (laundryData == null) {
      setState(() {
        errorMessage = 'Data laundry tidak ditemukan';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await LaundryService.getLaundryServices(laundryData!['laundry_id']);

      if (response['status']) {
        setState(() {
          servicesData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat data layanan';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
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
                    'Detail Laundry',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: Container(
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
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLaundryServices,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLaundryInfo(),
          const SizedBox(height: 24),
          _buildPaymentInfo(),
          const SizedBox(height: 24),
          _buildServicesInfo(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLaundryInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.local_laundry_service,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laundryData!['nama_laundry'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: laundryData!['is_partner'] == true
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        laundryData!['is_partner'] == true ? 'Partner' : 'Non-Partner',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: laundryData!['is_partner'] == true
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow(
            Icons.location_on,
            'Alamat',
            laundryData!['alamat'] ?? 'Tidak ada alamat',
          ),
          
          if (laundryData!['whatsapp_number'] != null &&
              laundryData!['whatsapp_number'].isNotEmpty)
            _buildInfoRow(
              Icons.phone,
              'WhatsApp',
              laundryData!['whatsapp_number'],
            ),
          
          _buildInfoRow(
            Icons.access_time,
            'Dibuat',
            _formatDateTime(laundryData!['created_at']),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // QRIS
          if (laundryData!['qris_image_url'] != null &&
              laundryData!['qris_image_url'].isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'QRIS tersedia',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                laundryData!['qris_image_url'],
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.qr_code, size: 50),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.qr_code, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Text(
                  'QRIS belum tersedia',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          
          // Rekening Info
          if (laundryData!['rekening_info'] != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ...() {
              final rekeningInfo = laundryData!['rekening_info'] as Map<String, dynamic>;
              return [
                if (rekeningInfo['bank'] != null && rekeningInfo['bank'].isNotEmpty)
                  _buildInfoRow(
                    Icons.account_balance,
                    'Bank',
                    rekeningInfo['bank'],
                  ),
                
                if (rekeningInfo['nomor'] != null && rekeningInfo['nomor'].isNotEmpty)
                  _buildInfoRow(
                    Icons.credit_card,
                    'Nomor Rekening',
                    rekeningInfo['nomor'],
                  ),
                
                if (rekeningInfo['atas_nama'] != null && rekeningInfo['atas_nama'].isNotEmpty)
                  _buildInfoRow(
                    Icons.person,
                    'Atas Nama',
                    rekeningInfo['atas_nama'],
                  ),
              ];
            }(),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesInfo() {
    final services = servicesData?['services'] as List? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Layanan Tersedia',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '${services.length} layanan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (services.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada layanan yang ditambahkan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...services.map((service) => _buildServiceItem(service)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final layanan = service['layanan'] as Map<String, dynamic>;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.cleaning_services,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layanan['nama_layanan'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Satuan: ${layanan['satuan'] ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_formatCurrency(service['harga_per_satuan'])}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: service['is_available'] == true
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  service['is_available'] == true ? 'Aktif' : 'Nonaktif',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: service['is_available'] == true
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => Get.to(
              () => const LaundryServicesScreen(),
              arguments: {
                'laundry_data': laundryData,
                'services_data': servicesData,
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9EBFED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.settings, color: Colors.white),
            label: Text(
              'Kelola Layanan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => Get.to(
              () => const LaundryOrdersScreen(),
              arguments: {
                'kost_data': kostData,
                'laundry_filter': laundryData!['laundry_id'],
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.list_alt, color: Colors.white),
            label: Text(
              'Lihat Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    
    double value;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    } else if (amount is num) {
      value = amount.toDouble();
    } else {
      return '0';
    }

    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}