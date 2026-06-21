import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lamaCtr = TextEditingController();
  final _baruCtr = TextEditingController();
  final _konfirmasiCtr = TextEditingController();
  bool _showLama = false;
  bool _showBaru = false;
  bool _showKonfirmasi = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _lamaCtr.dispose();
    _baruCtr.dispose();
    _konfirmasiCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final email = supabase.auth.currentUser?.email;

      if (email == null) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sesi tidak ditemukan, silakan login ulang.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // Verifikasi password lama dengan re-sign-in
      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: _lamaCtr.text.trim(),
        );
      } on AuthException {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password lama salah.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      // Password lama benar, update ke password baru
      await supabase.auth.updateUser(
        UserAttributes(password: _baruCtr.text.trim()),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password berhasil diubah!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengubah password, coba lagi.'),
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
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ganti Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icon header
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryColor, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Buat password baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 6),
            Text('Password baru minimal 6 karakter',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600])),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Password Lama', isDark),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _lamaCtr, hint: 'Masukkan password lama',
                      isDark: isDark, show: _showLama,
                      onToggle: () => setState(() => _showLama = !_showLama),
                      validator: (v) => v!.trim().isEmpty ? 'Password lama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _label('Password Baru', isDark),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _baruCtr, hint: 'Masukkan password baru',
                      isDark: isDark, show: _showBaru,
                      onToggle: () => setState(() => _showBaru = !_showBaru),
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Password baru tidak boleh kosong';
                        if (v.trim().length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _label('Konfirmasi Password Baru', isDark),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _konfirmasiCtr, hint: 'Ulangi password baru',
                      isDark: isDark, show: _showKonfirmasi,
                      onToggle: () => setState(() => _showKonfirmasi = !_showKonfirmasi),
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Konfirmasi password kosong';
                        if (v.trim() != _baruCtr.text.trim()) return 'Password tidak sama';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Simpan Password',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Text(text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : const Color(0xFF4A4A6A)));

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required bool isDark,
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    return TextFormField(
      controller: ctrl,
      obscureText: !show,
      validator: validator,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey[400]),
        prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
        suffixIcon: IconButton(
          icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
      ),
    );
  }
}