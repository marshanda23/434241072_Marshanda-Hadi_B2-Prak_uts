import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'login_screen.dart';
import 'ganti_password_screen.dart';
import 'pengaturan_notifikasi_screen.dart';

class ProfilScreen extends StatefulWidget {
  final UserModel user;

  const ProfilScreen({super.key, required this.user});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late UserModel _user;
  bool _isUploadingFoto = false;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  // Ganti nama pengguna lewat dialog input sederhana, lalu update ke Supabase.
  Future<void> _gantiNama() async {
    final ctrl = TextEditingController(text: _user.nama);
    final namaBaru = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ganti Nama', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama baru',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final value = ctrl.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (namaBaru == null || namaBaru == _user.nama) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profiles').update({'nama': namaBaru}).eq('id', _user.id);
      setState(() => _user = _user.copyWith(nama: namaBaru));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama berhasil diubah'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah nama'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Ganti foto profil: pilih dari kamera/galeri, upload ke bucket 'avatars',
  // lalu simpan URL publiknya ke kolom avatar_url di tabel profiles.
  Future<void> _gantiFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryColor),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _prosesFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryColor),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _prosesFoto(ImageSource.gallery);
              },
            ),
            if (_user.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _hapusFoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _prosesFoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 512);
      if (picked == null) return;

      setState(() => _isUploadingFoto = true);
      final bytes = await picked.readAsBytes();
      // Di platform web, picked.path adalah blob URL (mis. "blob:http://localhost/uuid"),
      // bukan path file biasa — jadi ekstensi tidak bisa diambil dari path.
      // Pakai MIME type dari XFile (atau fallback ke jpg) supaya aman di web & mobile.
      final ext = _extensiFromMime(picked.mimeType) ?? _extensiFromNama(picked.name) ?? 'jpg';
      final fileName = '${_user.id}.$ext';

      final supabase = Supabase.instance.client;
      await supabase.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: picked.mimeType ?? 'image/jpeg'),
      );

      // Tambahkan query param waktu agar Image.network tidak menampilkan cache lama
      // saat URL-nya persis sama dengan sebelumnya (nama file = user id, statis).
      final rawUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      final urlBaru = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      await supabase.from('profiles').update({'avatar_url': urlBaru}).eq('id', _user.id);

      setState(() {
        _user = _user.copyWith(avatarUrl: urlBaru);
        _isUploadingFoto = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Foto profil berhasil diubah'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => _isUploadingFoto = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source == ImageSource.camera
              ? 'Gagal mengakses kamera. Pastikan izin kamera sudah diaktifkan.'
              : 'Gagal mengubah foto profil.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Helper: ambil ekstensi file dari MIME type, contoh "image/jpeg" -> "jpg".
  // Lebih reliable daripada parsing path, karena path di web berupa blob URL.
  String? _extensiFromMime(String? mimeType) {
    if (mimeType == null) return null;
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/heic':
        return 'heic';
      default:
        return null;
    }
  }

  // Fallback: ambil ekstensi dari nama file asli (XFile.name), kalau MIME
  // type tidak tersedia. Aman dipakai karena XFile.name bukan path/URL.
  String? _extensiFromNama(String nama) {
    if (!nama.contains('.')) return null;
    final ext = nama.split('.').last.toLowerCase();
    if (ext.length > 5 || ext.isEmpty) return null; // guard terhadap nama aneh
    return ext;
  }

  Future<void> _hapusFoto() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profiles').update({'avatar_url': null}).eq('id', _user.id);
      setState(() => _user = _user.copyWith(avatarUrl: null));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Foto profil dihapus'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menghapus foto'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            children: [
              // Avatar & info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isUploadingFoto ? null : _gantiFoto,
                      child: Stack(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: _isUploadingFoto
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24, height: 24,
                                        child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2.5),
                                      ),
                                    )
                                  : _user.avatarUrl != null
                                      ? Image.network(
                                          _user.avatarUrl!,
                                          fit: BoxFit.cover,
                                          width: 80,
                                          height: 80,
                                          errorBuilder: (context, error, stack) => Center(
                                            child: Text(
                                              _user.nama.isNotEmpty ? _user.nama.substring(0, 1).toUpperCase() : '?',
                                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            _user.nama.isNotEmpty ? _user.nama.substring(0, 1).toUpperCase() : '?',
                                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                                          ),
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 24, height: 24,
                              decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _gantiNama,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_user.nama,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_outlined, size: 15, color: isDark ? Colors.white38 : Colors.grey[400]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_user.email,
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600])),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_user.role,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Column(
                  children: [
                    _infoTile(Icons.email_outlined, 'Email', _user.email, isDark),
                    _divider(isDark),
                    _infoTile(Icons.shield_outlined, 'Role', _user.role, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pengaturan
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Column(
                  children: [
                    _actionTile(Icons.person_outline_rounded, 'Ganti Nama', isDark, _gantiNama),
                    _divider(isDark),
                    _actionTile(Icons.photo_camera_outlined, 'Ganti Foto Profil', isDark, _gantiFoto),
                    _divider(isDark),
                    // Dark mode toggle — pakai ValueListenableBuilder agar reaktif
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeModeNotifier,
                      builder: (context, themeMode, _) {
                        final isOn = themeMode == ThemeMode.dark;
                        return _switchTile(
                          Icons.dark_mode_outlined,
                          'Dark Mode',
                          isOn,
                          isDark,
                          (v) {
                            themeModeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                          },
                        );
                      },
                    ),
                    _divider(isDark),
                    _actionTile(Icons.lock_outline_rounded, 'Ganti Password', isDark, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const GantiPasswordScreen()));
                    }),
                    _divider(isDark),
                    _actionTile(Icons.notifications_outlined, 'Pengaturan Notifikasi', isDark, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PengaturanNotifikasiScreen()));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.dangerColor.withOpacity(0.5)),
                    foregroundColor: AppTheme.dangerColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Keluar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E)))),
            Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white24 : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(IconData icon, String label, bool value, bool isDark, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E)))),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 0, thickness: 0.5,
      color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE),
      indent: 16, endIndent: 16,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}