// lib/screens/admin/dashboard_admin.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kosan_euy/screens/admin/notification/notification_admin.dart';
import 'package:kosan_euy/screens/admin/pengelola_detail_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/widgets/success_delete_screen.dart';
import 'package:kosan_euy/widgets/success_screen.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data - replace with actual API calls
  final List<Map<String, dynamic>> _pendingPengelola = [
    {
      'id': '1',
      'nama': 'John Doe',
      'email': 'john@example.com',
      'namaKost': 'Kost Kapling 40',
      'lokasi': 'Jl. Kapling No. 40',
      'tanggalDaftar': '2024-06-10',
      'status': 'pending',
    },
    {
      'id': '2',
      'nama': 'Jane Smith',
      'email': 'jane@example.com',
      'namaKost': 'Kost Melati',
      'lokasi': 'Jl. Melati No. 15',
      'tanggalDaftar': '2024-06-09',
      'status': 'pending',
    },
  ];

  final List<Map<String, dynamic>> _verifiedPengelola = [
    {
      'id': '3',
      'nama': 'Ahmad Sari',
      'email': 'ahmad@example.com',
      'namaKost': 'Kost Mawar',
      'lokasi': 'Jl. Mawar No. 20',
      'tanggalDaftar': '2024-06-01',
      'tanggalVerifikasi': '2024-06-02',
      'status': 'verified',
    },
  ];

  List<Map<String, dynamic>> _filterPengelola(List<Map<String, dynamic>> data) {
    if (_searchQuery.isEmpty) return data;

    return data.where((pengelola) {
      final nama = pengelola['nama'].toString().toLowerCase();
      final namaKost = pengelola['namaKost'].toString().toLowerCase();
      final lokasi = pengelola['lokasi'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return nama.contains(query) ||
          namaKost.contains(query) ||
          lokasi.contains(query);
    }).toList();
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF91B7DE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Tab Bar
            _buildTabBar(),
            // Tab Bar View
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
          // Top row with back button and stats
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
              // Statistics
              Row(
                children: [
                  
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () => Get.to(() => SettingScreen()),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Greeting and icons
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Kelola pengelola kos di sini',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(25),
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
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari pengelola, kost, atau lokasi...',
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
    final filteredData = _filterPengelola(_pendingPengelola);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                filteredData.isEmpty
                    ? _buildEmptyState(
                      'Tidak ada pengelola pending yang ditemukan',
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        return _PenggelolaCard(
                          pengelola: filteredData[index],
                          isPending: true,
                          onTap: () => _goToDetail(filteredData[index]),
                          onVerify: () => _verifyPengelola(filteredData[index]),
                          onDelete: () => _deletePengelola(filteredData[index]),
                        );
                      },
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

  Widget _buildVerifiedList() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _verifiedPengelola.length,
        itemBuilder: (context, index) {
          return _PenggelolaCard(
            pengelola: _verifiedPengelola[index],
            isPending: false,
            onTap: () => _goToDetail(_verifiedPengelola[index]),
            onDelete: () => _deletePengelola(_verifiedPengelola[index]),
          );
        },
      ),
    );
  }

  void _goToDetail(Map<String, dynamic> pengelola) {
    Get.to(() => PenggelolaDetailScreen(pengelola: pengelola));
  }

  void _verifyPengelola(Map<String, dynamic> pengelola) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Verifikasi Pengelola',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin memverifikasi ${pengelola['nama']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    pengelola['status'] = 'verified';
                    pengelola['tanggalVerifikasi'] =
                        DateTime.now().toString().split(' ')[0];
                    _verifiedPengelola.add(pengelola);
                    _pendingPengelola.remove(pengelola);
                  });
                  Get.to(
                    () => SuccessScreen(
                      title: 'Pengelola berhasil diverifikasi',
                      subtitle: '${pengelola['nama']} telah diverifikasi.',
                    ),
                  );
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

  void _deletePengelola(Map<String, dynamic> pengelola) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Hapus Pengelola',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus ${pengelola['nama']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _pendingPengelola.remove(pengelola);
                    _verifiedPengelola.remove(pengelola);
                  });
                  Get.to(
                    () => SuccessDeleteScreen(
                      title: 'Pengelola berhasil dihapus',
                    ),
                  );
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
                    child: Icon(
                      Icons.person,
                      color: isPending ? Colors.orange : Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pengelola['nama'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          pengelola['namaKost'],
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
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
              Text(
                pengelola['lokasi'],
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              Text(
                'Daftar: ${pengelola['tanggalDaftar']}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (!isPending && pengelola['tanggalVerifikasi'] != null)
                Text(
                  'Verifikasi: ${pengelola['tanggalVerifikasi']}',
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
}
