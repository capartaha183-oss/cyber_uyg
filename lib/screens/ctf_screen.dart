import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CtfScreen extends StatefulWidget {
  final Function(int xp, int score) onComplete;
  const CtfScreen({super.key, required this.onComplete});
  @override State<CtfScreen> createState() => _CtfScreenState();
}

class _CtfScreenState extends State<CtfScreen> {
  final List<_CtfChallenge> _challenges = [
    _CtfChallenge(
      id: 0, title: 'İlk Adım', category: 'KOLAY', points: 50,
      description: 'Aşağıdaki Base64 kodunu çöz ve bayrağı bul:',
      code: 'Q1RGe2Jhc2U2NF9pc19ub3RfZW5jcnlwdGlvbn0=',
      hint: 'Base64 decode et',
      answer: 'CTF{base64_is_not_encryption}',
      type: CtfType.crypto,
    ),
    _CtfChallenge(
      id: 1, title: 'Morse Mesajı', category: 'KOLAY', points: 75,
      description: 'Bu Morse kodunu çöz:',
      code: '-.-. - ..-. / .-- . .-.. -.-. --- -- .',
      hint: 'Morse alfabesini kullan. "/" kelime ayırıcıdır.',
      answer: 'CTF WELCOME',
      type: CtfType.crypto,
    ),
    _CtfChallenge(
      id: 2, title: 'Hex Sırı', category: 'ORTA', points: 100,
      description: 'Bu hex değerini ASCII\'ye çevir:',
      code: '43 54 46 7B 68 65 78 5F 74 6F 5F 61 73 63 69 69 7D',
      hint: 'Her iki hex = bir karakter',
      answer: 'CTF{hex_to_ascii}',
      type: CtfType.crypto,
    ),
    _CtfChallenge(
      id: 3, title: 'ROT13', category: 'ORTA', points: 100,
      description: 'ROT13 ile şifrelenmiş metni çöz:',
      code: 'PGS{ebg13_vf_rnfl}',
      hint: 'Her harf 13 pozisyon kaydırılmış',
      answer: 'CTF{rot13_is_easy}',
      type: CtfType.crypto,
    ),
    _CtfChallenge(
      id: 4, title: 'Gizli Sayı', category: 'ZOR', points: 150,
      description: 'Binary\'yi decimal\'e çevir ve bayrağı bul:\n01000011 01010100 01000110',
      code: '01000011 01010100 01000110',
      hint: 'Binary → ASCII karakter. Sonuç 3 harfli.',
      answer: 'CTF',
      type: CtfType.binary,
    ),
  ];

