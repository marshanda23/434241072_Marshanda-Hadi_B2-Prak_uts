import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/ticket_model.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class CreateTiketScreen extends StatefulWidget {
  final UserModel user;

  const CreateTiketScreen({super.key, required this.user});

  @override
  State<CreateTiketScreen> createState() => _CreateTiketScreenState();
}

class _CreateTiketScreenState extends State<CreateTiketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  String _kategori = 'Akses Sistem';
  String _prioritas = 'medium';
  bool _isLoading = false;

  final List<String> _kategoris = [
    'Akses Sistem', 'Hardware', 'Software', 'Jaringan', 'Fasilitas', 'Lainnya'
  ];

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final newTiket = TicketModel(
      id: 'TKT-00${DummyData.tikets.length + 1}',
      judul: _judulCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      status: 'open',
      prioritas: _prioritas,
      kategori: _kategori,
      pembuatUsername: widget.user.username,
      createdAt: DateTime.now(),
    );

    DummyData.tikets.insert(0, newTiket);

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tiket berhasil dibuat!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
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
        title: Text('Buat Tiket',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFEEEEEE), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Judul Tiket', isDark),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _judulCtrl,
                      hint: 'Contoh: Tidak bisa login ke SIAKAD',
                      isDark: isDark,
                      validator: (v) => v!.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _label('Kategori', isDark),
                    const SizedBox(height: 8),
                    _buildDropdown(isDark),
                    const SizedBox(height: 16),
                    _label('Prioritas', isDark),
                    const SizedBox(height: 10),
                    _buildPrioritas(isDark),
                    const SizedBox(height: 16),
                    _label('Deskripsi', isDark),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _deskripsiCtrl,
                      hint: 'Jelaskan masalah yang Anda alami secara detail...',
                      isDark: isDark,
                      maxLines: 5,
                      validator: (v) => v!.trim().isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _label('Lampiran (Opsional)', isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur upload akan tersedia setelah terhubung backend')),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0xFFE0E0E0),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 24,
                                color: isDark ? Colors.white38 : Colors.grey[400]),
                            const SizedBox(height: 4),
                            Text('Klik untuk upload gambar / file',
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[400])),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Kirim Tiket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF4A4A6A)),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey[400]),
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

  Widget _buildDropdown(bool isDark) {
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    return DropdownButtonFormField<String>(
      value: _kategori,
      onChanged: (v) => setState(() => _kategori = v!),
      dropdownColor: isDark ? const Color(0xFF1C1F2E) : Colors.white,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
      ),
      items: _kategoris.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
    );
  }

  Widget _buildPrioritas(bool isDark) {
    return Row(
      children: ['low', 'medium', 'high'].map((p) {
        final isActive = _prioritas == p;
        final color = AppTheme.prioritasColor(p);
        final label = AppTheme.prioritasLabel(p);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _prioritas = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.15) : (isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8F9FB)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? color : (isDark ? Colors.white12 : const Color(0xFFE0E0E0))),
              ),
              child: Column(
                children: [
                  Icon(Icons.circle, size: 10, color: isActive ? color : Colors.grey),
                  const SizedBox(height: 4),
                  Text(label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: isActive ? color : (isDark ? Colors.white38 : Colors.grey[500]))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}