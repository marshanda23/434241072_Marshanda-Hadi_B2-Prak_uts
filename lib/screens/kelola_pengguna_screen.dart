import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class KelolaPenggunaScreen extends StatefulWidget {
  final UserModel currentUser;

  const KelolaPenggunaScreen({super.key, required this.currentUser});

  @override
  State<KelolaPenggunaScreen> createState() => _KelolaPenggunaScreenState();
}

class _KelolaPenggunaScreenState extends State<KelolaPenggunaScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _filterRole = 'semua';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _roles = ['User', 'Helpdesk', 'Admin'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('profiles').select().order('nama', ascending: true);

      setState(() {
        _users = (response as List).map((u) => UserModel.fromMap(u)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal memuat daftar pengguna'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  List<UserModel> get _filteredUsers {
    List<UserModel> list = _users;
    if (_filterRole != 'semua') {
      list = list.where((u) => u.role == _filterRole).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((u) =>
          u.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  Future<void> _ubahRole(UserModel user, String roleBaru) async {
    if (user.id == widget.currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak bisa mengubah role akun sendiri'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profiles').update({'role': roleBaru}).eq('id', user.id);
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) _users[index] = _users[index].copyWith(role: roleBaru);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role ${user.nama} diubah menjadi $roleBaru'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah role'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _toggleAktif(UserModel user) async {
    if (user.id == widget.currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak bisa menonaktifkan akun sendiri'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final statusBaru = !user.isActive;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(statusBaru ? 'Aktifkan Pengguna' : 'Nonaktifkan Pengguna',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(statusBaru
            ? '${user.nama} akan bisa login dan menggunakan aplikasi kembali.'
            : '${user.nama} tidak akan bisa login sampai diaktifkan kembali. Data tiket & riwayatnya tetap aman.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: statusBaru ? AppTheme.successColor : AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            child: Text(statusBaru ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profiles').update({'is_active': statusBaru}).eq('id', user.id);
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) _users[index] = _users[index].copyWith(isActive: statusBaru);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusBaru ? '${user.nama} diaktifkan' : '${user.nama} dinonaktifkan'),
          backgroundColor: statusBaru ? AppTheme.successColor : AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah status pengguna'),
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : const Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Kelola Pengguna',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau email...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
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
                children: ['semua', 'User', 'Helpdesk', 'Admin'].map((r) {
                  final isActive = _filterRole == r;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterRole = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primaryColor : cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isActive ? AppTheme.primaryColor : (isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE)),
                              width: 0.5),
                        ),
                        child: Text(r == 'semua' ? 'Semua' : r,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : (isDark ? Colors.white60 : Colors.grey[700]))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Text('Tidak ada pengguna',
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey[500])),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          color: AppTheme.primaryColor,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                            itemCount: _filteredUsers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) => _userCard(_filteredUsers[i], isDark, cardBg),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard(UserModel user, bool isDark, Color cardBg) {
    final isMe = user.id == widget.currentUser.id;
    final roleColor = user.role == 'Admin'
        ? AppTheme.primaryColor
        : user.role == 'Helpdesk'
            ? AppTheme.warningColor
            : AppTheme.successColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: user.isActive
                ? (isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE))
                : AppTheme.dangerColor.withOpacity(0.3),
            width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: roleColor.withOpacity(0.12), shape: BoxShape.circle),
                child: Center(
                  child: Text(user.nama.isNotEmpty ? user.nama.substring(0, 1).toUpperCase() : '?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: roleColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(user.nama,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Text('(Anda)', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[400])),
                        ],
                      ],
                    ),
                    Text(user.email,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey[600]),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (!user.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.dangerColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Nonaktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.dangerColor)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: user.role,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isDark ? Colors.white38 : Colors.grey[500]),
                      dropdownColor: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: isMe ? null : (v) {
                        if (v != null && v != user.role) _ubahRole(user, v);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isMe ? null : () => _toggleAktif(user),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? (isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8F9FB))
                        : (user.isActive ? AppTheme.dangerColor.withOpacity(0.1) : AppTheme.successColor.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    user.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                    size: 18,
                    color: isMe
                        ? (isDark ? Colors.white24 : Colors.grey[400])
                        : (user.isActive ? AppTheme.dangerColor : AppTheme.successColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}