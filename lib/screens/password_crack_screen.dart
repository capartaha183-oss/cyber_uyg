import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';

class PasswordCrackScreen extends StatefulWidget {
  final Function(int xp, int score) onComplete;
  const PasswordCrackScreen({super.key, required this.onComplete});
  @override State<PasswordCrackScreen> createState() => _PasswordCrackScreenState();
}

class _PasswordCrackScreenState extends State<PasswordCrackScreen> with TickerProviderStateMixin {
  final _rand = Random();
  int _level = 0;
  int _score = 0;
  bool _cracking = false;
  bool _cracked = false;
  double _progress = 0;
  String _currentAttempt = '';
  String _method = '';
  Timer? _timer;
  late AnimationController _glowCtrl;

  final _levels = [
    _CrackLevel(hash: '5f4dcc3b5aa765d61d8327deb882cf99', type: 'MD5', hint: 'Çok yaygın bir kelime', answer: 'password', method: 'Dictionary Attack', difficulty: 1),
    _CrackLevel(hash: '827ccb0eea8a706c4c34a16891f84e7b', type: 'MD5', hint: '6 haneli rakam', answer: '123456', method: 'Brute Force', difficulty: 1),
    _CrackLevel(hash: 'abc123_simulated_sha256', type: 'SHA-256', hint: 'Harf+rakam kombinasyonu', answer: 'abc123', method: 'Rainbow Table', difficulty: 2),
    _CrackLevel(hash: 'qwerty_simulated_bcrypt', type: 'bcrypt', hint: 'Klavye sırası', answer: 'qwerty', method: 'Dictionary Attack', difficulty: 2),
    _CrackLevel(hash: 'tr0ub4dor_simulated', type: 'SHA-512', hint: 'Leetspeak ile yazılmış', answer: 'tr0ub4dor', method: 'Hybrid Attack', difficulty: 3),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() { _glowCtrl.dispose(); _timer?.cancel(); super.dispose(); }

  void _startCrack() {
    if (_cracking || _cracked) return;
    final lvl = _levels[_level];
    setState(() { _cracking = true; _progress = 0; _cracked = false; _method = lvl.method; });
    HapticFeedback.lightImpact();

    final duration = (2000 + lvl.difficulty * 1500).toDouble();
    final steps = 60;
    int step = 0;

    _timer = Timer.periodic(Duration(milliseconds: (duration / steps).round()), (t) {
      step++;
      final prog = step / steps;

      // Generate random attempts
      final chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#\$';
      final attemptLen = 4 + _rand.nextInt(6);
      final attempt = List.generate(attemptLen, (_) => chars[_rand.nextInt(chars.length)]).join();

      setState(() {
        _progress = prog;
        _currentAttempt = step < steps ? attempt : lvl.answer;
      });

      if (step >= steps) {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() { _cracking = false; _cracked = true; });
      }
    });
  }

  void _nextLevel() {
    if (_level >= _levels.length - 1) {
      widget.onComplete(100, _score);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _CompletionDialog(score: _score, onClose: () => Navigator.of(context)..pop()..pop()),
      );
      return;
    }
    setState(() {
      _score += (100 * _levels[_level].difficulty);
      _level++;
      _cracked = false;
      _cracking = false;
      _progress = 0;
      _currentAttempt = '';
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final lvl = _levels[_level];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞİFRE KIRMA SİM.'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('$_score PTS', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w900)))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Level indicator
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_levels.length, (i) => Container(
                width: i == _level ? 28 : 10, height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: i < _level ? primary : i == _level ? primary : primary.withOpacity(0.2),
                ),
              )),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            // Hash display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF020A02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(lvl.type, style: GoogleFonts.orbitron(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(lvl.method, style: GoogleFonts.jetBrainsMono(color: Colors.orange, fontSize: 10))),
                ]),
                const SizedBox(height: 12),
                Text('HEDEF HASH:', style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 10, letterSpacing: 2)),
                const SizedBox(height: 6),
                SelectableText(lvl.hash, style: GoogleFonts.jetBrainsMono(color: primary, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 14),
                  const SizedBox(width: 6),
                  Text('İpucu: ${lvl.hint}', style: GoogleFonts.jetBrainsMono(color: Colors.yellow.withOpacity(0.7), fontSize: 11)),
                ]),
              ]),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Crack terminal
            Container(
              width: double.infinity,
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF020A02), borderRadius: BorderRadius.circular(16), border: Border.all(color: _cracking ? primary.withOpacity(0.5) : primary.withOpacity(0.2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _cracking ? Colors.red : _cracked ? Colors.green : Colors.white24)),
                  const SizedBox(width: 8),
                  Text(_cracking ? '${lvl.method.toUpperCase()} ÇALIŞIYOR...' : _cracked ? 'KIRILDI!' : 'HAZIR', style: GoogleFonts.jetBrainsMono(color: _cracking ? Colors.red : _cracked ? Colors.green : Colors.white38, fontSize: 11, letterSpacing: 2)),
                ]),
                const SizedBox(height: 12),
                if (_cracking || _cracked) ...[
                  Text('Deneme: ', style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 11)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      _currentAttempt,
                      key: ValueKey(_currentAttempt),
                      style: GoogleFonts.jetBrainsMono(color: _cracked ? Colors.green : Colors.white70, fontSize: _cracked ? 28 : 16, fontWeight: _cracked ? FontWeight.w900 : FontWeight.normal, letterSpacing: _cracked ? 4 : 1),
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: _progress, backgroundColor: primary.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(_cracked ? Colors.green : primary), minHeight: 6),
                  ),
                  const SizedBox(height: 4),
                  Text(_cracked ? '✓ Şifre kırıldı!' : '${(_progress * 100).round()}% tamamlandı', style: GoogleFonts.jetBrainsMono(color: _cracked ? Colors.green : Colors.white38, fontSize: 10)),
                ] else
                  Center(child: Text('Kırmaya başlamak için butona bas', style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 12))),
              ]),
            ),

            const SizedBox(height: 20),

            if (!_cracked && !_cracking)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startCrack,
                  icon: const Icon(Icons.lock_open),
                  label: Text('KIRMAYI BAŞLAT', style: GoogleFonts.orbitron(letterSpacing: 2)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ).animate().fadeIn(),

            if (_cracked) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.4))),
                child: Column(children: [
                  Text('🎯 KIRMA BAŞARILI!', style: GoogleFonts.orbitron(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Şifre: "${lvl.answer}"', style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('+${100 * lvl.difficulty} puan', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextLevel,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text(_level >= _levels.length - 1 ? 'TAMAMLA' : 'SONRAKİ SEVİYE →', style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ]),
              ).animate().fadeIn().scale(curve: Curves.elasticOut),
            ],
          ],
        ),
      ),
    );
  }
}

class _CrackLevel { final String hash, type, hint, answer, method; final int difficulty; _CrackLevel({required this.hash, required this.type, required this.hint, required this.answer, required this.method, required this.difficulty}); }

class _CompletionDialog extends StatelessWidget {
  final int score; final VoidCallback onClose;
  const _CompletionDialog({required this.score, required this.onClose});
  @override Widget build(BuildContext context) => Dialog(
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('💀', style: TextStyle(fontSize: 56)).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 12),
        Text('TÜM HASHLER KIRILDI!', style: GoogleFonts.orbitron(color: const Color(0xFF00FF88), fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Text('$score', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.w900)),
        Text('toplam puan', style: GoogleFonts.jetBrainsMono(color: Colors.white38)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onClose, child: const Text('KAPAT')),
      ]),
    ),
  );
}
