import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import 'create_tiket_screen.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: user.role == 'Admin'
            ? _buildAdminDashboard(context, isDark)
            : user.role == 'Helpdesk'
                ? _buildHelpdeskDashboard(context, isDark)
                : _buildUserDashboard(context, isDark),
      ),
      floatingActionButton: user.role == 'User'
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CreateTiketScreen(user: user))),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Tiket', style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _buildAdminDashboard(BuildContext context, bool isDark) {
    final tikets = DummyData.tikets;
    final totalOpen = tikets.where((t) => t.status == 'open').length;
    final totalProgress = tikets.where((t) => t.status == 'on_progress').length;
    final totalResolved = tikets.where((t) => t.status == 'resolved').length;
    final totalClosed = tikets.where((t) => t.status == 'closed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, 'Admin', AppTheme.primaryColor),
          const SizedBox(height: 20),
          // 4 stat cards 2x2
          Row(children: [
            Expanded(child: _statCard(isDark, 'Total', tikets.length, AppTheme.primaryColor, Icons.confirmation_number_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(isDark, 'Open', totalOpen, AppTheme.dangerColor, Icons.radio_button_unchecked_rounded)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _statCard(isDark, 'Progress', totalProgress, AppTheme.warningColor, Icons.autorenew_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(isDark, 'Resolved', totalResolved, AppTheme.successColor, Icons.check_circle_outline_rounded)),
          ]),
          const SizedBox(height: 20),
          // Bar chart
          Text('Statistik Tiket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          _buildBarChart(isDark, totalOpen, totalProgress, totalResolved, totalClosed, tikets.length),
          const SizedBox(height: 20),
          // Tiket terbaru - semua tiket
          _buildRecentHeader(isDark, 'Semua Tiket Terbaru'),
          const SizedBox(height: 12),
          ...tikets.take(4).map((t) => _tiketCard(isDark, t)),
        ],
      ),
    );
  }

  Widget _buildHelpdeskDashboard(BuildContext context, bool isDark) {
    final tikets = DummyData.tikets.where((t) => t.assignedTo == user.username).toList();
    final totalOpen = tikets.where((t) => t.status == 'open').length;
    final totalProgress = tikets.where((t) => t.status == 'on_progress').length;
    final totalResolved = tikets.where((t) => t.status == 'resolved').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, 'Helpdesk', AppTheme.warningColor),
          const SizedBox(height: 20),
         
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF9F27), Color(0xFFBA7517)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tiket Saya', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('${tikets.length} Tiket Diassign',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('$totalProgress tiket sedang ditangani',
                          style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 26),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _statCard(isDark, 'Open', totalOpen, AppTheme.dangerColor, Icons.radio_button_unchecked_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(isDark, 'Progress', totalProgress, AppTheme.warningColor, Icons.autorenew_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(isDark, 'Resolved', totalResolved, AppTheme.successColor, Icons.check_circle_outline_rounded)),
          ]),
          const SizedBox(height: 20),
          _buildRecentHeader(isDark, 'Tiket yang Diassign ke Saya'),
          const SizedBox(height: 12),
          if (tikets.isEmpty)
            _emptyCard(isDark, 'Belum ada tiket yang diassign ke Anda')
          else
            ...tikets.take(4).map((t) => _tiketCard(isDark, t)),
        ],
      ),
    );
  }

  Widget _buildUserDashboard(BuildContext context, bool isDark) {
    final tikets = DummyData.tikets.where((t) => t.pembuatUsername == user.username).toList();
    final totalOpen = tikets.where((t) => t.status == 'open').length;
    final totalProgress = tikets.where((t) => t.status == 'on_progress').length;
    final totalResolved = tikets.where((t) => t.status == 'resolved').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark, 'User', AppTheme.successColor),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tiket Saya', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('${tikets.length} Tiket',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('$totalOpen tiket menunggu penanganan',
                          style: const TextStyle(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                ),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _statCard(isDark, 'Open', totalOpen, AppTheme.dangerColor, Icons.radio_button_unchecked_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(isDark, 'Progress', totalProgress, AppTheme.warningColor, Icons.autorenew_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _statCard(isDark, 'Resolved', totalResolved, AppTheme.successColor, Icons.check_circle_outline_rounded)),
          ]),
          const SizedBox(height: 20),
          _buildRecentHeader(isDark, 'Tiket Terbaru'),
          const SizedBox(height: 12),
          if (tikets.isEmpty)
            _emptyCard(isDark, 'Belum ada tiket. Tekan "Buat Tiket" untuk mulai.')
          else
            ...tikets.take(3).map((t) => _tiketCard(isDark, t)),
        ],
      ),
    );
  }

  // ── SHARED WIDGETS ────────────────────────────────────────────
  Widget _buildHeader(bool isDark, String roleLabel, Color roleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(), style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600])),
            const SizedBox(height: 2),
            Text(user.nama, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(roleLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: roleColor)),
        ),
      ],
    );
  }

  Widget _buildRecentHeader(bool isDark, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
        GestureDetector(
          onTap: () => onNavigate(1),
          child: const Text('Lihat Semua',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
        ),
      ],
    );
  }

  Widget _statCard(bool isDark, String label, int count, Color color, IconData icon) {
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDark, int open, int progress, int resolved, int closed, int total) {
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (total + 2).toDouble(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => isDark ? const Color(0xFF2A2D3E) : const Color(0xFFF5F7FA),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final labels = ['Open', 'Progress', 'Resolved', 'Closed'];
                  return BarTooltipItem('${labels[groupIndex]}\n${rod.toY.toInt()}',
                      TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          fontSize: 12, fontWeight: FontWeight.w600));
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final labels = ['Open', 'Progress', 'Resolved', 'Closed'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(labels[value.toInt()],
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white54 : Colors.grey[600])),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, interval: 1, reservedSize: 28,
                  getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey[400])),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? Colors.white10 : Colors.grey.shade200, strokeWidth: 0.5),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              _barGroup(0, open.toDouble(), AppTheme.dangerColor),
              _barGroup(1, progress.toDouble(), AppTheme.warningColor),
              _barGroup(2, resolved.toDouble(), AppTheme.successColor),
              _barGroup(3, closed.toDouble(), Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y, color: color, width: 28,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
      ),
    ]);
  }

  Widget _tiketCard(bool isDark, dynamic t) {
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final statusColor = AppTheme.statusColor(t.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(t.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(AppTheme.statusLabel(t.status),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(t.judul, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(t.kategori, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark, String message) {
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: isDark ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey[400])),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi 👋';
    if (hour < 15) return 'Selamat Siang 👋';
    if (hour < 18) return 'Selamat Sore 👋';
    return 'Selamat Malam 👋';
  }
}