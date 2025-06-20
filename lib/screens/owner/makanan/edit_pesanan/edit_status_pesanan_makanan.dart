// lib/screens/owner/makanan/edit_pesanan/edit_status_pesanan_makanan.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/services/catering_menu_service.dart';
import '../../../../widgets/success_screen.dart';

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
  String? _pengelolaId;
  String? _selectedStatus; // New state for dropdown
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      _orderId = Get.arguments['orderId'];
      _currentStatus = Get.arguments['currentStatus'];
      _pengelolaId = Get.arguments['pengelolaId'];
      _selectedStatus =
          _currentStatus; // Initialize dropdown with current status
    } else {
      Get.snackbar('Error', 'Order ID or current status not found.');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }
  }

  Future<void> _updateStatus() async {
    if (!_formKey.currentState!.validate()) return;
    if (_orderId == null || _selectedStatus == null || _pengelolaId == null) {
      Get.snackbar('Error', 'Data tidak lengkap untuk memperbarui status.');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await CateringMenuService.updateCateringOrderStatus(
        orderId: _orderId!,
        status: _selectedStatus!,
        pengelolaId: _pengelolaId!,
      );

      if (response['status']) {
        Get.back(); // Pop this screen
        Get.snackbar(
          'Sukses',
          response['message'] ?? 'Status pesanan berhasil diperbarui!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to a success screen or refresh previous detail screen
        Get.off(
          () => const SuccessScreen(
            title: 'Status Berhasil Diperbarui',
            subtitle: 'Status pesanan catering berhasil diubah.',
          ),
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
                // Tombol back
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
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Edit Status Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Dropdown untuk status
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status Pemesanan',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                    DropdownMenuItem(value: 'PROSES', child: Text('PROSES')),
                    DropdownMenuItem(
                      value: 'DITERIMA',
                      child: Text('DITERIMA'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
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
                              : const Text(
                                'Perbarui',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
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
}