  final Map<int, bool> _solved = {};
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, bool> _showHints = {};
  final Map<int, bool> _wrong = {};
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    for (final c in _challenges) {
      _controllers[c.id] = TextEditingController();
      _showHints[c.id] = false;
      _wrong[c.id] = false;
    }
  }

  @override
  void dispose() { for (final c in _controllers.values) c.dispose(); super.dispose(); }

  void _submit(int id) {
    final challenge = _challenges.firstWhere((c) => c.id == id);
    final input = _controllers[id]!.text.trim();
    final correct = input.toUpperCase() == challenge.answer.toUpperCase();

    if (correct) {
      HapticFeedback.heavyImpact();
      setState(() { _solved[id] = true; _totalScore += challenge.points; _wrong[id] = false; });
      if (_solved.length == _challenges.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onComplete(150, _totalScore);
          showDialog(
            context: context, barrierDismissible: false,
            builder: (_) => _CtfCompleteDialog(score: _totalScore, onClose: () => Navigator.of(context)..pop()..pop()),
          );
        });
      }
    } else {
      HapticFeedback.vibrate();
      setState(() => _wrong[id] = true);
      Future.delayed(const Duration(seconds: 1), () { if (mounted) setState(() => _wrong[id] = false); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final solvedCount = _solved.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CTF BULMACALARI'),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text('$_totalScore PTS', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w900))))],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withOpacity(0.3))),
            child: Row(children: [
              Text('🚩', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$solvedCount / ${_challenges.length} BAYRAK BULUNDU', style: GoogleFonts.orbitron(color: primary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: solvedCount / _challenges.length, backgroundColor: primary.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(primary), minHeight: 8)),
              ])),
            ]),
          ).animate().fadeIn(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _challenges.length,
              itemBuilder: (context, i) {
                final c = _challenges[i];
                final solved = _solved[c.id] == true;
                final wrong = _wrong[c.id] == true;
                final catColors = {'KOLAY': Colors.green, 'ORTA': Colors.orange, 'ZOR': Colors.red};
                final catColor = catColors[c.category] ?? primary;
                final typeIcons = {CtfType.crypto: Icons.vpn_key, CtfType.binary: Icons.code};

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: solved ? Colors.green.withOpacity(0.5) : primary.withOpacity(0.2), width: solved ? 2 : 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(typeIcons[c.type] ?? Icons.flag, color: solved ? Colors.green : catColor, size: 22),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c.title, style: GoogleFonts.orbitron(color: solved ? Colors.green : Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: catColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(c.category, style: GoogleFonts.orbitron(color: catColor, fontSize: 9, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 6),
                        Text('+${c.points}', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w700)),
                        if (solved) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check_circle, color: Colors.green, size: 20)),
                      ]),
                      const SizedBox(height: 10),
                      Text(c.description, style: GoogleFonts.jetBrainsMono(color: Colors.white60, fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF020A02), borderRadius: BorderRadius.circular(10), border: Border.all(color: primary.withOpacity(0.2))),
                        child: SelectableText(c.code, style: GoogleFonts.jetBrainsMono(color: primary, fontSize: 12, letterSpacing: 1)),
                      ),
                      if (_showHints[c.id] == true) ...[
                        const SizedBox(height: 8),
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.yellow.withOpacity(0.2))),
                          child: Row(children: [const Icon(Icons.lightbulb, color: Colors.yellow, size: 14), const SizedBox(width: 6), Expanded(child: Text(c.hint, style: GoogleFonts.jetBrainsMono(color: Colors.yellow.withOpacity(0.7), fontSize: 11)))]),
                        ),
                      ],
                      if (!solved) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: TextField(
                            controller: _controllers[c.id],
                            style: GoogleFonts.jetBrainsMono(color: wrong ? Colors.red : Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'CTF{...}',
                              hintStyle: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 13),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: wrong ? Colors.red : primary.withOpacity(0.3))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: wrong ? Colors.red : primary, width: 2)),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _submit(c.id),
                          )),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: () => _submit(c.id), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), child: Text('GÖNDEr', style: GoogleFonts.orbitron(fontSize: 10))),
                        ]),
                        TextButton.icon(
                          onPressed: () => setState(() => _showHints[c.id] = !(_showHints[c.id] ?? false)),
                          icon: Icon(Icons.lightbulb_outline, size: 14, color: Colors.yellow.withOpacity(0.5)),
                          label: Text('İpucu', style: GoogleFonts.jetBrainsMono(color: Colors.yellow.withOpacity(0.5), fontSize: 11)),
                        ),
                      ] else
                        Padding(padding: const EdgeInsets.only(top: 8), child: Text('✓ Çözüldü: ${c.answer}', style: GoogleFonts.jetBrainsMono(color: Colors.green, fontSize: 11))),
                    ]),
                  ),
                ).animate(delay: Duration(milliseconds: i * 100)).fadeIn().slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CtfType { crypto, binary, web, forensic }
class _CtfChallenge { final int id, points; final String title, category, description, code, hint, answer; final CtfType type; _CtfChallenge({required this.id, required this.title, required this.category, required this.points, required this.description, required this.code, required this.hint, required this.answer, required this.type}); }

class _CtfCompleteDialog extends StatelessWidget {
  final int score; final VoidCallback onClose;
  const _CtfCompleteDialog({required this.score, required this.onClose});
  @override Widget build(BuildContext context) => Dialog(
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🏁', style: TextStyle(fontSize: 56)).animate().scale(curve: Curves.elasticOut),
      const SizedBox(height: 12),
      Text('TÜM BAYRAKLAR TOPLANDTI!', style: GoogleFonts.orbitron(color: const Color(0xFF00FF88), fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      Text('$score', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.w900)),
      Text('toplam puan', style: GoogleFonts.jetBrainsMono(color: Colors.white38)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: onClose, child: const Text('KAPAT')),
    ])),
  );
}
