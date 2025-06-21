// lib/screens/owner/makanan/edit_pesanan/edit_status_pesanan_makanan.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/services/catering_menu_service.dart';
import 'package:kosan_euy/models/catering_order_model.dart';

class EditStatusPesananMakananScreen extends StatefulWidget {
  const EditStatusPesananMakananScreen({super.key});

  @override
  State<EditStatusPesananMakananScreen> createState() =>
      _EditStatusPesananMakananScreenState();
}

class _EditStatusPesananMakananScreenState
    extends State<EditStatusPesananMakananScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _orderId;
  String? _currentStatus;
  String? _selectedStatus;
  CateringOrder? _order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final arguments = Get.arguments;
    if (arguments != null) {
      _orderId = arguments['orderId'];
      _currentStatus = arguments['currentStatus'];
      _order = arguments['order'];
      _selectedStatus = _currentStatus;
    } else {
      Get.snackbar('Error', 'Order data not found.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }
  }

  List<String> _getAvailableStatuses() {
    switch (_currentStatus) {
      case 'PENDING':
        return ['PENDING', 'PROSES'];
      case 'PROSES':
        return ['PROSES', 'DITERIMA'];
      case 'DITERIMA':
        return ['DITERIMA'];
      default:
        return ['PENDING', 'PROSES', 'DITERIMA'];
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'PENDING':
        return 'Menunggu Konfirmasi';
      case 'PROSES':
        return 'Sedang Diproses';
      case 'DITERIMA':
        return 'Selesai/Diterima';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'PROSES':
        return Colors.blue;
      case 'DITERIMA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus() async {
    if (!_formKey.currentState!.validate()) return;
    if (_orderId == null || _selectedStatus == null) {
      Get.snackbar('Error', 'Data tidak lengkap untuk memperbarui status.');
      return;
    }

    if (_selectedStatus == _currentStatus) {
      Get.snackbar('Info', 'Status tidak berubah.');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await CateringMenuService.updateOrderStatus(
        _orderId!,
        _selectedStatus!,
      );

      if (response['status']) {
        Get.back(); // Pop this screen
        Get.back(); // Pop detail screen
        Get.snackbar(
          'Sukses',
          response['message'] ?? 'Status pesanan berhasil diperbarui!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal memperbarui status pesanan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
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
                    const Spacer(),
                    Text(
                      'Edit Status Pesanan',
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
                const SizedBox(height: 32),

                // Order Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Pesanan',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Pemesan:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _order?.user?.fullName ?? 'N/A',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Total:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatCurrency(_order?.totalHarga ?? 0),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Status Saat Ini:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                _currentStatus ?? '',
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusDisplayName(_currentStatus ?? ''),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(_currentStatus ?? ''),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Status Selection
                Text(
                  'Pilih Status Baru',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      hint: Text(
                        'Pilih Status',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      items:
                          _getAvailableStatuses().map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _getStatusDisplayName(status),
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Status Flow Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alur Status Pesanan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. PENDING → Pesanan masuk, menunggu konfirmasi\n'
                        '2. PROSES → Pesanan dikonfirmasi, sedang diproses\n'
                        '3. DITERIMA → Pesanan selesai dan sudah diterima',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isUpdating ? Colors.grey : const Color(0xFF119DB0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        _isUpdating
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              'Perbarui Status',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
