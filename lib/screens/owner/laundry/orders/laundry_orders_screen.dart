// lib/screens/owner/laundry/orders/laundry_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/screens/owner/laundry/orders/laundry_order_detail_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/laundry_service.dart';

class LaundryOrdersScreen extends StatefulWidget {
  final bool showAll; // Kept for potential future use or old navigation

  const LaundryOrdersScreen({super.key, this.showAll = false});

  @override
  State<LaundryOrdersScreen> createState() => _LaundryOrdersScreenState();
}

class _LaundryOrdersScreenState extends State<LaundryOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? kostData;
  String? initialLaundryFilterId; // Stores the laundryId passed in arguments

  Map<String, dynamic>?
  _selectedLaundryForOrders; // The actual laundry object selected
  List<dynamic> _availableLaundries = []; // List of laundries for selection

  List<dynamic> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  // Status filters berdasarkan backend schema
  final List<String> statusTabs = ['Pending', 'Proses', 'Diterima'];
  final Map<String, String> statusMapping = {
    'Pending': 'PENDING',
    'Proses': 'PROSES',
    'Diterima': 'DITERIMA',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    kostData = arguments['kost_data'];
    initialLaundryFilterId = arguments['laundry_filter']?.toString();

    _initializeScreenData();
  }

  Future<void> _initializeScreenData() async {
    if (kostData == null) {
      setState(() {
        errorMessage = 'Data kost tidak ditemukan.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    if (initialLaundryFilterId != null) {
      // If a specific laundryId is passed, try to load its full data
      await _loadAndSetSpecificLaundry(initialLaundryFilterId!);
      if (_selectedLaundryForOrders != null) {
        await _loadOrders(); // Load orders for this specific laundry
      }
    } else {
      // If no specific laundryId is passed, load all laundries for the kost
      // and allow selection or set default if only one exists.
      await _loadAvailableLaundriesAndSetDefault();
    }
  }

  Future<void> _loadAndSetSpecificLaundry(String laundryId) async {
    try {
      final allLaundriesResponse = await LaundryService.getLaundriesByKost(
        kostData!['kost_id'],
      );

      if (allLaundriesResponse['status'] &&
          allLaundriesResponse['data'] is List) {
        final List<dynamic> laundries = allLaundriesResponse['data'];
        final foundLaundry = laundries.firstWhereOrNull(
          (l) => l['laundry_id'] == laundryId,
        );
        if (foundLaundry != null) {
          setState(() {
            _selectedLaundryForOrders = foundLaundry;
            _availableLaundries =
                laundries; // Keep available laundries populated
          });
        } else {
          setState(() {
            errorMessage = 'Laundry dengan ID $laundryId tidak ditemukan.';
          });
        }
      } else {
        setState(() {
          errorMessage =
              allLaundriesResponse['message'] ?? 'Gagal memuat data laundry.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat memuat data laundry: $e';
      });
    } finally {
      setState(() {
        isLoading = false; // Always set false after attempting load
      });
    }
  }

  Future<void> _loadAvailableLaundriesAndSetDefault() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await LaundryService.getLaundriesByKost(
        kostData!['kost_id'],
      );
      if (response['status']) {
        setState(() {
          _availableLaundries = response['data'] ?? [];
          if (_availableLaundries.isNotEmpty) {
            _selectedLaundryForOrders =
                _availableLaundries.first; // Automatically select the first
            _loadOrders(); // Load orders for the default selected laundry
          } else {
            errorMessage =
                'Tidak ada layanan laundry yang terdaftar untuk kost ini.';
          }
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat daftar laundry.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat memuat daftar laundry: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging && _selectedLaundryForOrders != null) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    if (_selectedLaundryForOrders == null ||
        _selectedLaundryForOrders!['laundry_id'] == null) {
      // This state should ideally not be reached if _selectedLaundryForOrders is managed correctly.
      // If it is, it means no laundry is selected to view orders for.
      setState(() {
        errorMessage = 'Pilih laundry terlebih dahulu untuk melihat pesanan.';
        orders = []; // Clear previous orders
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final selectedStatus =
          statusMapping[statusTabs[_tabController.index]] ?? '';

      final response = await LaundryService.getLaundryOrdersByKost(
        kostId: kostData!['kost_id'].toString(),
        status: selectedStatus.isNotEmpty ? selectedStatus : null,
        laundryId: _selectedLaundryForOrders!['laundry_id'].toString(),
      );

      if (response['status']) {
        setState(() {
          orders = response['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Gagal memuat pesanan.';
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

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await LaundryService.updateLaundryOrderStatus(orderId, {
        'status': newStatus,
      });

      Get.back();

      final bool isSuccess = response['status'] == true;
      final String message =
          response['message']?.toString() ??
          (isSuccess
              ? 'Status berhasil diperbarui'
              : 'Gagal memperbarui status');

      if (isSuccess) {
        Get.snackbar(
          'Berhasil',
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        await _loadOrders();
      } else {
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showStatusUpdateDialog(Map<String, dynamic> order) {
    final currentStatus = order['status'] ?? '';
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
                    _updateOrderStatus(order['pesanan_id'].toString(), status);
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
        return ['PROSES'];
      case 'PROSES':
        return ['DITERIMA'];
      case 'DITERIMA':
        return [];
      default:
        return ['PROSES'];
    }
  }

  void _goToOrderDetail(Map<String, dynamic> order) {
    Get.to(
      () => const LaundryOrderDetailScreen(),
      arguments: {
        'order_id': order['pesanan_id'].toString(),
        'order_data': order, // Pass cached data
      },
    )?.then((result) {
      if (result == true) {
        _loadOrders();
      }
    });
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
                        'Pesanan Laundry', // Changed title
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (kostData != null && _selectedLaundryForOrders != null)
                        Text(
                          _selectedLaundryForOrders!['nama_laundry'] ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        )
                      else if (kostData != null)
                        Text(
                          kostData!['nama_kost'] ?? '',
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
                        Icons.refresh,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed:
                          _selectedLaundryForOrders == null
                              ? _loadAvailableLaundriesAndSetDefault
                              : _loadOrders,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.black,
                        size: 20, // Ubah dari 28 ke 20 untuk konsistensi
                      ),
                      onPressed: () => Get.to(() => SettingScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24), // Spacer after summary cards
            // Tab Bar (only visible when a laundry is selected)
            if (_selectedLaundryForOrders != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: const Color(0xFF9EBFED),
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: statusTabs.map((status) => Tab(text: status)).toList(),
                ),
              ),

            const SizedBox(height: 16),

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
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
              onPressed: _loadOrders, // Attempt to reload orders
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_selectedLaundryForOrders == null) {
      // If no laundry is selected, show the selection list
      return _buildLaundrySelectionList();
    } else {
      // If a laundry is selected, show the orders for that laundry
      List<dynamic> currentOrders;
      final selectedTabName = statusTabs[_tabController.index];
      currentOrders =
          orders
              .where(
                (order) => order['status'] == statusMapping[selectedTabName],
              )
              .toList();

      if (currentOrders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Belum ada pesanan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan akan muncul di sini ketika ada customer yang memesan',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: currentOrders.length,
          itemBuilder: (context, index) {
            final order = currentOrders[index];
            return _buildOrderCard(order);
          },
        ),
      );
    }
  }

  Widget _buildLaundrySelectionList() {
    if (_availableLaundries.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_laundry_service,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada layanan laundry yang terdaftar untuk kost ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAvailableLaundriesAndSetDefault,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _availableLaundries.length,
      itemBuilder: (context, index) {
        final laundry = _availableLaundries[index];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedLaundryForOrders = laundry;
              isLoading = true; // Set loading true before fetching orders
            });
            _loadOrders(); // Fetch orders for the newly selected laundry
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_laundry_service,
                  size: 40,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laundry['nama_laundry'] ?? 'Nama Laundry',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        laundry['alamat'] ?? 'Alamat tidak tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final user = order['user'] as Map<String, dynamic>? ?? {};
    final laundry = order['laundry'] as Map<String, dynamic>? ?? {};
    final detailPesanan = order['detail_pesanan_laundry'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _goToOrderDetail(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['pesanan_id']?.substring(0, 8) ?? 'N/A'}', // Shorten ID for display
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(order['created_at']),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order['status']),
                          size: 14,
                          color: _getStatusColor(order['status']),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusDisplayName(order['status']),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(order['status']),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Customer Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['full_name'] ?? 'Customer',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user['email'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Laundry Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_laundry_service,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      laundry['nama_laundry'] ?? 'Laundry',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Order Items Summary
              Container(
                padding: const EdgeInsets.all(12),
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
                        Text(
                          'Detail Pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${detailPesanan.length} item${detailPesanan.length > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Show max 2 items, then "dan X lainnya"
                    ...detailPesanan
                        .take(2)
                        .map((item) => _buildOrderItem(item))
                        .toList(),
                    if (detailPesanan.length > 2) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'dan ${detailPesanan.length - 2} item lainnya...',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total and Actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(order['total_final'] ?? order['total_estimasi'])}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // View Detail Button
                      OutlinedButton(
                        onPressed: () => _goToOrderDetail(order),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF9EBFED)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Detail',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF9EBFED),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Update Status Button
                      if (_canUpdateStatus(order['status'])) ...[
                        ElevatedButton(
                          onPressed: () => _showStatusUpdateDialog(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9EBFED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Update',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Payment Info (if available)
              if (order['pembayaran'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Bukti pembayaran tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Delivery Info (if available)
              if (order['estimasi_selesai'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estimasi selesai: ${_formatDateTime(order['estimasi_selesai'])}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final layanan = item['layanan'] as Map<String, dynamic>? ?? {};
    final jumlahSatuan = _parseDouble(item['jumlah_satuan']).toInt();
    final hargaPerSatuan = _parseDouble(item['harga_per_satuan']);
    final subtotal = jumlahSatuan * hargaPerSatuan;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              layanan['nama_layanan'] ?? 'Layanan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$jumlahSatuan ${layanan['satuan'] ?? ''}',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${_formatCurrency(subtotal)}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
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

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'PROSES':
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
      case 'PROSES':
        return 'Diproses';
      case 'DITERIMA':
        return 'Selesai';
      default:
        return 'Tidak Diketahui';
    }
  }

  bool _canUpdateStatus(String? status) {
    return status == 'PENDING' || status == 'PROSES';
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
