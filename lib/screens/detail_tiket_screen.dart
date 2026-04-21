import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class DetailTiketScreen extends StatefulWidget {
  final TicketModel tiket;
  final UserModel user;

  const DetailTiketScreen({super.key, required this.tiket, required this.user});

  @override
  State<DetailTiketScreen> createState() => _DetailTiketScreenState();
}

class _DetailTiketScreenState extends State<DetailTiketScreen> {
  late TicketModel _tiket;
  final _komentarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tiket = widget.tiket;
  }

  @override
  void dispose() {
    _komentarCtrl.dispose();
    super.dispose();
  }

  void _tambahKomentar() {
    if (_komentarCtrl.text.trim().isEmpty) return;
    final komentar = KomentarModel(
      username: widget.user.username,
      isi: _komentarCtrl.text.trim(),
      waktu: DateTime.now(),
    );
    setState(() {
      final idx = DummyData.tikets.indexWhere((t) => t.id == _tiket.id);
      if (idx != -1) {
        _tiket = _tiket.copyWith(komentar: [..._tiket.komentar, komentar]);
        DummyData.tikets[idx] = _tiket;
      }
    });
    _komentarCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  void _updateStatus(String status) {
    setState(() {
      final idx = DummyData.tikets.indexWhere((t) => t.id == _tiket.id);
      if (idx != -1) {
        _tiket = _tiket.copyWith(status: status);
        DummyData.tikets[idx] = _tiket;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status diubah ke ${AppTheme.statusLabel(status)}'),
        backgroundColor: AppTheme.statusColor(status),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _assignTiket(String helpdeskUsername) {
    setState(() {
      final idx = DummyData.tikets.indexWhere((t) => t.id == _tiket.id);
      if (idx != -1) {
        _tiket = _tiket.copyWith(assignedTo: helpdeskUsername);
        DummyData.tikets[idx] = _tiket;
      }
    });
    final nama = DummyData.daftarHelpdesk
        .firstWhere((h) => h.username == helpdeskUsername).nama;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tiket diassign ke $nama'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final statusColor = AppTheme.statusColor(_tiket.status);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_tiket.id,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
        actions: [
          // Admin: bisa assign
          if (widget.user.role == 'Admin')
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
              onSelected: (value) {
                if (value.startsWith('assign_')) {
                  _assignTiket(value.replaceFirst('assign_', ''));
                } else {
                  _updateStatus(value);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'open', child: Text('Set Open')),
                const PopupMenuItem(value: 'on_progress', child: Text('Set On Progress')),
                const PopupMenuItem(value: 'resolved', child: Text('Set Resolved')),
                const PopupMenuItem(value: 'closed', child: Text('Set Closed')),
                const PopupMenuDivider(),
                ...DummyData.daftarHelpdesk.map((h) =>
                    PopupMenuItem(value: 'assign_${h.username}', child: Text('Assign ke ${h.nama}'))),
              ],
            ),
          // Helpdesk: hanya update status
          if (widget.user.role == 'Helpdesk')
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
              onSelected: _updateStatus,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'on_progress', child: Text('Set On Progress')),
                const PopupMenuItem(value: 'resolved', child: Text('Set Resolved')),
                const PopupMenuItem(value: 'closed', child: Text('Set Closed')),
              ],
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          border: Border(top: BorderSide(
              color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _komentarCtrl,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _tambahKomentar,
              child: Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Prioritas
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(AppTheme.statusLabel(_tiket.status),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: AppTheme.prioritasColor(_tiket.prioritas).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Prioritas: ${AppTheme.prioritasLabel(_tiket.prioritas)}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppTheme.prioritasColor(_tiket.prioritas))),
              ),
            ]),
            const SizedBox(height: 14),
            Text(_tiket.judul, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 14),
            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Column(children: [
                _infoRow('Kategori', _tiket.kategori, Icons.folder_outlined, isDark),
                const SizedBox(height: 10),
                _infoRow('Pembuat', _tiket.pembuatUsername, Icons.person_outline_rounded, isDark),
                const SizedBox(height: 10),
                _infoRow(
                  'Assigned ke',
                  _tiket.assignedTo ?? 'Belum diassign',
                  Icons.support_agent_rounded,
                  isDark,
                  valueColor: _tiket.assignedTo == null
                      ? AppTheme.dangerColor
                      : AppTheme.successColor,
                ),
                const SizedBox(height: 10),
                _infoRow('Dibuat', _formatTanggal(_tiket.createdAt), Icons.access_time_rounded, isDark),
              ]),
            ),
            const SizedBox(height: 16),
          
            Text('Deskripsi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Text(_tiket.deskripsi,
                  style: TextStyle(fontSize: 13, height: 1.6,
                      color: isDark ? Colors.white70 : const Color(0xFF4A4A6A))),
            ),
            const SizedBox(height: 16),
          
            Text('Komentar (${_tiket.komentar.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            if (_tiket.komentar.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Center(child: Text('Belum ada komentar',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey[400]))),
              )
            else
              ..._tiket.komentar.map((k) => _komentarItem(k, isDark, cardBg)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon, bool isDark, {Color? valueColor}) {
    return Row(children: [
      Icon(icon, size: 16, color: isDark ? Colors.white38 : Colors.grey[500]),
      const SizedBox(width: 8),
      Text('$label: ', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
      Expanded(
        child: Text(value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? Colors.white70 : const Color(0xFF4A4A6A))),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Widget _komentarItem(KomentarModel k, bool isDark, Color cardBg) {
    final isMe = k.username == widget.user.username;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryColor.withOpacity(0.08) : cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppTheme.primaryColor.withOpacity(0.2)
              : (isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE)),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(k.username,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: isMe ? AppTheme.primaryColor : (isDark ? Colors.white70 : const Color(0xFF4A4A6A)))),
            const Spacer(),
            Text(_formatWaktu(k.waktu),
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[400])),
          ]),
          const SizedBox(height: 5),
          Text(k.isi, style: TextStyle(fontSize: 13, height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF4A4A6A))),
        ],
      ),
    );
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}