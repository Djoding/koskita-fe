import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kosan_euy/widgets/success_screen.dart';

class LayananLaundryScreen extends StatefulWidget {
  const LayananLaundryScreen({super.key});

  @override
  State<LayananLaundryScreen> createState() => _LayananLaundryScreenState();
}

class _LayananLaundryScreenState extends State<LayananLaundryScreen>
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

  // Data laundry berdasarkan status
  final List<Map<String, dynamic>> laundryMasuk = [
    {
      'id': 'LM001',
      'nama': 'Nella Aprilia',
      'kamar': 'Kamar No 10',
      'jenis': 'Cuci Kering',
      'berat': 3.5,
      'harga': 21000,
      'waktuPesan': '08:30',
      'tanggal': '12 Juni 2025',
      'catatan': 'Jangan pakai pewangi ya',
      'status': 'masuk',
    },
    {
      'id': 'LM002',
      'nama': 'Angelica Sharon',
      'kamar': 'Kamar No 15',
      'jenis': 'Cuci Setrika',
      'berat': 2.0,
      'harga': 16000,
      'waktuPesan': '09:15',
      'tanggal': '12 Juni 2025',
      'catatan': 'Setrika rapi ya kak',
      'status': 'masuk',
    },
  ];

  final List<Map<String, dynamic>> laundryDiproses = [
    {
      'id': 'LD001',
      'nama': 'Putri Ayu',
      'kamar': 'Kamar No 5',
      'jenis': 'Cuci Lipat',
      'berat': 4.0,
      'harga': 24000,
      'waktuPesan': '07:45',
      'tanggal': '12 Juni 2025',
      'catatan': 'Lipat rapi dalam plastik',
      'status': 'diproses',
      'estimasi': '2 jam',
      'tahap': 'Sedang dicuci',
    },
  ];

  final List<Map<String, dynamic>> laundrySelesai = [
    {
      'id': 'LS001',
      'nama': 'Maya Indah',
      'kamar': 'Kamar No 12',
      'jenis': 'Cuci Setrika',
      'berat': 3.0,
      'harga': 24000,
      'waktuPesan': '06:30',
      'waktuSelesai': '10:30',
      'tanggal': '12 Juni 2025',
      'catatan': 'Setrika semua baju',
      'status': 'selesai',
      'metodeBayar': 'Cash',
    },
    {
      'id': 'LS002',
      'nama': 'Desi Ratnasari',
      'kamar': 'Kamar No 7',
      'jenis': 'Cuci Kering',
      'berat': 2.5,
      'harga': 15000,
      'waktuPesan': '05:45',
      'waktuSelesai': '09:00',
      'tanggal': '12 Juni 2025',
      'catatan': 'Cuci bersih saja',
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
                    'Layanan Laundry',
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
                      'Masuk',
                      laundryMasuk.length,
                      Colors.orange,
                      Icons.local_laundry_service,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Diproses',
                      laundryDiproses.length,
                      Colors.blue,
                      Icons.hourglass_empty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Selesai',
                      laundrySelesai.length,
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
                  _buildLaundryMasukTab(),
                  _buildLaundryDiprosesTab(),
                  _buildLaundrySelesaiTab(),
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

  // Tab Laundry Masuk
  Widget _buildLaundryMasukTab() {
    if (laundryMasuk.isEmpty) {
      return _buildEmptyState('Tidak ada laundry masuk');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: laundryMasuk.length,
      itemBuilder: (context, index) {
        final laundry = laundryMasuk[index];
        return _buildLaundryCard(
          laundry: laundry,
          actions: [
            ElevatedButton(
              onPressed: () => _tolakLaundry(laundry),
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
              onPressed: () => _terimaProsesLaundry(laundry),
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

  // Tab Laundry Diproses
  Widget _buildLaundryDiprosesTab() {
    if (laundryDiproses.isEmpty) {
      return _buildEmptyState('Tidak ada laundry yang diproses');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: laundryDiproses.length,
      itemBuilder: (context, index) {
        final laundry = laundryDiproses[index];
        return _buildLaundryCard(
          laundry: laundry,
          showEstimasi: true,
          actions: [
            ElevatedButton(
              onPressed: () => _selesaikanLaundry(laundry),
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

  // Tab Laundry Selesai
  Widget _buildLaundrySelesaiTab() {
    if (laundrySelesai.isEmpty) {
      return _buildEmptyState('Belum ada laundry selesai');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: laundrySelesai.length,
      itemBuilder: (context, index) {
        final laundry = laundrySelesai[index];
        return _buildLaundryCard(
          laundry: laundry,
          showMetodeBayar: true,
          isCompleted: true,
        );
      },
    );
  }

  Widget _buildLaundryCard({
    required Map<String, dynamic> laundry,
    List<Widget>? actions,
    bool showEstimasi = false,
    bool showMetodeBayar = false,
    bool isCompleted = false,
  }) {
    Color statusColor;
    String statusText;

    switch (laundry['status']) {
      case 'masuk':
        statusColor = Colors.orange;
        statusText = 'Laundry Masuk';
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
                        laundry['nama'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        laundry['kamar'],
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

            // Laundry Details
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
                          laundry['jenis'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${laundry['berat']} kg',
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
                    'Rp ${laundry['harga'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  if (laundry['catatan'] != null &&
                      laundry['catatan'].isNotEmpty) ...[
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
                              laundry['catatan'],
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
                  'Dipesan: ${laundry['waktuPesan']} - ${laundry['tanggal']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Estimasi & Tahap (untuk laundry diproses)
            if (showEstimasi) ...[
              if (laundry['estimasi'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Estimasi selesai: ${laundry['estimasi']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              if (laundry['tahap'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: 16,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${laundry['tahap']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Waktu Selesai & Metode Bayar (untuk laundry selesai)
            if (isCompleted) ...[
              if (laundry['waktuSelesai'] != null) ...[
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
                      'Selesai: ${laundry['waktuSelesai']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              if (showMetodeBayar && laundry['metodeBayar'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Dibayar: ${laundry['metodeBayar']}',
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
          Icon(
            Icons.local_laundry_service_outlined,
            size: 80,
            color: Colors.white60,
          ),
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
  void _tolakLaundry(Map<String, dynamic> laundry) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Tolak Laundry',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Apakah Anda yakin ingin menolak laundry dari ${laundry['nama']}?',
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
                    'Laundry Ditolak',
                    'Laundry dari ${laundry['nama']} telah ditolak',
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

  void _terimaProsesLaundry(Map<String, dynamic> laundry) {
    Get.snackbar(
      'Laundry Diterima',
      'Laundry dari ${laundry['nama']} sedang diproses',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // Logika untuk pindah ke tab diproses
    _tabController.animateTo(1);
  }

  void _selesaikanLaundry(Map<String, dynamic> laundry) {
    Get.to(
      () => const SuccessScreen(
        title: 'Laundry Selesai',
        subtitle: 'Laundry telah berhasil diselesaikan',
      ),
    );
  }
}
