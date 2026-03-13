import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, String>> _passwords = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    try {
      final data = await _storage.read(key: 'passwords');
      if (data != null) {
        final list = jsonDecode(data) as List;
        setState(() {
          _passwords = list.map((e) => Map<String, String>.from(e)).toList();
        });
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _savePasswords() async {
    await _storage.write(key: 'passwords', value: jsonEncode(_passwords));
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          title: Text(
            'YENİ ŞİFRE EKLE',
            style: GoogleFonts.orbitron(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Site / Uygulama',
                  prefixIcon: Icon(Icons.web),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı / E-posta',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setS(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İPTAL',
                style: GoogleFonts.jetBrainsMono(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && passwordCtrl.text.isNotEmpty) {
                  setState(() {
                    _passwords.add({
                      'title': titleCtrl.text,
                      'username': usernameCtrl.text,
                      'password': passwordCtrl.text,
                      'date': DateTime.now().toIso8601String(),
                    });
                  });
                  _savePasswords();
                  Navigator.pop(context);
                }
              },
              child: const Text('KAYDET'),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label panoya kopyalandı',
          style: GoogleFonts.jetBrainsMono(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('ŞİFRE YÖNETİCİSİ')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _passwords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 64, color: primary.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz şifre yok',
                        style: GoogleFonts.jetBrainsMono(
                            color: Colors.white30, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+ butonu ile ekleyin',
                        style: GoogleFonts.jetBrainsMono(
                            color: Colors.white.withOpacity(0.2), fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _passwords.length,
                  itemBuilder: (context, index) {
                    final item = _passwords[index];
                    return _PasswordCard(
                      item: item,
                      index: index,
                      onCopy: _copyToClipboard,
                      onDelete: () {
                        setState(() => _passwords.removeAt(index));
                        _savePasswords();
                      },
                    );
                  },
                ),
    );
  }
}

class _PasswordCard extends StatefulWidget {
  final Map<String, String> item;
  final int index;
  final Function(String, String) onCopy;
  final VoidCallback onDelete;

  const _PasswordCard({
    required this.item,
    required this.index,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.web, color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item['title'] ?? '',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Username
            if ((widget.item['username'] ?? '').isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.white38, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.item['username'] ?? '',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: primary.withOpacity(0.6),
                        size: 16),
                    onPressed: () => widget.onCopy(
                        widget.item['username'] ?? '', 'Kullanıcı adı'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Password
            Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showPassword
                        ? (widget.item['password'] ?? '')
                        : '•' * (widget.item['password']?.length ?? 8),
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: primary.withOpacity(0.6),
                    size: 16,
                  ),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.copy, color: primary.withOpacity(0.6),
                      size: 16),
                  onPressed: () =>
                      widget.onCopy(widget.item['password'] ?? '', 'Şifre'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 100))
        .fadeIn()
        .slideX(begin: 0.2);
  }
}
