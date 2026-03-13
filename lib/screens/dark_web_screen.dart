import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class DarkWebMonitorScreen extends StatefulWidget {
  const DarkWebMonitorScreen({super.key});
  @override State<DarkWebMonitorScreen> createState() => _DarkWebMonitorScreenState();
}

class _DarkWebMonitorScreenState extends State<DarkWebMonitorScreen> with TickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _scanning = false;
  bool _scanned = false;
  List<_DarkWebFind> _findings = [];
  int _scanStep = 0;
  late AnimationController _pulseCtrl;
  final _rand = Random();

  final _scanSteps = [
    'Tor ağına bağlanılıyor...',
    'Dark web veritabanları taranıyor...',
    'Paste siteleri kontrol ediliyor...',
    'Forum kayıtları aranıyor...',
    'Credential dump\'lar kontrol ediliyor...',
    'Sonuçlar analiz ediliyor...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  Future<void> _scan() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) return;

    setState(() { _scanning = true; _findings = []; _scanStep = 0; _scanned = false; });

    for (int i = 0; i < _scanSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) setState(() => _scanStep = i);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Simulated results
    final found = email.contains('test') || email.contains('admin') || email.length < 10;
    if (found) {
      _findings = [
        _DarkWebFind(source: 'RaidForums Dump', date: '2023-08', dataTypes: ['E-posta', 'MD5 Hash', 'İsim'], severity: FindSeverity.high, description: 'Kullanıcı bilgileri RaidForums sitesinde sızdırıldı.'),
        _DarkWebFind(source: 'Pastebin Leak', date: '2022-11', dataTypes: ['E-posta', 'Şifre'], severity: FindSeverity.critical, description: 'E-posta ve şifre çifti Pastebin\'de açık metin olarak yayınlandı.'),
        _DarkWebFind(source: 'Telegram Kanal', date: '2024-01', dataTypes: ['Telefon', 'E-posta'], severity: FindSeverity.medium, description: 'Telegram kanalında kişisel veri paketi içinde bulundu.'),
      ];
    }

    setState(() { _scanning = false; _scanned = true; });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05050A),
        title: Text('DARK WEB İZLEME', style: GoogleFonts.orbitron(color: const Color(0xFFAA44FF), fontSize: 15, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.dark_mode, color: Colors.purple, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Dark web\'deki sızıntı veritabanları simüle edilerek kontrol edilir.', style: GoogleFonts.jetBrainsMono(color: Colors.purple.withOpacity(0.7), fontSize: 10))),
              ]),
            ),

            // Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Column(children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.jetBrainsMono(color: Colors.white70),
                  decoration: InputDecoration(
                    labelText: 'E-posta adresi',
                    labelStyle: GoogleFonts.jetBrainsMono(color: Colors.purple.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.alternate_email, color: Colors.purple),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.purple.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.purple, width: 2)),
                  ),
                  onSubmitted: (_) => _scan(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                    onPressed: _scanning ? null : _scan,
                    icon: _scanning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.travel_explore),
                    label: Text(_scanning ? 'TARANYOR...' : 'DARK WEB TARA', style: GoogleFonts.orbitron(letterSpacing: 2)),
                  ),
                ),
              ]),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Scan progress
            if (_scanning)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: Column(
                  children: _scanSteps.asMap().entries.map((entry) {
                    final i = entry.key;
                    final step = entry.value;
                    final done = i < _scanStep;
                    final current = i == _scanStep;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        SizedBox(width: 20, child: done
                          ? const Icon(Icons.check, color: Colors.green, size: 16)
                          : current
                            ? AnimatedBuilder(animation: _pulseCtrl, builder: (_, __) => Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.withOpacity(0.5 + _pulseCtrl.value * 0.5))))
                            : Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white12))),
                        const SizedBox(width: 8),
                        Text(step, style: GoogleFonts.jetBrainsMono(color: done ? Colors.green : current ? Colors.purple : Colors.white24, fontSize: 11)),
                      ]),
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(),

            // Results
            if (_scanned) ...[
              if (_findings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(children: [
                    const Icon(Icons.verified_user, color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    Text('TEMİZ!', style: GoogleFonts.orbitron(color: Colors.green, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text('Bu e-posta dark web\'de bulunamadı.', style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
                  ]),
                ).animate().fadeIn().scale(curve: Curves.elasticOut)
              else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.dangerous, color: Colors.red, size: 32),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${_findings.length} KAYIT BULUNDU!', style: GoogleFonts.orbitron(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w900)),
                      Text('Şifrelerinizi hemen değiştirin!', style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 11)),
                    ])),
                  ]),
                ).animate().fadeIn(),
                const SizedBox(height: 12),
                ..._findings.asMap().entries.map((entry) {
                  final find = entry.value;
                  final severityColors = {FindSeverity.low: Colors.yellow, FindSeverity.medium: Colors.orange, FindSeverity.high: Colors.red, FindSeverity.critical: const Color(0xFFFF0055)};
                  final severityLabels = {FindSeverity.low: 'DÜŞÜK', FindSeverity.medium: 'ORTA', FindSeverity.high: 'YÜKSEK', FindSeverity.critical: 'KRİTİK'};
                  final c = severityColors[find.severity]!;

                  return Card(
                    color: const Color(0xFF0D0D18),
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: c.withOpacity(0.3))),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(Icons.leak_add, color: c, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(find.source, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(severityLabels[find.severity]!, style: GoogleFonts.orbitron(color: c, fontSize: 8, fontWeight: FontWeight.w700))),
                        ]),
                        const SizedBox(height: 6),
                        Text(find.description, style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, children: find.dataTypes.map((dt) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: Text(dt, style: GoogleFonts.jetBrainsMono(color: Colors.purple.withOpacity(0.8), fontSize: 10)),
                        )).toList()),
                        const SizedBox(height: 4),
                        Text('Tarih: ${find.date}', style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 9)),
                      ]),
                    ),
                  ).animate(delay: Duration(milliseconds: entry.key * 100)).fadeIn().slideY(begin: 0.2);
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

enum FindSeverity { low, medium, high, critical }
class _DarkWebFind {
  final String source, date, description; final List<String> dataTypes; final FindSeverity severity;
  _DarkWebFind({required this.source, required this.date, required this.dataTypes, required this.severity, required this.description});
}
