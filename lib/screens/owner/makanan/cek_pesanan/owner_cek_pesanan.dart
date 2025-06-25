// lib/screens/owner/makanan/cek_pesanan/owner_cek_pesanan.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/models/catering_order_model.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/services/catering_menu_service.dart';
import 'package:kosan_euy/models/catering_model.dart';
import 'package:kosan_euy/routes/app_pages.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull

class OwnerCekPesanan extends StatefulWidget {
  const OwnerCekPesanan({super.key});

  @override
  State<OwnerCekPesanan> createState() => _OwnerCekPesananState();
}

class _OwnerCekPesananState extends State<OwnerCekPesanan>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CateringOrder> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _kostData;

  String? initialCateringFilterId; // Stores the cateringId passed in arguments
  Catering? _selectedCateringForOrders; // The actual catering object selected
  List<Catering> _availableCaterings = []; // List of caterings for selection

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    _kostData = arguments['kost_data'];
    initialCateringFilterId = arguments['catering_filter']?.toString();

    _initializeScreenData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreenData() async {
    if (_kostData == null) {
      setState(() {
        _errorMessage = 'Data kost tidak ditemukan.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch all caterings for the current kost first.
      // This list will be used for selection if no specific catering is provided,
      // or to find the specific catering if initialCateringFilterId is present.
      final allCateringsResponse = await CateringMenuService.getCateringsByKost(
        _kostData!['kost_id'],
      );

      if (allCateringsResponse['status'] &&
          allCateringsResponse['data'] is List<Catering>) {
        _availableCaterings = allCateringsResponse['data'];

        if (initialCateringFilterId != null) {
          // If a specific cateringId was passed, find it in the list
          final foundCatering = _availableCaterings.firstWhereOrNull(
            (c) => c.cateringId == initialCateringFilterId,
          );

          if (foundCatering != null) {
            _selectedCateringForOrders = foundCatering;
            await _fetchOrders(); // Fetch orders for this specific catering
          } else {
            // Specific catering not found, clear selection and show error/list
            _errorMessage =
                'Catering dengan ID ${initialCateringFilterId} tidak ditemukan.';
            _selectedCateringForOrders = null; // Ensure it's null
          }
        } else {
          // No specific catering ID, try to set the first one as default
          if (_availableCaterings.isNotEmpty) {
            _selectedCateringForOrders = _availableCaterings.first;
            await _fetchOrders(); // Load orders for the default selected catering
          } else {
            _errorMessage =
                'Tidak ada layanan catering yang terdaftar untuk kost ini.';
          }
        }
      } else {
        _errorMessage =
            allCateringsResponse['message'] ?? 'Gagal memuat data catering.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat inisialisasi data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableCateringsAndSetDefault() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await CateringMenuService.getCateringsByKost(
        _kostData!['kost_id'],
      );
      if (response['status']) {
        setState(() {
          _availableCaterings = response['data'] ?? [];
          if (_availableCaterings.isNotEmpty) {
            _selectedCateringForOrders =
                _availableCaterings.first; // Automatically select the first
            _fetchOrders(); // Load orders for the default selected catering
          } else {
            _errorMessage =
                'Tidak ada layanan catering yang terdaftar untuk kost ini.';
          }
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Gagal memuat daftar catering.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat daftar catering: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging && _selectedCateringForOrders != null) {
      _fetchOrders();
    }
  }

  Future<void> _fetchOrders() async {
    // Crucial check: Ensure a catering is selected before attempting to fetch orders
    if (_selectedCateringForOrders == null ||
        _selectedCateringForOrders!.cateringId.isEmpty) {
      setState(() {
        _errorMessage = 'Pilih catering terlebih dahulu untuk melihat pesanan.';
        _allOrders = []; // Clear previous orders
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await CateringMenuService.getCateringOrders(
        cateringId:
            _selectedCateringForOrders!
                .cateringId, // Use the selected catering's ID
        status: _getOrdersByStatusString(_tabController.index),
      );

      if (response['status']) {
        setState(() {
          _allOrders = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load orders.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  String _getOrdersByStatusString(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'PENDING';
      case 1:
        return 'PROSES';
      case 2:
        return 'DITERIMA';
      default:
        return '';
    }
  }

  List<CateringOrder> _getOrdersByStatus(String status) {
    return _allOrders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  Column(
                    children: [
                      Text(
                        'Pesanan Catering',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      if (_selectedCateringForOrders != null)
                        Text(
                          _selectedCateringForOrders!.namaCatering,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
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
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          onPressed: () {
                            if (_selectedCateringForOrders == null) {
                              _loadAvailableCateringsAndSetDefault();
                            } else {
                              _fetchOrders();
                            }
                          },
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
                            size: 20,
                          ),
                          onPressed: () => Get.to(() => SettingScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Bar (only visible when a catering is selected)
            if (_selectedCateringForOrders != null)
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
                  labelColor: const Color(0xFF91B7DE),
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Pending'),
                    Tab(text: 'Proses'),
                    Tab(text: 'Diterima'),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (initialCateringFilterId != null) {
                  // If there was an initial filter, try to reload specific
                  _initializeScreenData();
                } else {
                  // Otherwise, reload available caterings
                  _loadAvailableCateringsAndSetDefault();
                }
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_selectedCateringForOrders == null) {
      // Show catering selection list if no catering is selected
      return _buildCateringSelectionList();
    } else {
      // Show orders tabbed view for the selected catering
      return _buildOrdersTabbedView();
    }
  }

  Widget _buildCateringSelectionList() {
    // Only show "No services" message if loading is done and list is truly empty
    if (_availableCaterings.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ada layanan catering yang terdaftar untuk kost ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAvailableCateringsAndSetDefault,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableCaterings.length,
      itemBuilder: (context, index) {
        final catering = _availableCaterings[index];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedCateringForOrders = catering;
              _isLoading = true; // Set loading true before fetching orders
            });
            _fetchOrders(); // Fetch orders for the newly selected catering
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                const Icon(Icons.restaurant, size: 40, color: Colors.orange),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catering.namaCatering,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        catering.alamat,
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

  Widget _buildOrdersTabbedView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersList(_getOrdersByStatus('PENDING')),
        _buildOrdersList(_getOrdersByStatus('PROSES')),
        _buildOrdersList(_getOrdersByStatus('DITERIMA')),
      ],
    );
  }

  Widget _buildOrdersList(List<CateringOrder> orders) {
    if (orders.isEmpty) {
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
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(CateringOrder order) {
    Color statusColor;
    switch (order.status) {
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'PROSES':
        statusColor = Colors.blue;
        break;
      case 'DITERIMA':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final result = await Get.toNamed(
              Routes.cateringOrderDetail,
              arguments: {'orderId': order.pesananId, 'order': order},
            );
            if (result == true) {
              _fetchOrders();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.user?.fullName ?? 'Unknown User',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _formatDate(order.createdAt),
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
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
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status,
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${order.detailPesanan.length} item(s)',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatCurrency(order.totalHarga),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
