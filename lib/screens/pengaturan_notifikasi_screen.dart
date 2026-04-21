import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PengaturanNotifikasiScreen extends StatefulWidget {
  const PengaturanNotifikasiScreen({super.key});

  @override
  State<PengaturanNotifikasiScreen> createState() => _PengaturanNotifikasiScreenState();
}

class _PengaturanNotifikasiScreenState extends State<PengaturanNotifikasiScreen> {
  bool _notifUmum = true;
  bool _notifStatusTiket = true;
  bool _notifKomentar = true;
  bool _notifAssign = true;
  bool _notifEmail = false;
  bool _notifPushAndroid = true;
  String _frekuensi = 'realtime';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pengaturan Notifikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
        actions: [
          TextButton(
            onPressed: _simpan,
            child: const Text('Simpan', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifikasi Umum
            _sectionTitle('Notifikasi Umum', isDark),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Column(
                children: [
                  _switchItem(
                    icon: Icons.notifications_active_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'Aktifkan Notifikasi',
                    subtitle: 'Terima semua notifikasi dari aplikasi',
                    value: _notifUmum,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _notifUmum = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Jenis Notifikasi
            _sectionTitle('Jenis Notifikasi', isDark),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Column(
                children: [
                  _switchItem(
                    icon: Icons.sync_alt_rounded,
                    iconColor: AppTheme.warningColor,
                    title: 'Update Status Tiket',
                    subtitle: 'Notifikasi saat status tiket berubah',
                    value: _notifStatusTiket && _notifUmum,
                    isDark: isDark,
                    onChanged: _notifUmum ? (v) => setState(() => _notifStatusTiket = v) : null,
                  ),
                  _divider(isDark),
                  _switchItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: AppTheme.successColor,
                    title: 'Komentar Baru',
                    subtitle: 'Notifikasi saat ada komentar di tiket',
                    value: _notifKomentar && _notifUmum,
                    isDark: isDark,
                    onChanged: _notifUmum ? (v) => setState(() => _notifKomentar = v) : null,
                  ),
                  _divider(isDark),
                  _switchItem(
                    icon: Icons.assignment_ind_rounded,
                    iconColor: AppTheme.dangerColor,
                    title: 'Tiket Diassign',
                    subtitle: 'Notifikasi saat tiket diassign ke kamu',
                    value: _notifAssign && _notifUmum,
                    isDark: isDark,
                    onChanged: _notifUmum ? (v) => setState(() => _notifAssign = v) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Saluran Notifikasi
            _sectionTitle('Saluran Notifikasi', isDark),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Column(
                children: [
                  _switchItem(
                    icon: Icons.phone_android_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'Push Notification',
                    subtitle: 'Notifikasi langsung di perangkat',
                    value: _notifPushAndroid,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _notifPushAndroid = v),
                  ),
                  _divider(isDark),
                  _switchItem(
                    icon: Icons.email_outlined,
                    iconColor: AppTheme.warningColor,
                    title: 'Email',
                    subtitle: 'Kirim notifikasi ke email terdaftar',
                    value: _notifEmail,
                    isDark: isDark,
                    onChanged: (v) => setState(() => _notifEmail = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Frekuensi
            _sectionTitle('Frekuensi Notifikasi', isDark),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Column(
                children: [
                  _radioItem('realtime', 'Realtime', 'Langsung saat ada aktivitas', isDark),
                  _divider(isDark),
                  _radioItem('harian', 'Ringkasan Harian', 'Dikirim setiap hari pukul 08.00', isDark),
                  _divider(isDark),
                  _radioItem('mingguan', 'Ringkasan Mingguan', 'Dikirim setiap Senin pagi', isDark),
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan Pengaturan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _simpan() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pengaturan notifikasi disimpan!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  Widget _sectionTitle(String text, bool isDark) => Text(text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white54 : Colors.grey[600]));

  Widget _switchItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: onChanged == null
                        ? (isDark ? Colors.white24 : Colors.grey[300])
                        : (isDark ? Colors.white : const Color(0xFF1A1A2E)))),
                Text(subtitle, style: TextStyle(fontSize: 11,
                    color: onChanged == null
                        ? (isDark ? Colors.white12 : Colors.grey[200])
                        : (isDark ? Colors.white38 : Colors.grey[500]))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _radioItem(String value, String title, String subtitle, bool isDark) {
    final isSelected = _frekuensi == value;
    return GestureDetector(
      onTap: () => setState(() => _frekuensi = value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _frekuensi,
              onChanged: (v) => setState(() => _frekuensi = v!),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
      height: 0, thickness: 0.5,
      color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE),
      indent: 16, endIndent: 16);
}