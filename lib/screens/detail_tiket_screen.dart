import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';
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
  List<UserModel> _daftarHelpdesk = [];
  List<RiwayatTiketModel> _riwayat = [];
  bool _isLoadingRiwayat = true;
  bool _isLoadingKomentar = true;
  String? _namaPembuat;
  String? _namaAssignee;

  @override
  void initState() {
    super.initState();
    _tiket = widget.tiket;
    _loadHelpdesk();
    _loadRiwayat();
    _loadKomentar();
    _loadNamaPembuatDanAssignee();
  }

  Future<void> _loadNamaPembuatDanAssignee() async {
    try {
      final supabase = Supabase.instance.client;
      final ids = <String>{_tiket.pembuatId, if (_tiket.assignedTo != null) _tiket.assignedTo!};
      final response = await supabase.from('profiles').select('id, nama').inFilter('id', ids.toList());

      final map = <String, String>{
        for (final row in (response as List)) row['id'] as String: row['nama'] as String,
      };

      setState(() {
        _namaPembuat = map[_tiket.pembuatId] ?? _tiket.pembuatId;
        _namaAssignee = _tiket.assignedTo != null ? (map[_tiket.assignedTo] ?? _tiket.assignedTo) : null;
      });
    } catch (e) {
      setState(() {
        _namaPembuat = _tiket.pembuatId;
        _namaAssignee = _tiket.assignedTo;
      });
    }
  }

  @override
  void dispose() {
    _komentarCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHelpdesk() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('profiles').select().eq('role', 'Helpdesk');
    setState(() {
      _daftarHelpdesk = (response as List)
          .map((u) => UserModel.fromMap(u))
          .toList();
    });
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('riwayat_tiket')
          .select()
          .eq('ticket_id', _tiket.id)
          .order('waktu', ascending: true);

      setState(() {
        _riwayat = (response as List)
            .map((r) => RiwayatTiketModel(
                  id: r['id'],
                  ticketId: r['ticket_id'],
                  aksi: r['aksi'],
                  keterangan: r['keterangan'],
                  waktu: DateTime.parse(r['waktu']),
                ))
            .toList();
        _isLoadingRiwayat = false;
      });
    } catch (e) {
      setState(() => _isLoadingRiwayat = false);
    }
  }

  Future<void> _loadKomentar() async {
    setState(() => _isLoadingKomentar = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('komentar')
          .select('user_id, isi, waktu, profiles(nama)')
          .eq('ticket_id', _tiket.id)
          .order('waktu', ascending: true);

      final daftarKomentar = (response as List)
          .map((k) => KomentarModel(
                userId: k['user_id'],
                nama: k['profiles']?['nama'] ?? 'Pengguna',
                isi: k['isi'],
                waktu: DateTime.parse(k['waktu']),
              ))
          .toList();

      setState(() {
        _tiket = _tiket.copyWith(komentar: daftarKomentar);
        _isLoadingKomentar = false;
      });
    } catch (e) {
      setState(() => _isLoadingKomentar = false);
    }
  }

  Future<void> _catatRiwayat(String aksi, String keterangan) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('riwayat_tiket').insert({
        'ticket_id': _tiket.id,
        'aksi': aksi,
        'keterangan': keterangan,
        'waktu': DateTime.now().toIso8601String(),
      });
      _loadRiwayat();
    } catch (e) {
      // silent fail
    }
  }

  Future<void> _kirimNotifikasi({
    required String userId,
    required String judul,
    required String pesan,
    required String tipe,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('notifikasi').insert({
        'user_id': userId,
        'judul': judul,
        'pesan': pesan,
        'tipe': tipe,
        'waktu': DateTime.now().toIso8601String(),
        'sudah_dibaca': false,
      });
    } catch (e) {
      // silent fail — notifikasi gagal t
    }
  }

  Future<void> _tambahKomentar() async {
    if (_komentarCtrl.text.trim().isEmpty) return;
    final isi = _komentarCtrl.text.trim();
    _komentarCtrl.clear();
    FocusScope.of(context).unfocus();

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('komentar').insert({
        'ticket_id': _tiket.id,
        'user_id': widget.user.id,
        'isi': isi,
        'waktu': DateTime.now().toIso8601String(),
      });

      final komentar = KomentarModel(
        userId: widget.user.id,
        nama: widget.user.nama,
        isi: isi,
        waktu: DateTime.now(),
      );
      setState(() {
        _tiket = _tiket.copyWith(komentar: [..._tiket.komentar, komentar]);
      });

      await _catatRiwayat('komentar', '${widget.user.nama} menambahkan komentar');

      
      final penerima = <String>{_tiket.pembuatId, if (_tiket.assignedTo != null) _tiket.assignedTo!}
          .where((id) => id != widget.user.id);
      for (final id in penerima) {
        await _kirimNotifikasi(
          userId: id,
          judul: 'Komentar baru di ${_tiket.id}',
          pesan: '${widget.user.nama} menambahkan komentar: "$isi"',
          tipe: 'info',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Gagal mengirim komentar'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('tickets').update({'status': status}).eq('id', _tiket.id);
      setState(() => _tiket = _tiket.copyWith(status: status));

      final labelStatus = AppTheme.statusLabel(status);
      await _catatRiwayat('status', 'Status diubah menjadi $labelStatus oleh ${widget.user.nama}');

    
      if (_tiket.pembuatId != widget.user.id) {
        await _kirimNotifikasi(
          userId: _tiket.pembuatId,
          judul: 'Status tiket ${_tiket.id} berubah',
          pesan: 'Tiket "${_tiket.judul}" sekarang berstatus $labelStatus',
          tipe: status == 'closed' ? 'success' : 'info',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diubah ke $labelStatus'),
          backgroundColor: AppTheme.statusColor(status),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Gagal mengubah status'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  Future<void> _terimaTiket() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('tickets').update({'status': 'assigned'}).eq('id', _tiket.id);
      setState(() => _tiket = _tiket.copyWith(status: 'assigned'));

      await _catatRiwayat('diterima', 'Tiket diterima oleh ${widget.user.nama}, menunggu dipilihkan helpdesk');

      if (_tiket.pembuatId != widget.user.id) {
        await _kirimNotifikasi(
          userId: _tiket.pembuatId,
          judul: 'Tiket ${_tiket.id} diterima',
          pesan: 'Tiket "${_tiket.judul}" sudah diterima admin dan akan segera ditugaskan ke helpdesk',
          tipe: 'info',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tiket diterima — silakan pilih helpdesk'),
          backgroundColor: AppTheme.assignedColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menerima tiket'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _assignTiket(String helpdeskId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('tickets')
          .update({'assigned_to': helpdeskId, 'status': 'on_progress'}).eq('id', _tiket.id);
      setState(() => _tiket = _tiket.copyWith(assignedTo: helpdeskId, status: 'on_progress'));

      final nama = _daftarHelpdesk.firstWhere((h) => h.id == helpdeskId).nama;
      await _catatRiwayat('assign', 'Tiket diassign ke $nama oleh ${widget.user.nama}');
      await _catatRiwayat('status', 'Status diubah menjadi On Progress — $nama sedang menangani tiket ini');

      await _kirimNotifikasi(
        userId: helpdeskId,
        judul: 'Tiket baru ditugaskan: ${_tiket.id}',
        pesan: 'Anda ditugaskan menangani tiket "${_tiket.judul}"',
        tipe: 'warning',
      );
      if (_tiket.pembuatId != widget.user.id) {
        await _kirimNotifikasi(
          userId: _tiket.pembuatId,
          judul: 'Tiket ${_tiket.id} sedang ditangani',
          pesan: 'Tiket "${_tiket.judul}" sedang dikerjakan oleh $nama',
          tipe: 'info',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tiket diassign ke $nama — status On Progress'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Gagal assign tiket'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  Future<void> _selesaikanTiket() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Selesaikan Tiket', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Tandai tiket ${_tiket.id} "${_tiket.judul}" sebagai selesai? Status akan berubah menjadi Closed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor, foregroundColor: Colors.white),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('tickets').update({'status': 'closed'}).eq('id', _tiket.id);
      setState(() => _tiket = _tiket.copyWith(status: 'closed'));

      await _catatRiwayat('status', 'Tiket diselesaikan oleh ${widget.user.nama} — status Closed');

      if (_tiket.pembuatId != widget.user.id) {
        await _kirimNotifikasi(
          userId: _tiket.pembuatId,
          judul: 'Tiket ${_tiket.id} selesai',
          pesan: 'Tiket "${_tiket.judul}" telah selesai dikerjakan oleh ${widget.user.nama}',
          tipe: 'success',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tiket berhasil diselesaikan'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Gagal menyelesaikan tiket'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }
  }

  Future<void> _hapusTiket() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tiket', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Tiket ${_tiket.id} "${_tiket.judul}" akan dihapus permanen beserta seluruh riwayat dan komentarnya. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('riwayat_tiket').delete().eq('ticket_id', _tiket.id);
      await supabase.from('komentar').delete().eq('ticket_id', _tiket.id);
      await supabase.from('tickets').delete().eq('id', _tiket.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tiket ${_tiket.id} berhasil dihapus'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menghapus tiket'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : const Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_tiket.id,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
        actions: [
          if (widget.user.role == 'Admin')
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
              onSelected: (value) {
                if (value == 'hapus') {
                  _hapusTiket();
                } else if (value == 'terima') {
                  _terimaTiket();
                } else if (value.startsWith('assign_')) {
                  _assignTiket(value.replaceFirst('assign_', ''));
                }
              },
              itemBuilder: (_) => [
                if (_tiket.status == 'open')
                  const PopupMenuItem(value: 'terima', child: Text('Terima Tiket')),
                if (_tiket.status == 'assigned' && _daftarHelpdesk.isNotEmpty) ...[
                  const PopupMenuItem(enabled: false,
                    child: Text('Pilih Helpdesk', style: TextStyle(fontSize: 11, color: Colors.grey))),
                  ..._daftarHelpdesk
                      .map((h) => PopupMenuItem(value: 'assign_${h.id}', child: Text(h.nama))),
                  const PopupMenuDivider(),
                ],
                const PopupMenuItem(
                  value: 'hapus',
                  child: Text('Hapus Tiket', style: TextStyle(color: AppTheme.dangerColor)),
                ),
              ],
            ),
          if (widget.user.role == 'Helpdesk' && _tiket.status == 'on_progress')
            TextButton.icon(
              onPressed: _selesaikanTiket,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppTheme.successColor),
              label: const Text('Selesai', style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.w600)),
            ),
          if (widget.user.role == 'Helpdesk')
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
              onSelected: _updateStatus,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'on_progress', child: Text('Set On Progress')),
                const PopupMenuItem(value: 'closed', child: Text('Set Closed')),
              ],
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          border:
              Border(top: BorderSide(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5)),
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
                width: 42,
                height: 42,
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
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.prioritasColor(_tiket.prioritas))),
              ),
            ]),
            const SizedBox(height: 14),
            Text(_tiket.judul,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 14),
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
                _infoRow('Pembuat', _namaPembuat ?? '...', Icons.person_outline_rounded, isDark),
                const SizedBox(height: 10),
                _infoRow(
                  'Assigned ke',
                  _namaAssignee ?? 'Belum diassign',
                  Icons.support_agent_rounded,
                  isDark,
                  valueColor: _tiket.assignedTo == null ? AppTheme.dangerColor : AppTheme.successColor,
                ),
                const SizedBox(height: 10),
                _infoRow('Dibuat', _formatTanggal(_tiket.createdAt), Icons.access_time_rounded, isDark),
              ]),
            ),
            const SizedBox(height: 16),
            Text('Deskripsi',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
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
                  style: TextStyle(fontSize: 13, height: 1.6, color: isDark ? Colors.white70 : const Color(0xFF4A4A6A))),
            ),
            const SizedBox(height: 16),
            if (_tiket.lampiranUrl != null) ...[
              Text('Lampiran',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: InteractiveViewer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(_tiket.lampiranUrl!, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    _tiket.lampiranUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 200,
                        color: cardBg,
                        child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                      );
                    },
                    errorBuilder: (context, error, stack) => Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                      ),
                      child: const Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text('Riwayat Tiket',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            if (_isLoadingRiwayat)
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            else if (_riwayat.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Center(
                    child: Text('Belum ada riwayat',
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey[400]))),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Column(
                  children: List.generate(_riwayat.length, (i) {
                    final r = _riwayat[i];
                    final isLast = i == _riwayat.length - 1;
                    return _timelineItem(r, isDark, isLast: isLast);
                  }),
                ),
              ),
            const SizedBox(height: 20),

            Text('Komentar (${_tiket.komentar.length})',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            if (_isLoadingKomentar)
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            else if (_tiket.komentar.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Center(
                    child: Text('Belum ada komentar',
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

  Widget _timelineItem(RiwayatTiketModel r, bool isDark, {required bool isLast}) {
    final color = _aksiColor(r.aksi);
    final icon = _aksiIcon(r.aksi);
    final dotSize = isLast ? 40.0 : 32.0;
    final iconSize = isLast ? 20.0 : 16.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isLast ? color : color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: isLast ? Border.all(color: color.withOpacity(0.3), width: 4) : null,
                ),
                child: Icon(icon, size: iconSize, color: isLast ? Colors.white : color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: color.withOpacity(0.35),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 26, top: isLast ? 8 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_aksiJudul(r.aksi, r.keterangan),
                      style: TextStyle(
                          fontSize: isLast ? 14.5 : 13.5,
                          fontWeight: isLast ? FontWeight.w800 : FontWeight.w700,
                          color: isLast ? color : (isDark ? Colors.white : const Color(0xFF1A1A2E)))),
                  const SizedBox(height: 3),
                  Text(r.keterangan, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey[600])),
                  const SizedBox(height: 5),
                  Row(children: [
                    Icon(Icons.access_time_rounded, size: 11, color: isDark ? Colors.white24 : Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(_formatTanggalLengkap(r.waktu),
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.grey[400])),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _aksiJudul(String aksi, [String? keterangan]) {
    switch (aksi) {
      case 'dibuat':
        return 'Tiket dibuat';
      case 'diterima':
        return 'Diterima admin';
      case 'assign':
        return 'Diassign ke helpdesk';
      case 'status':
        if (keterangan != null) {
          if (keterangan.contains('On Progress')) return 'Sedang dikerjakan';
          if (keterangan.contains('Resolved')) return 'Tiket selesai';
          if (keterangan.contains('Closed')) return 'Tiket ditutup';
          if (keterangan.contains('Open')) return 'Tiket dibuka kembali';
          if (keterangan.contains('Assigned')) return 'Tiket diassign';
        }
        return 'Status diperbarui';
      case 'komentar':
        return 'Komentar baru';
      default:
        return aksi;
    }
  }

  Color _aksiColor(String aksi) {
    switch (aksi) {
      case 'dibuat':
        return AppTheme.primaryColor;
      case 'diterima':
        return Colors.teal;
      case 'assign':
        return AppTheme.assignedColor;
      case 'status':
        return AppTheme.successColor;
      case 'komentar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _aksiIcon(String aksi) {
    switch (aksi) {
      case 'dibuat':
        return Icons.add_circle_outline_rounded;
      case 'diterima':
        return Icons.verified_outlined;
      case 'assign':
        return Icons.support_agent_rounded;
      case 'status':
        return Icons.sync_alt_rounded;
      case 'komentar':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _infoRow(String label, String value, IconData icon, bool isDark, {Color? valueColor}) {
    return Row(children: [
      Icon(icon, size: 16, color: isDark ? Colors.white38 : Colors.grey[500]),
      const SizedBox(width: 8),
      Text('$label: ', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
      Expanded(
        child: Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? Colors.white70 : const Color(0xFF4A4A6A))),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Widget _komentarItem(KomentarModel k, bool isDark, Color cardBg) {
    final isMe = k.userId == widget.user.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryColor.withOpacity(0.08) : cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? AppTheme.primaryColor.withOpacity(0.2)
              : (isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE)),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(k.nama,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isMe ? AppTheme.primaryColor : (isDark ? Colors.white70 : const Color(0xFF4A4A6A)))),
            const Spacer(),
            Text(_formatWaktu(k.waktu), style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[400])),
          ]),
          const SizedBox(height: 5),
          Text(k.isi, style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white70 : const Color(0xFF4A4A6A))),
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

  String _formatTanggalLengkap(DateTime dt) {
    final bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}