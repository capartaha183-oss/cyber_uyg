import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class HashToolScreen extends StatefulWidget {
  const HashToolScreen({super.key});

  @override
  State<HashToolScreen> createState() => _HashToolScreenState();
}

class _HashToolScreenState extends State<HashToolScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputCtrl = TextEditingController();
  final TextEditingController _base64Ctrl = TextEditingController();

  String _md5Result = '';
  String _sha1Result = '';
  String _sha256Result = '';
  String _sha512Result = '';
  String _base64Result = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputCtrl.dispose();
    _base64Ctrl.dispose();
    super.dispose();
  }

  void _computeHashes(String input) {
    final bytes = utf8.encode(input);
    setState(() {
      _md5Result = md5.convert(bytes).toString();
      _sha1Result = sha1.convert(bytes).toString();
      _sha256Result = sha256.convert(bytes).toString();
      _sha512Result = sha512.convert(bytes).toString();
    });
  }

  void _computeBase64(String input) {
    setState(() {
      _base64Result = base64.encode(utf8.encode(input));
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopyalandı', style: GoogleFonts.jetBrainsMono()),
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HASH & ŞİFRELEME'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelStyle: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 1),
          tabs: const [
            Tab(text: 'HASH'),
            Tab(text: 'BASE64'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Hash tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _inputCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Metin girin',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  onChanged: _computeHashes,
                ).animate().fadeIn(),

                const SizedBox(height: 16),

                if (_md5Result.isNotEmpty) ...[
                  _HashResultCard(
                    label: 'MD5',
                    value: _md5Result,
                    color: primary,
                    onCopy: () => _copyToClipboard(_md5Result, 'MD5'),
                  ),
                  _HashResultCard(
                    label: 'SHA-1',
                    value: _sha1Result,
                    color: secondary,
                    onCopy: () => _copyToClipboard(_sha1Result, 'SHA-1'),
                  ),
                  _HashResultCard(
                    label: 'SHA-256',
                    value: _sha256Result,
                    color: const Color(0xFFFF6B35),
                    onCopy: () => _copyToClipboard(_sha256Result, 'SHA-256'),
                  ),
                  _HashResultCard(
                    label: 'SHA-512',
                    value: _sha512Result,
                    color: const Color(0xFFAA44FF),
                    onCopy: () => _copyToClipboard(_sha512Result, 'SHA-512'),
                  ),
                ],
              ],
            ),
          ),

          // Base64 tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _base64Ctrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Metin girin',
                    alignLabelWithHint: true,
                  ),
                  onChanged: _computeBase64,
                ).animate().fadeIn(),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _computeBase64(_base64Ctrl.text),
                        icon: const Icon(Icons.lock),
                        label: const Text('ENCODE'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondary,
                        ),
                        onPressed: () {
                          try {
                            final decoded =
                                utf8.decode(base64.decode(_base64Ctrl.text));
                            setState(() => _base64Result = decoded);
                          } catch (_) {
                            setState(() => _base64Result = 'Geçersiz Base64!');
                          }
                        },
                        icon: const Icon(Icons.lock_open),
                        label: const Text('DECODE'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (_base64Result.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'SONUÇ',
                              style: GoogleFonts.orbitron(
                                color: primary,
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(Icons.copy, color: primary, size: 18),
                              onPressed: () =>
                                  _copyToClipboard(_base64Result, 'Sonuç'),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _base64Result,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HashResultCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onCopy;

  const _HashResultCard({
    required this.label,
    required this.value,
    required this.color,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.copy, color: color.withOpacity(0.7), size: 16),
                onPressed: onCopy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
