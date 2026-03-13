import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  double _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;
  String _generatedPassword = '';
  int _strength = 0;
  List<String> _history = [];
  final _random = Random.secure();

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    String chars = '';
    if (_uppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_lowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_numbers) chars += '0123456789';
    if (_symbols) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (chars.isEmpty) {
      chars = 'abcdefghijklmnopqrstuvwxyz';
    }

    final password = List.generate(
      _length.toInt(),
      (i) => chars[_random.nextInt(chars.length)],
    ).join();

    int strength = 0;
    if (_length >= 8) strength++;
    if (_length >= 12) strength++;
    if (_length >= 16) strength++;
    if (_uppercase && _lowercase) strength++;
    if (_numbers) strength++;
    if (_symbols) strength++;

    setState(() {
      _generatedPassword = password;
      _strength = strength;
    });
  }

  void _copyPassword() {
    if (_generatedPassword.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    setState(() {
      if (!_history.contains(_generatedPassword)) {
        _history.insert(0, _generatedPassword);
        if (_history.length > 5) _history.removeLast();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Şifre kopyalandı!', style: GoogleFonts.jetBrainsMono()),
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color get _strengthColor {
    if (_strength <= 2) return Colors.red;
    if (_strength <= 4) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  String get _strengthLabel {
    if (_strength <= 2) return 'ZAYIF';
    if (_strength <= 4) return 'ORTA';
    return 'GÜÇLÜ';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('ŞİFRE ÜRETİCİ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _strengthColor.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _strengthColor.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _generatedPassword,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Strength bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _strength / 6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GÜVENLİK: $_strengthLabel',
                        style: GoogleFonts.orbitron(
                          color: _strengthColor,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_length.toInt()} karakter',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generate,
                          icon: const Icon(Icons.refresh),
                          label: const Text('YENİ OLUŞTUR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary.withOpacity(0.2),
                            foregroundColor: primary,
                            side: BorderSide(color: primary.withOpacity(0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyPassword,
                          icon: const Icon(Icons.copy),
                          label: const Text('KOPYALA'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().scale(curve: Curves.elasticOut),

            const SizedBox(height: 20),

            // Settings
            Text(
              'AYARLAR',
              style: GoogleFonts.orbitron(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  // Length slider
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'UZUNLUK',
                              style: GoogleFonts.orbitron(
                                color: Colors.white60,
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              _length.toInt().toString(),
                              style: GoogleFonts.orbitron(
                                color: primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: primary,
                            thumbColor: primary,
                            overlayColor: primary.withOpacity(0.2),
                            inactiveTrackColor: primary.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _length,
                            min: 4,
                            max: 64,
                            divisions: 60,
                            onChanged: (v) {
                              setState(() => _length = v);
                              _generate();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: primary.withOpacity(0.1)),

                  // Toggles
                  _ToggleRow(
                    label: 'BÜYÜK HARF (A-Z)',
                    value: _uppercase,
                    onChanged: (v) {
                      setState(() => _uppercase = v);
                      _generate();
                    },
                    primary: primary,
                  ),
                  Divider(height: 1, color: primary.withOpacity(0.1)),
                  _ToggleRow(
                    label: 'KÜÇÜK HARF (a-z)',
                    value: _lowercase,
                    onChanged: (v) {
                      setState(() => _lowercase = v);
                      _generate();
                    },
                    primary: primary,
                  ),
                  Divider(height: 1, color: primary.withOpacity(0.1)),
                  _ToggleRow(
                    label: 'RAKAMLAR (0-9)',
                    value: _numbers,
                    onChanged: (v) {
                      setState(() => _numbers = v);
                      _generate();
                    },
                    primary: primary,
                  ),
                  Divider(height: 1, color: primary.withOpacity(0.1)),
                  _ToggleRow(
                    label: 'SEMBOLLER (!@#\$...)',
                    value: _symbols,
                    onChanged: (v) {
                      setState(() => _symbols = v);
                      _generate();
                    },
                    primary: primary,
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(),

            // History
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'SON KOPYALANANLAR',
                style: GoogleFonts.orbitron(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              ..._history.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            p,
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy,
                              color: primary.withOpacity(0.4), size: 16),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: p));
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primary;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primary,
            activeTrackColor: primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
