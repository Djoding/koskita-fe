import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosan_euy/screens/penghuni/dashboard_kos_screen.dart';
import 'package:kosan_euy/services/order_catering_service.dart';
import 'package:kosan_euy/services/order_laundry_service.dart';

class OrderPaymentScreen extends StatefulWidget {
  final String reservasiId;
  final String? cateringId;
  final String? laundryId;
  final List<Map<String, dynamic>> orderItems;
  final double totalAmount;
  final String? qrisImage;
  final Map<String, dynamic>? rekeningInfo;

  const OrderPaymentScreen({
    super.key,
    required this.reservasiId,
    this.cateringId,
    this.laundryId,
    required this.orderItems,
    required this.totalAmount,
    this.qrisImage,
    this.rekeningInfo,
  }) : assert(
         cateringId != null || laundryId != null,
         'Either cateringId or laundryId must be provided for order payment.',
       );

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  File? _pickedImageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final OrderCateringService _orderCateringService = OrderCateringService();
  final OrderLaundryService _orderLaundryService = OrderLaundryService();

  String? _selectedPaymentMethod;
  final List<String> _availablePaymentMethods = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePaymentMethods();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _initializePaymentMethods() {
    // Tentukan metode pembayaran yang tersedia berdasarkan data yang diterima
    if (widget.qrisImage != null && widget.qrisImage!.isNotEmpty) {
      _availablePaymentMethods.add('QRIS');
    }
    // Asumsi widget.rekeningInfo sudah berisi {bank, nomor, atas_nama}
    if (_isBankInfoAvailable()) {
      _availablePaymentMethods.add('TRANSFER');
    }

    if (_availablePaymentMethods.isNotEmpty) {
      _selectedPaymentMethod = _availablePaymentMethods[0];
    } else {
      Get.snackbar(
        'Peringatan',
        'Tidak ada metode pembayaran yang tersedia untuk layanan ini.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  bool _isBankInfoAvailable() {
    return widget.rekeningInfo != null &&
        widget.rekeningInfo!['bank'] != null &&
        widget.rekeningInfo!['bank'] !=
            'Tidak Tersedia' && // Opsional: cek string "Tidak Tersedia"
        widget.rekeningInfo!['nomor'] != null &&
        widget.rekeningInfo!['nomor'] != 'Tidak Tersedia'; // Opsional
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price.round());
  }

  String _cleanImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    String cleaned = rawUrl;
    if (cleaned.startsWith('http://kost-kita.my.idhttp')) {
      cleaned = cleaned.substring('http://kost-kita.my.id'.length);
    }
    if (!cleaned.startsWith('http')) {
      cleaned = 'http://kost-kita.my.id$cleaned'; // Sesuaikan host Anda
    }
    return cleaned;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImageFile = File(image.path);
      });
    } else {
      Get.snackbar(
        'Peringatan',
        'Pemilihan bukti pembayaran dibatalkan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitPaymentProof() async {
    if (_pickedImageFile == null) {
      Get.snackbar(
        'Error',
        'Tidak ada bukti pembayaran yang dipilih.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      Get.snackbar(
        'Error',
        'Metode pembayaran belum dipilih.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final List<Map<String, dynamic>> rawItemsForService =
          widget.orderItems.map((item) {
            final int quantity =
                (item['jumlah'] is int)
                    ? item['jumlah'] as int
                    : (item['jumlah'] as num).toInt();
            return {'menu_id': item['menu_id'], 'jumlah_porsi': quantity};
          }).toList();

      final String itemsJsonString = jsonEncode(rawItemsForService);

      final List<Map<String, dynamic>> rawItemsForLaundry =
          widget.orderItems.map((item) {
            final int quantity =
                (item['jumlah'] is int)
                    ? item['jumlah'] as int
                    : (item['jumlah'] as num).toInt();
            return {
              'layanan_id': item['layanan_id'],
              'jumlah_satuan': quantity,
            };
          }).toList();

      final String itemsJsonStringLaundry = jsonEncode(rawItemsForLaundry);
      debugPrint(
        'DEBUG OrderPaymentScreen: Final items JSON string to service: $itemsJsonString',
      );
      if (widget.cateringId != null) {
        final result = await _orderCateringService
            .createCateringOrderWithPayment(
              reservasiId: widget.reservasiId,
              cateringId: widget.cateringId!,
              metodeBayar: _selectedPaymentMethod!,
              catatan:
                  _notesController.text.isEmpty
                      ? 'Pesanan makanan'
                      : _notesController.text,
              itemsJson: itemsJsonString,
              buktiBayarFile: _pickedImageFile!,
            );

        if (result['status'] == true) {
          Get.snackbar(
            'Sukses!',
            result['message'] ?? 'Pesanan makanan berhasil dibuat.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          _showSuccessDialogAndNavigate(
            message:
                result['message'] ??
                'Pembayaran makanan berhasil diunggah. Mohon tunggu verifikasi.',
          );
        } else {
          Get.snackbar(
            'Gagal',
            result['message'] ??
                'Gagal membuat pesanan makanan. Mohon coba lagi.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (widget.laundryId != null) {
        final result = await _orderLaundryService.createOrderLaundryWithPayment(
          reservasiId: widget.reservasiId,
          laundryId: widget.laundryId!,
          metodeBayar: _selectedPaymentMethod!,
          catatan:
              _notesController.text.isEmpty
                  ? 'Pesanan laundry'
                  : _notesController.text,
          itemsJson: itemsJsonStringLaundry,
          buktiBayarFile: _pickedImageFile!,
        );

        if (result['status'] == true) {
          Get.snackbar(
            'Sukses!',
            result['message'] ?? 'Pesanan laundry berhasil dibuat.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          _showSuccessDialogAndNavigate(
            message:
                result['message'] ??
                'Pembayaran laundry berhasil diunggah. Mohon tunggu verifikasi.',
          );
        } else {
          Get.snackbar(
            'Gagal',
            result['message'] ??
                'Gagal membuat pesanan laundry. Mohon coba lagi.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Tipe order tidak valid (bukan catering atau laundry).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error submitting payment proof: $e");
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat mengunggah bukti pembayaran: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isUploading = false;
        _pickedImageFile = null;
      });
    }
  }

  void _showSuccessDialogAndNavigate({required String message}) {
    Get.defaultDialog(
      title: "Pembayaran Berhasil!",
      titleStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.green[700],
      ),
      content: Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
          SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.offAll(
                () => const KosScreen(),
              ); // Sesuaikan navigasi setelah pembayaran sukses
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF119DB1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text('Oke', style: GoogleFonts.poppins(fontSize: 16)),
          ),
        ],
      ),
      barrierDismissible: false,
      radius: 15.0,
      contentPadding: EdgeInsets.all(20.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String qrisUrlToDisplay =
        widget.qrisImage != null && widget.qrisImage!.isNotEmpty
            ? _cleanImageUrl(widget.qrisImage)
            : 'https://i.stack.imgur.com/yvS1s.png';
    final String bankName = widget.rekeningInfo?['bank'] ?? 'Tidak Tersedia';
    final String accountNumber =
        widget.rekeningInfo?['nomor'] ?? 'Tidak Tersedia';
    final String accountName =
        widget.rekeningInfo?['atas_nama'] ?? 'Tidak Tersedia';

    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Text(
              'Pilih Metode Pembayaran\nDibawah Ini...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  _buildDetailPembayaranCard(context),
                  const SizedBox(height: 20),
                  _buildPaymentMethodDropdown(),
                  const SizedBox(height: 20),
                  if (_selectedPaymentMethod == 'TRANSFER' &&
                      _availablePaymentMethods.contains('TRANSFER'))
                    _buildBankInfoCard(bankName, accountNumber, accountName),
                  if (_selectedPaymentMethod == 'QRIS' &&
                      _availablePaymentMethods.contains('QRIS'))
                    _buildQrisImage(qrisUrlToDisplay),
                  const SizedBox(height: 20),
                  if (_pickedImageFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Text(
                            'Bukti Pembayaran Terpilih:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Image.file(
                            _pickedImageFile!,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF119DB1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Pilih Bukti Bayar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isUploading || _pickedImageFile == null
                          ? null
                          : _submitPaymentProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 5,
                  ),
                  child:
                      _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Unggah Bukti Bayar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.9 * 255).toInt()),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 22,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDetailPembayaranCard(BuildContext context) {
    String purposeDescription;
    if (widget.cateringId != null) {
      purposeDescription = 'Pembayaran Pesanan Makanan';
    } else if (widget.laundryId != null) {
      purposeDescription = 'Pembayaran Pesanan Laundry';
    } else {
      purposeDescription = 'Pembayaran Order';
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pembayaran',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  purposeDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (widget.orderItems.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Item:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.orderItems.map((item) {
                    final String itemName = item['nama'] ?? 'Item';
                    final int itemQuantity = item['jumlah'] ?? 0;
                    final double itemPrice = item['harga'] ?? 0.0;
                    final double subtotal = itemQuantity * itemPrice;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$itemQuantity x $itemName',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatPrice(subtotal),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 15),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
                Text(
                  _formatPrice(
                    widget.totalAmount,
                  ), // Gunakan totalAmount dari widget
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4D9DAB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Reservasi ID: ${widget.reservasiId}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
            if (widget.cateringId != null) const SizedBox(height: 5),
            if (widget.cateringId != null)
              Text(
                'Catering ID: ${widget.cateringId}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            if (widget.laundryId != null) const SizedBox(height: 5),
            if (widget.laundryId != null)
              Text(
                'Laundry ID: ${widget.laundryId}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    if (_availablePaymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Pilih Metode',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items:
                  _availablePaymentMethods.map((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoCard(
    String bankName,
    String accountNumber,
    String accountName,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Transfer Bank',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            _buildDetailRow(
              label: 'Bank',
              value: bankName,
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              valueStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: 'Nomor Rekening',
              value: accountNumber,
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              valueStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: 'Atas Nama',
              value: accountName,
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              valueStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisImage(String? imageUrl) {
    final String cleanedUrl = _cleanImageUrl(imageUrl);
    if (cleanedUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool isAsset = cleanedUrl.startsWith('assets/');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pembayaran QRIS',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey[800],
              ),
            ),
            const Divider(height: 25, thickness: 1.5, color: Colors.grey),
            isAsset
                ? Image.asset(
                  cleanedUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildErrorImagePlaceholder(size: 250),
                )
                : Image.network(
                  cleanedUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 250,
                      height: 250,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildErrorImagePlaceholder(size: 250),
                ),
            const SizedBox(height: 10),
            Text(
              'Scan QRIS ini untuk pembayaran',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                valueStyle ??
                GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorImagePlaceholder({double size = 200}) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(Icons.broken_image, size: size / 2.5, color: Colors.grey),
    );
  }
}
