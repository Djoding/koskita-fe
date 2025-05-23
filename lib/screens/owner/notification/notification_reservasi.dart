import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kosan_euy/screens/owner/notification/notification_reservasi_detail.dart';

class ReservationItem {
  final String id;
  final String name;
  final DateTime date;
  final String status;

  ReservationItem({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
  });

  factory ReservationItem.fromJson(Map<String, dynamic> json) {
    return ReservationItem(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
    );
  }
}

class NotificationReservasiScreen extends StatefulWidget {
  const NotificationReservasiScreen({super.key});

  @override
  State<NotificationReservasiScreen> createState() => _NotificationReservasiScreenState();
}

class _NotificationReservasiScreenState extends State<NotificationReservasiScreen> {
  List<ReservationItem> _items = [];
  Map<String, List<ReservationItem>> _groupedItems = {};
  bool _isLoading = true;

  final String dummyReservationsJson = '''
  [
    {
      "id": "1",
      "name": "Nella Aprilia",
      "date": "2024-12-10T10:00:00Z",
      "status": "Lunas"
    },
    {
      "id": "2",
      "name": "Angelica Sharon A, M",
      "date": "2024-09-01T11:00:00Z",
      "status": "Lunas"
    },
    {
      "id": "3",
      "name": "Budi Santoso",
      "date": "2024-09-05T14:30:00Z",
      "status": "DP 50%"
    },
    {
      "id": "4",
      "name": "Citra Lestari",
      "date": "2024-11-20T09:00:00Z",
      "status": "Lunas"
    },
    {
      "id": "5",
      "name": "Desember Ceria",
      "date": "2024-12-25T12:00:00Z",
      "status": "Booking"
    },
    {
      "id": "6",
      "name": "November Rain",
      "date": "2024-11-11T16:00:00Z",
      "status": "Lunas"
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _fetchAndProcessData();
  }

  Future<void> _fetchAndProcessData() async {
    await initializeDateFormatting('id_ID', null);
    _loadReservationItems();
  }

  void _loadReservationItems() {
    final List<dynamic> parsedJson = jsonDecode(dummyReservationsJson) as List<dynamic>;
    _items = parsedJson.map((jsonItem) => ReservationItem.fromJson(jsonItem as Map<String, dynamic>)).toList();

    _items.sort((a, b) => b.date.compareTo(a.date));

    _groupItemsByMonth();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupItemsByMonth() {
    _groupedItems = {};
    final DateFormat monthFormat = DateFormat('MMMM', 'id_ID');

    for (var item in _items) {
      String monthKey = monthFormat.format(item.date);
      if (!_groupedItems.containsKey(monthKey)) {
        _groupedItems[monthKey] = [];
      }
      _groupedItems[monthKey]!.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              Expanded(
                child: _groupedItems.isEmpty && !_isLoading
                    ? Center(
                  child: Text(
                    'Tidak ada pesanan.',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _groupedItems.keys.length,
                  itemBuilder: (context, index) {
                    String monthKey = _groupedItems.keys.elementAt(index);
                    List<ReservationItem> itemsInMonth = _groupedItems[monthKey]!;
                    return _buildMonthSection(context, monthKey, itemsInMonth);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Semua Layanan Pesanan Reservasi Kamar',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSection(BuildContext context, String monthName, List<ReservationItem> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${items.length} item${items.length > 1 ? "" : ""}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildReservationCard(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, ReservationItem item) {
    final DateFormat itemDateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    return InkWell(
      onTap: () {
        print('Item ${item.name} diklik!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationReservasiDetail(
              detailNotifikasiId: item.id,
            ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${itemDateFormat.format(item.date)} | ${item.status}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: Colors.grey[500], size: 28),
          ],
        ),
      ),
    );
  }
}