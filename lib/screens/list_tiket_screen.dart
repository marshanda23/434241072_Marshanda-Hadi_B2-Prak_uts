import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import 'detail_tiket_screen.dart';
import 'create_tiket_screen.dart';

class ListTiketScreen extends StatefulWidget {
  final UserModel user;
  final Function(int) onNavigate;

  const ListTiketScreen({super.key, required this.user, required this.onNavigate});

  @override
  State<ListTiketScreen> createState() => _ListTiketScreenState();
}

class _ListTiketScreenState extends State<ListTiketScreen> {
  String _filterStatus = 'semua';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  bool get isAdmin => widget.user.role == 'Admin';
  bool get isHelpdesk => widget.user.role == 'Helpdesk';
  bool get isUser => widget.user.role == 'User';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TicketModel> get _filteredTikets {
    List<TicketModel> list;
    if (isAdmin) {
      // Admin lihat semua tiket
      list = DummyData.tikets;
    } else if (isHelpdesk) {
      // Helpdesk lihat tiket yang diassign ke dia
      list = DummyData.tikets.where((t) => t.assignedTo == widget.user.username).toList();
    } else {
      // User lihat tiket miliknya sendiri
      list = DummyData.tikets.where((t) => t.pembuatUsername == widget.user.username).toList();
    }
    if (_filterStatus != 'semua') {
      list = list.where((t) => t.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) =>
          t.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.id.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAdmin ? 'Semua Tiket' : isHelpdesk ? 'Tiket Saya' : 'Tiket Saya',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  Text('${_filteredTikets.length} tiket',
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey[500])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: 'Cari tiket...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18, color: isDark ? Colors.white38 : Colors.grey[500]),
                          onPressed: () => setState(() { _searchCtrl.clear(); _searchQuery = ''; }),
                        )
                      : null,
                  filled: true, fillColor: cardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: ['semua', 'open', 'on_progress', 'resolved', 'closed'].map((s) {
                  final labels = {'semua': 'Semua', 'open': 'Open', 'on_progress': 'On Progress', 'resolved': 'Resolved', 'closed': 'Closed'};
                  final isActive = _filterStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterStatus = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primaryColor : (isDark ? const Color(0xFF1C1F2E) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isActive ? AppTheme.primaryColor : (isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE)), width: 0.5),
                        ),
                        child: Text(labels[s]!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : (isDark ? Colors.white60 : Colors.grey[700]))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredTikets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded, size: 56, color: isDark ? Colors.white24 : Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('Tidak ada tiket', style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _filteredTikets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _tiketCard(context, _filteredTikets[i], isDark, cardBg),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: isUser
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CreateTiketScreen(user: widget.user)))
                  .then((_) => setState(() {})),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _tiketCard(BuildContext context, TicketModel t, bool isDark, Color cardBg) {
    final statusColor = AppTheme.statusColor(t.status);
    final prioritasColor = AppTheme.prioritasColor(t.prioritas);
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailTiketScreen(tiket: t, user: widget.user)))
          .then((_) => setState(() {})),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(t.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: prioritasColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Text(AppTheme.prioritasLabel(t.prioritas),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: prioritasColor)),
                ),
                const Spacer(),
                // Admin lihat badge "Belum diassign"
                if (isAdmin && t.assignedTo == null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Text('Belum diassign', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.orange)),
                  ),
                if (t.assignedTo != null || !isAdmin) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(AppTheme.statusLabel(t.status),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(t.judul, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(t.deskripsi, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500]),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.folder_outlined, size: 13, color: isDark ? Colors.white38 : Colors.grey[500]),
                const SizedBox(width: 4),
                Text(t.kategori, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
                if (isAdmin) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.person_outline_rounded, size: 13, color: isDark ? Colors.white38 : Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(t.pembuatUsername, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
                ],
                const Spacer(),
                Icon(Icons.access_time_rounded, size: 13, color: isDark ? Colors.white38 : Colors.grey[500]),
                const SizedBox(width: 4),
                Text(_formatWaktu(t.createdAt), style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatWaktu(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }
}