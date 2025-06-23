// lib/screens/admin/dashboard_admin.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/admin/pengelola_detail_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/widgets/success_delete_screen.dart';
import 'package:kosan_euy/widgets/success_screen.dart';
import 'package:kosan_euy/services/admin_service.dart';
import 'package:kosan_euy/widgets/dialog_utils.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _pendingPengelola = [];
  List<Map<String, dynamic>> _verifiedPengelola = [];
  Map<String, dynamic>? _statistics;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  int _pendingPage = 1;
  int _verifiedPage = 1;
  bool _hasMorePending = true;
  bool _hasMoreVerified = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _searchController.clear();
      _searchQuery = '';
      setState(() {});
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadPendingUsers(refresh: true),
        _loadVerifiedUsers(refresh: true),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPendingUsers({bool refresh = false}) async {
    try {
      if (refresh) {
        _pendingPage = 1;
        _hasMorePending = true;
      }

      final result = await AdminService.getPendingUsers(
        page: _pendingPage,
        limit: _limit,
      );

      if (result['status']) {
        final List<dynamic> users = result['data'] ?? [];
        final pagination = result['pagination'];

        setState(() {
          if (refresh) {
            _pendingPengelola = users.cast<Map<String, dynamic>>();
          } else {
            _pendingPengelola.addAll(users.cast<Map<String, dynamic>>());
          }
          _hasMorePending = pagination['hasNext'] ?? false;
          if (!refresh) _pendingPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pending users: $e')),
        );
      }
    }
  }

  Future<void> _loadVerifiedUsers({bool refresh = false}) async {
    try {
      if (refresh) {
        _verifiedPage = 1;
        _hasMoreVerified = true;
      }

      final result = await AdminService.getVerifiedUsers(
        page: _verifiedPage,
        limit: _limit,
      );

      if (result['status']) {
        final List<dynamic> users = result['data'] ?? [];
        final pagination = result['pagination'];

        setState(() {
          if (refresh) {
            _verifiedPengelola = users.cast<Map<String, dynamic>>();
          } else {
            _verifiedPengelola.addAll(users.cast<Map<String, dynamic>>());
          }
          _hasMoreVerified = pagination['hasNext'] ?? false;
          if (!refresh) _verifiedPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading verified users: $e')),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchQuery = '';
      });
      await _loadInitialData();
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query.trim();
    });

    try {
      final result = await AdminService.searchUsers(_searchQuery);
      if (result['status']) {
        final List<dynamic> users = result['data'] ?? [];
        setState(() {
          // Filter by approval status based on current tab
          if (_tabController.index == 0) {
            // Pending tab
            _pendingPengelola =
                users
                    .where((user) => user['is_approved'] == false)
                    .cast<Map<String, dynamic>>()
                    .toList();
          } else {
            // Verified tab
            _verifiedPengelola =
                users
                    .where((user) => user['is_approved'] == true)
                    .cast<Map<String, dynamic>>()
                    .toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredUsers(
    List<Map<String, dynamic>> users,
  ) {
    if (_searchQuery.isEmpty) return users;

    return users.where((user) {
      final name = (user['full_name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final username = (user['username'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          username.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPendingList(), _buildVerifiedList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Removed back button
              const Spacer(),
              // Added Refresh button
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                onPressed: () async {
                  await _loadInitialData();
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                onPressed: () => Get.to(() => SettingScreen()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hi Admin!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola akun pengelola kos di sini',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF119DB1),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(
            child: Text(
              'Pending (${_pendingPengelola.length})',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Tab(
            child: Text(
              'Verified (${_verifiedPengelola.length})',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          if (value.trim().length >= 2 || value.trim().isEmpty) {
            _searchUsers(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Cari pengelola, nama, atau email...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    final filteredData = _getFilteredUsers(_pendingPengelola);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                _isLoading && _pendingPengelola.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _buildErrorState(_errorMessage!)
                    : filteredData.isEmpty
                    ? _buildEmptyState(
                      'Tidak ada pengelola pending yang ditemukan',
                    )
                    : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading &&
                            _hasMorePending &&
                            _searchQuery.isEmpty &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          _loadPendingUsers();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount:
                            filteredData.length +
                            (_hasMorePending && _searchQuery.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredData.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _PenggelolaCard(
                            pengelola: filteredData[index],
                            isPending: true,
                            onTap: () => _goToDetail(filteredData[index]),
                            onVerify:
                                () => _verifyPengelola(filteredData[index]),
                            onDelete:
                                () => _deletePengelola(filteredData[index]),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedList() {
    final filteredData = _getFilteredUsers(_verifiedPengelola);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                _isLoading && _verifiedPengelola.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _buildErrorState(_errorMessage!)
                    : filteredData.isEmpty
                    ? _buildEmptyState(
                      'Tidak ada pengelola verified yang ditemukan',
                    )
                    : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading &&
                            _hasMoreVerified &&
                            _searchQuery.isEmpty &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          _loadVerifiedUsers();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount:
                            filteredData.length +
                            (_hasMoreVerified && _searchQuery.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredData.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _PenggelolaCard(
                            pengelola: filteredData[index],
                            isPending: false,
                            onTap: () => _goToDetail(filteredData[index]),
                            onDelete:
                                () => _deletePengelola(filteredData[index]),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: GoogleFonts.poppins(color: Colors.red[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _goToDetail(Map<String, dynamic> pengelola) async {
    final result = await Get.to(
      () => PenggelolaDetailScreen(pengelola: pengelola),
    );

    // Refresh data if user was updated or deleted
    if (result != null) {
      if (result == 'deleted') {
        _loadInitialData();
      } else if (result is Map<String, dynamic>) {
        // User was updated, refresh the lists
        _loadInitialData();
      }
    }
  }

  void _verifyPengelola(Map<String, dynamic> pengelola) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Verifikasi Pengelola',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin memverifikasi ${pengelola['full_name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  Navigator.pop(context);

                  DialogUtils.showLoadingDialog(context, false);

                  try {
                    final result = await AdminService.approveUser(
                      pengelola['user_id'],
                      true,
                    );

                    if (!mounted) return;
                    DialogUtils.hideLoadingDialog(context);

                    if (result['status']) {
                      Get.to(
                        () => SuccessScreen(
                          title: 'Pengelola berhasil diverifikasi',
                          subtitle:
                              '${pengelola['full_name']} telah diverifikasi.',
                        ),
                      );
                      _loadInitialData(); // Auto-refresh after successful operation
                    }
                  } catch (e) {
                    if (!mounted) return;
                    DialogUtils.hideLoadingDialog(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text(
                  'Verifikasi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _deletePengelola(Map<String, dynamic> pengelola) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Hapus Pengelola',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus ${pengelola['full_name']}? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);

                  DialogUtils.showLoadingDialog(context, false);

                  try {
                    final result = await AdminService.deleteUser(
                      pengelola['user_id'],
                    );

                    if (!mounted) return;
                    DialogUtils.hideLoadingDialog(context);

                    if (result['status']) {
                      Get.to(
                        () => SuccessDeleteScreen(
                          title: '${pengelola['full_name']} berhasil dihapus',
                        ),
                      );
                      _loadInitialData(); // Auto-refresh after successful operation
                    }
                  } catch (e) {
                    if (!mounted) return;
                    DialogUtils.hideLoadingDialog(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class _PenggelolaCard extends StatelessWidget {
  final Map<String, dynamic> pengelola;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onVerify;
  final VoidCallback onDelete;

  const _PenggelolaCard({
    required this.pengelola,
    required this.isPending,
    required this.onTap,
    this.onVerify,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          isPending
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isPending ? Colors.orange : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          pengelola['avatar'] != null
                              ? NetworkImage(pengelola['avatar'])
                              : null,
                      child:
                          pengelola['avatar'] == null
                              ? Icon(
                                Icons.person,
                                color: isPending ? Colors.orange : Colors.green,
                                size: 28,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pengelola['full_name'] ?? 'Nama tidak tersedia',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          pengelola['email'] ?? 'Email tidak tersedia',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '@${pengelola['username'] ?? 'username'}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
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
                      color: isPending ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPending ? 'Pending' : 'Verified',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (pengelola['phone'] != null) ...[
                Text(
                  'Telepon: ${pengelola['phone']}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
              Text(
                'Role: ${pengelola['role']}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              Text(
                'Bergabung: ${_formatDate(pengelola['created_at'])}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (!isPending && pengelola['last_login'] != null)
                Text(
                  'Login terakhir: ${_formatDate(pengelola['last_login'])}',
                  style: GoogleFonts.poppins(color: Colors.green, fontSize: 12),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isPending && onVerify != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onVerify,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Verifikasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (isPending && onVerify != null) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tidak diketahui';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Format tanggal salah';
    }
  }
}
