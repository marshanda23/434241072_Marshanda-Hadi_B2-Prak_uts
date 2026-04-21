import 'package:flutter/material.dart';
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
 
  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

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
                    Stack(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.user.nama.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
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
                    const SizedBox(height: 14),
                    Text(widget.user.nama,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                    const SizedBox(height: 4),
                    Text(widget.user.email,
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600])),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.user.role,
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
                    _infoTile(Icons.person_outline_rounded, 'Username', widget.user.username, isDark),
                    _divider(isDark),
                    _infoTile(Icons.email_outlined, 'Email', widget.user.email, isDark),
                    _divider(isDark),
                    _infoTile(Icons.shield_outlined, 'Role', widget.user.role, isDark),
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