import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/widgets/success_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Data pesanan berdasarkan status
  final List<Map<String, dynamic>> pesananMasuk = [
    {
      'id': 'PM001',
      'nama': 'Nella Aprilia',
      'kamar': 'Kamar No 10',
      'menu': 'Nasi Gudeg + Es Teh',
      'jumlah': 2,
      'harga': 25000,
      'waktuPesan': '10:30',
      'tanggal': '12 Juni 2025',
      'catatan': 'Extra sambal ya kak',
      'status': 'masuk',
    },
    {
      'id': 'PM002',
      'nama': 'Angelica Sharon',
      'kamar': 'Kamar No 15',
      'menu': 'Ayam Geprek + Es Jeruk',
      'jumlah': 1,
      'harga': 15000,
      'waktuPesan': '11:15',
      'tanggal': '12 Juni 2025',
      'catatan': 'Pedesnya level 2',
      'status': 'masuk',
    },
  ];

  final List<Map<String, dynamic>> pesananDiproses = [
    {
      'id': 'PD001',
      'nama': 'Putri Ayu',
      'kamar': 'Kamar No 5',
      'menu': 'Soto Ayam + Es Campur',
      'jumlah': 1,
      'harga': 18000,
      'waktuPesan': '09:45',
      'tanggal': '12 Juni 2025',
      'catatan': 'Tanpa kecap',
      'status': 'diproses',
      'estimasi': '20 menit',
    },
    {
      'id': 'PD002',
      'nama': 'Rina Sari',
      'kamar': 'Kamar No 8',
      'menu': 'Gado-gado + Teh Hangat',
      'jumlah': 2,
      'harga': 24000,
      'waktuPesan': '10:00',
      'tanggal': '12 Juni 2025',
      'catatan': 'Bumbu kacangnya banyak',
      'status': 'diproses',
      'estimasi': '15 menit',
    },
  ];

  final List<Map<String, dynamic>> pesananSelesai = [
    {
      'id': 'PS001',
      'nama': 'Maya Indah',
      'kamar': 'Kamar No 12',
      'menu': 'Rendang + Nasi + Es Teh',
      'jumlah': 1,
      'harga': 22000,
      'waktuPesan': '08:30',
      'waktuSelesai': '09:00',
      'tanggal': '12 Juni 2025',
      'catatan': 'Rendangnya empuk ya',
      'status': 'selesai',
      'metodeBayar': 'Cash',
    },
    {
      'id': 'PS002',
      'nama': 'Desi Ratnasari',
      'kamar': 'Kamar No 7',
      'menu': 'Bakso Malang + Es Jeruk',
      'jumlah': 2,
      'harga': 30000,
      'waktuPesan': '07:45',
      'waktuSelesai': '08:15',
      'tanggal': '12 Juni 2025',
      'catatan': 'Baksonya yang besar',
      'status': 'selesai',
      'metodeBayar': 'Transfer',
    },
  ];

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
                    'Layanan Makanan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Pesanan Masuk',
                      pesananMasuk.length,
                      Colors.orange,
                      Icons.inbox,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Diproses',
                      pesananDiproses.length,
                      Colors.blue,
                      Icons.hourglass_empty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Selesai',
                      pesananSelesai.length,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Bar
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
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Masuk'),
                  Tab(text: 'Diproses'),
                  Tab(text: 'Selesai'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPesananMasukTab(),
                  _buildPesananDiprosesTab(),
                  _buildPesananSelesaiTab(),
                ],
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

  // Tab Pesanan Masuk
  Widget _buildPesananMasukTab() {
    if (pesananMasuk.isEmpty) {
      return _buildEmptyState('Tidak ada pesanan masuk');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pesananMasuk.length,
      itemBuilder: (context, index) {
        final pesanan = pesananMasuk[index];
        return _buildPesananCard(
          pesanan: pesanan,
          actions: [
            ElevatedButton(
              onPressed: () => _tolakPesanan(pesanan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Tolak', style: GoogleFonts.poppins(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _terimaProsesPesanan(pesanan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Terima & Proses',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  // Tab Pesanan Diproses
  Widget _buildPesananDiprosesTab() {
    if (pesananDiproses.isEmpty) {
      return _buildEmptyState('Tidak ada pesanan yang diproses');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pesananDiproses.length,
      itemBuilder: (context, index) {
        final pesanan = pesananDiproses[index];
        return _buildPesananCard(
          pesanan: pesanan,
          showEstimasi: true,
          actions: [
            ElevatedButton(
              onPressed: () => _selesaikanPesanan(pesanan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tandai Selesai',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  // Tab Pesanan Selesai
  Widget _buildPesananSelesaiTab() {
    if (pesananSelesai.isEmpty) {
      return _buildEmptyState('Belum ada pesanan selesai');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pesananSelesai.length,
      itemBuilder: (context, index) {
        final pesanan = pesananSelesai[index];
        return _buildPesananCard(
          pesanan: pesanan,
          showMetodeBayar: true,
          isCompleted: true,
        );
      },
    );
  }

  Widget _buildPesananCard({
    required Map<String, dynamic> pesanan,
    List<Widget>? actions,
    bool showEstimasi = false,
    bool showMetodeBayar = false,
    bool isCompleted = false,
  }) {
    Color statusColor;
    String statusText;

    switch (pesanan['status']) {
      case 'masuk':
        statusColor = Colors.orange;
        statusText = 'Pesanan Masuk';
        break;
      case 'diproses':
        statusColor = Colors.blue;
        statusText = 'Sedang Diproses';
        break;
      case 'selesai':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

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
                        pesanan['nama'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        pesanan['kamar'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pesanan['menu'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${pesanan['jumlah']}x',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${pesanan['harga'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  if (pesanan['catatan'] != null &&
                      pesanan['catatan'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pesanan['catatan'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Time Info
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Dipesan: ${pesanan['waktuPesan']} - ${pesanan['tanggal']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Estimasi (untuk pesanan diproses)
            if (showEstimasi && pesanan['estimasi'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Estimasi selesai: ${pesanan['estimasi']}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ],

            // Waktu Selesai & Metode Bayar (untuk pesanan selesai)
            if (isCompleted) ...[
              if (pesanan['waktuSelesai'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Selesai: ${pesanan['waktuSelesai']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              if (showMetodeBayar && pesanan['metodeBayar'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Dibayar: ${pesanan['metodeBayar']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Actions
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.white60),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Actions
  void _tolakPesanan(Map<String, dynamic> pesanan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Tolak Pesanan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Apakah Anda yakin ingin menolak pesanan dari ${pesanan['nama']}?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Pesanan Ditolak',
                    'Pesanan dari ${pesanan['nama']} telah ditolak',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Tolak',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _terimaProsesPesanan(Map<String, dynamic> pesanan) {
    Get.snackbar(
      'Pesanan Diterima',
      'Pesanan dari ${pesanan['nama']} sedang diproses',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // Logika untuk pindah ke tab diproses
    _tabController.animateTo(1);
  }

  void _selesaikanPesanan(Map<String, dynamic> pesanan) {
    Get.to(
      () => const SuccessScreen(
        title: 'Pesanan Selesai',
        subtitle: 'Pesanan telah berhasil diselesaikan',
      ),
    );
  }
}
