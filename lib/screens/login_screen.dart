import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();

    try {
      final supabase = Supabase.instance.client;

      // Login menggunakan Supabase Auth
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        setState(() { _isLoading = false; _errorMessage = 'Email atau password salah.'; });
        return;
      }


      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (profile == null) {
        setState(() { _isLoading = false; _errorMessage = 'Profil pengguna tidak ditemukan.'; });
        return;
      }

      final user = UserModel.fromMap(profile);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation(user: user)),
      );
    } on AuthException catch (e) {
      setState(() { _isLoading = false; _errorMessage = e.message; });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = 'Terjadi kesalahan, coba lagi.'; });
    }
  }

  // build(), _label(), _field() tidak berubah sama sekali
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1C1F2E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text('E-Ticketing Helpdesk',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E), letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text('Masuk untuk melanjutkan',
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey[600])),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.08), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Email', isDark),
                            const SizedBox(height: 8),
                            _field(controller: _emailCtrl, hint: 'Masukkan email',
                                icon: Icons.email_outlined, isDark: isDark,
                                validator: (v) {
                                  if (v!.trim().isEmpty) return 'Email tidak boleh kosong';
                                  if (!v.contains('@')) return 'Format email tidak valid';
                                  return null;
                                }),
                            const SizedBox(height: 18),
                            _label('Password', isDark),
                            const SizedBox(height: 8),
                            _field(controller: _passwordCtrl, hint: 'Masukkan password',
                                icon: Icons.lock_outline_rounded, isDark: isDark, isPassword: true,
                                validator: (v) => v!.trim().isEmpty ? 'Password tidak boleh kosong' : null),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                                child: const Text('Lupa Password?', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                                ]),
                              ),
                              const SizedBox(height: 16),
                            ],
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white,
                                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun? ', style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600])),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text('Daftar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Text(text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : const Color(0xFF4A4A6A)));

  Widget _field({
    required TextEditingController controller, required String hint,
    required IconData icon, required bool isDark,
    bool isPassword = false, String? Function(String?)? validator,
  }) {
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_showPassword,
      validator: validator,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey[400]),
        prefixIcon: Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
          onPressed: () => setState(() => _showPassword = !_showPassword),
        ) : null,
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