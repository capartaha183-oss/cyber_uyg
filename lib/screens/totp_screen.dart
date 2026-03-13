import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class TotpScreen extends StatefulWidget {
  const TotpScreen({super.key});

  @override
  State<TotpScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends State<TotpScreen> {
  final List<_TotpEntry> _entries = [
    _TotpEntry(name: 'Google', issuer: 'Google LLC', secret: 'JBSWY3DPEHPK3PXP'),
    _TotpEntry(name: 'GitHub', issuer: 'GitHub', secret: 'JBSWY3DPEHPK3PXQ'),
  ];

  Timer? _timer;
  int _timeLeft = 30;
  int _currentEpoch = 0;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeLeft = 30 - (epoch % 30);
    if (mounted) setState(() {
      _timeLeft = timeLeft;
      _currentEpoch = epoch ~/ 30;
    });
  }

  String _generateTotp(String secret) {
    try {
      // Decode base32 secret
      final bytes = _base32Decode(secret.toUpperCase().replaceAll(' ', ''));
      final timeBytes = _int64ToBytes(_currentEpoch);

      // HMAC-SHA1
      final hmac = Hmac(sha1, bytes);
      final hash = hmac.convert(timeBytes).bytes;

      // Dynamic truncation
      final offset = hash[hash.length - 1] & 0x0f;
      final code = ((hash[offset] & 0x7f) << 24) |
          ((hash[offset + 1] & 0xff) << 16) |
          ((hash[offset + 2] & 0xff) << 8) |
          (hash[offset + 3] & 0xff);

      return (code % 1000000).toString().padLeft(6, '0');
    } catch (e) {
      return '------';
    }
  }

  List<int> _base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    var bits = 0;
    var value = 0;
    final output = <int>[];

    for (final char in input.split('')) {
      final idx = alphabet.indexOf(char);
      if (idx == -1) continue;
      value = (value << 5) | idx;
      bits += 5;
      if (bits >= 8) {
        output.add((value >> (bits - 8)) & 0xff);
        bits -= 8;
      }
    }
    return output;
  }

  List<int> _int64ToBytes(int value) {
    final bytes = List<int>.filled(8, 0);
    for (int i = 7; i >= 0; i--) {
      bytes[i] = value & 0xff;
      value >>= 8;
    }
    return bytes;
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final issuerCtrl = TextEditingController();
    final secretCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        title: Text(
          'HESAP EKLE',
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
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Hesap Adı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: issuerCtrl,
              decoration: const InputDecoration(labelText: 'Yayıncı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secretCtrl,
              decoration: const InputDecoration(
                labelText: 'Secret Key (Base32)',
                hintText: 'JBSWY3DPEHPK3PXP',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İPTAL',
                style: GoogleFonts.jetBrainsMono(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && secretCtrl.text.isNotEmpty) {
                setState(() {
                  _entries.add(_TotpEntry(
                    name: nameCtrl.text,
                    issuer: issuerCtrl.text,
                    secret: secretCtrl.text,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('EKLE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('2FA KİMLİK DOĞRULAYICI')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          // Timer bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _timeLeft / 30,
                        strokeWidth: 4,
                        backgroundColor: primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _timeLeft < 10 ? Colors.red : primary,
                        ),
                      ),
                      Text(
                        _timeLeft.toString(),
                        style: GoogleFonts.orbitron(
                          color: _timeLeft < 10 ? Colors.red : primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KOD YENİLEME',
                      style: GoogleFonts.orbitron(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '$_timeLeft saniye kaldı',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.shield, color: primary.withOpacity(0.5), size: 28),
              ],
            ),
          ).animate().fadeIn(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final code = _generateTotp(entry.secret);
                final formattedCode =
                    '${code.substring(0, 3)} ${code.substring(3)}';

                return _TotpCard(
                  entry: entry,
                  code: formattedCode,
                  timeLeft: _timeLeft,
                  primary: primary,
                  index: index,
                  onDelete: () => setState(() => _entries.removeAt(index)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TotpEntry {
  final String name;
  final String issuer;
  final String secret;

  _TotpEntry({required this.name, required this.issuer, required this.secret});
}

class _TotpCard extends StatelessWidget {
  final _TotpEntry entry;
  final String code;
  final int timeLeft;
  final Color primary;
  final int index;
  final VoidCallback onDelete;

  const _TotpCard({
    required this.entry,
    required this.code,
    required this.timeLeft,
    required this.primary,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      entry.name[0].toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (entry.issuer.isNotEmpty)
                        Text(
                          entry.issuer,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    code,
                    style: GoogleFonts.orbitron(
                      color: timeLeft < 10 ? Colors.red : primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: primary),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: code.replaceAll(' ', '')));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kod kopyalandı',
                            style: GoogleFonts.jetBrainsMono()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn()
        .slideX(begin: 0.2);
  }
}
