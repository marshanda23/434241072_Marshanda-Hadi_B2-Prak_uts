import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class NotifikasiScreen extends StatefulWidget {
  final UserModel user;

  const NotifikasiScreen({super.key, required this.user});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA);
    final notifs = DummyData.notifikasi;
    final belumDibaca = notifs.where((n) => !n.sudahDibaca).length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifikasi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                      if (belumDibaca > 0)
                        Text('$belumDibaca belum dibaca',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey[600])),
                    ],
                  ),
                  if (belumDibaca > 0)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          for (var n in DummyData.notifikasi) {
                            n.sudahDibaca = true;
                          }
                        });
                      },
                      child: const Text('Tandai semua dibaca',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notifs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 56,
                              color: isDark ? Colors.white24 : Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('Tidak ada notifikasi',
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      itemCount: notifs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = notifs[index];
                        return _buildNotifCard(n, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(dynamic n, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final tipeColor = _tipeColor(n.tipe);

    return GestureDetector(
      onTap: () => setState(() => n.sudahDibaca = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.sudahDibaca ? cardBg : tipeColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: n.sudahDibaca
                ? (isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE))
                : tipeColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tipeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_tipeIcon(n.tipe), color: tipeColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.judul,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                      ),
                      if (!n.sudahDibaca)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: tipeColor, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.pesan,
                      style: TextStyle(fontSize: 12, height: 1.5,
                          color: isDark ? Colors.white54 : Colors.grey[600]),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(_formatWaktu(n.waktu),
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[400])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _tipeColor(String tipe) {
    switch (tipe) {
      case 'success': return AppTheme.successColor;
      case 'warning': return AppTheme.warningColor;
      case 'danger': return AppTheme.dangerColor;
      default: return AppTheme.primaryColor;
    }
  }

  IconData _tipeIcon(String tipe) {
    switch (tipe) {
      case 'success': return Icons.check_circle_outline_rounded;
      case 'warning': return Icons.warning_amber_rounded;
      case 'danger': return Icons.error_outline_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}