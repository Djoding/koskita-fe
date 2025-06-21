// lib/screens/owner/laundry/services/laundry_services_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/laundry/services/add_edit_service_screen.dart';
import 'package:kosan_euy/services/laundry_service.dart';
import 'package:kosan_euy/widgets/success_screen.dart';

class LaundryServicesScreen extends StatefulWidget {
  const LaundryServicesScreen({super.key});

  @override
  State<LaundryServicesScreen> createState() => _LaundryServicesScreenState();
}

class _LaundryServicesScreenState extends State<LaundryServicesScreen> {
  Map<String, dynamic>? laundryData;
  Map<String, dynamic>? servicesData;
  List<dynamic> services = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    laundryData = arguments['laundry_data'];
    servicesData = arguments['services_data'];
    _loadServices();
  }

  void _loadServices() {
    if (servicesData != null && servicesData!['services'] != null) {
      setState(() {
        services = servicesData!['services'] as List;
      });
    }
  }

  Future<void> _refreshServices() async {
    if (laundryData == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await LaundryService.getLaundryServices(
        laundryData!['laundry_id'],
      );

      if (response['status']) {
        setState(() {
          servicesData = response['data'];
          services = servicesData!['services'] as List? ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal memuat layanan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> service) {
    final layanan = service['layanan'] as Map<String, dynamic>;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Layanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus layanan ${layanan['nama_layanan']}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteService(service);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(Map<String, dynamic> service) async {
    if (laundryData == null) return;

    final layanan = service['layanan'] as Map<String, dynamic>;

    try {
      final response = await LaundryService.deleteLaundryService(
        laundryData!['laundry_id'],
        layanan['layanan_id'],
      );

      if (response['status']) {
        Get.to(
          () => const SuccessScreen(
            title: 'Layanan Berhasil Dihapus',
            subtitle: 'Layanan telah dihapus dari daftar',
          ),
        );
        _refreshServices();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Gagal menghapus layanan',
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
                  Column(
                    children: [
                      Text(
                        'Kelola Layanan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (laundryData != null)
                        Text(
                          laundryData!['nama_laundry'] ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
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
                        Icons.add,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () async {
                        final result = await Get.to(
                          () => const AddEditServiceScreen(),
                          arguments: {
                            'laundry_data': laundryData,
                            'is_edit': false,
                          },
                        );
                        if (result == true) {
                          _refreshServices();
                        }
                      },
                    ),
                  ),
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
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildServicesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cleaning_services_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada layanan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan layanan laundry untuk mulai menerima pesanan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Get.to(
                  () => const AddEditServiceScreen(),
                  arguments: {'laundry_data': laundryData, 'is_edit': false},
                );
                if (result == true) {
                  _refreshServices();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9EBFED),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Tambah Layanan',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final layanan = service['layanan'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    color: Colors.green,
                    size: 28,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Satuan: ${layanan['satuan'] ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Get.to(
                          () => const AddEditServiceScreen(),
                          arguments: {
                            'laundry_data': laundryData,
                            'service_data': service,
                            'is_edit': true,
                          },
                        )?.then((result) {
                          if (result == true) {
                            _refreshServices();
                          }
                        });
                        break;
                      case 'delete':
                        _showDeleteConfirmation(service);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              Text('Edit', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Text('Hapus', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(service['harga_per_satuan'])}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        service['is_available'] == true
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        service['is_available'] == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color:
                            service['is_available'] == true
                                ? Colors.green[700]
                                : Colors.red[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        service['is_available'] == true ? 'Aktif' : 'Nonaktif',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              service['is_available'] == true
                                  ? Colors.green[700]
                                  : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
