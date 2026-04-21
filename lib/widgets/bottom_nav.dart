import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../screens/dashboard_screen.dart';
import '../screens/list_tiket_screen.dart';
import '../screens/notifikasi_screen.dart';
import '../screens/profil_screen.dart';

class MainNavigation extends StatefulWidget {
  final UserModel user;
  final int initialIndex;

  const MainNavigation({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final screens = [
      DashboardScreen(user: widget.user, onNavigate: _changePage),
      ListTiketScreen(user: widget.user, onNavigate: _changePage),
      NotifikasiScreen(user: widget.user),
      ProfilScreen(user: widget.user),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
                _navItem(1, Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, 'Tiket'),
                _navItem(2, Icons.notifications_rounded, Icons.notifications_outlined, 'Notifikasi'),
                _navItem(3, Icons.person_rounded, Icons.person_outlined, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changePage(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}