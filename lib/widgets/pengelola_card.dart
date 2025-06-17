// lib/widgets/pengelola_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PenggelolaCard extends StatelessWidget {
  final Map<String, dynamic> pengelola;
  final bool isPending;
  final VoidCallback? onTap;
  final VoidCallback? onVerify;
  final VoidCallback? onDelete;

  const PenggelolaCard({
    super.key,
    required this.pengelola,
    required this.isPending,
    this.onTap,
    this.onVerify,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(child: _buildUserInfo()),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 12),
              _buildUserDetails(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
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
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pengelola['full_name'] ?? 'Nama tidak tersedia',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          pengelola['email'] ?? 'Email tidak tersedia',
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '@${pengelola['username'] ?? 'username'}',
          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildUserDetails() {
    return Column(
      children: [
        if (pengelola['phone'] != null)
          _buildDetailRow(Icons.phone, 'Telepon', pengelola['phone']),
        _buildDetailRow(Icons.badge, 'Role', pengelola['role'] ?? 'PENGELOLA'),
        _buildDetailRow(
          Icons.calendar_today,
          'Bergabung',
          _formatDate(pengelola['created_at']),
        ),
        if (!isPending && pengelola['last_login'] != null)
          _buildDetailRow(
            Icons.login,
            'Login terakhir',
            _formatDate(pengelola['last_login']),
            valueColor: Colors.green[600],
          ),
        if (pengelola['email_verified'] == true)
          _buildDetailRow(
            Icons.verified,
            'Email',
            'Terverifikasi',
            valueColor: Colors.green[600],
          ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: valueColor ?? Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (isPending && onVerify != null) {
      return Row(
        children: [
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
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    }

    // For verified pengelola, only show delete button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.delete, size: 16),
        label: const Text('Hapus Pengelola'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
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
