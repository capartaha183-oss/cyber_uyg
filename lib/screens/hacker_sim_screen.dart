import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math';

class HackerSimScreen extends StatefulWidget {
  final Function(int xp, int score) onComplete;
  const HackerSimScreen({super.key, required this.onComplete});
  @override State<HackerSimScreen> createState() => _HackerSimScreenState();
}

class _HackerSimScreenState extends State<HackerSimScreen> with TickerProviderStateMixin {
  final _rand = Random();
  final ScrollController _scrollCtrl = ScrollController();
  late AnimationController _glowCtrl;

  int _missionIndex = 0;
  int _stepIndex = 0;
  int _score = 0;
  bool _running = false;
  bool _missionComplete = false;
  bool _waitingInput = false;
  final List<_TermLine> _output = [];
  String _inputValue = '';
  final TextEditingController _inputCtrl = TextEditingController();

  final _missions = [
    _Mission(
      title: 'GÖREV 1: İZ BIRAKMADAN GİR',
      briefing: 'Hedef: Güvenli olmayan bir test sunucusuna bağlan ve admin şifresini bul.',
      steps: [
        _Step(auto: true, lines: ['[*] Bağlantı başlatılıyor...', '[*] Hedef: 192.168.1.1:22', '[*] SSH servisi tespit edildi'], delay: 100),
        _Step(auto: true, lines: ['[*] Port taraması...', '[+] 22/tcp AÇIK - SSH', '[+] 80/tcp AÇIK - HTTP', '[-] 443/tcp KAPALI'], delay: 150),
        _Step(auto: false, prompt: 'Saldırı yöntemi seç:', options: ['Brute Force', 'Dictionary Attack', 'SQL Injection'], correctIndex: 1, lines: ['[*] Dictionary saldırısı başlatıldı...', '[*] 1000 şifre deneniyor...', '[+] ŞİFRE BULUNDU: admin123', '[+] SSH bağlantısı kuruldu!']),
        _Step(auto: true, lines: ['[+] root@server:~# ', '[*] Dosyalar listeleniyor...', '[*] flag.txt bulundu!', '[+] BAYRAK: CTF{mission_1_complete}'], delay: 200),
      ],
      reward: 200,
    ),
    _Mission(
      title: 'GÖREV 2: VERİ SIZDIRMA',
      briefing: 'Hedef: Web uygulamasındaki SQL açığını bul ve admin bilgilerini çek.',
      steps: [
        _Step(auto: true, lines: ['[*] Web uygulaması taranıyor...', '[*] URL: http://target.com/login', '[*] Giriş formu tespit edildi'], delay: 100),
        _Step(auto: true, lines: ['[*] SQL Injection testi...', "[!] Test payload: ' OR '1'='1", '[+] AÇIK TESPİT EDİLDİ!', '[+] Veritabanı: MySQL 5.7'], delay: 150),
        _Step(auto: false, prompt: 'Hangi tabloyu hedefliyorsun?', options: ['users', 'products', 'orders'], correctIndex: 0, lines: ['[*] users tablosu sorgulanıyor...', '[+] Tablo yapısı: id, username, password, email', '[+] Kayıt sayısı: 2847', '[+] Admin kaydı bulundu!']),
        _Step(auto: true, lines: ['[+] Kullanıcı: admin', '[+] Hash: 5f4dcc3b5aa765d61d8327deb882cf99', '[+] Çözüldü: password', '[+] BAŞARILI! Tüm veriler alındı.'], delay: 200),
      ],
      reward: 300,
    ),
    _Mission(
      title: 'GÖREV 3: İZLERİ SİL',
      briefing: 'Hedef: Sisteme sızdıktan sonra logları temizle ve iz bırakma.',
      steps: [
        _Step(auto: true, lines: ['[*] Sistem günlükleri analiz ediliyor...', '[*] /var/log/auth.log - 4.2MB', '[*] /var/log/apache2/access.log - 12MB', '[!] 847 giriş denemesi kaydedilmiş'], delay: 100),
        _Step(auto: false, prompt: 'İlk ne yaparsın?', options: ['Logları direkt sil', 'Logları düzenle, sadece kendi izlerini sil', 'Sistemi kapat'], correctIndex: 1, lines: ['[*] Log editörü başlatılıyor...', '[*] Kendi IP filtreleniyor: 10.0.0.5', '[+] 23 kayıt temizlendi', '[+] Log dosyası orijinal boyutuna getirildi']),
        _Step(auto: true, lines: ['[*] Bash geçmişi temizleniyor...', '[*] Temp dosyalar siliniyor...', '[*] Arka kapı kaldırılıyor...', '[+] TÜM İZLER TEMİZLENDİ!', '[+] GÖREV TAMAMLANDI'], delay: 150),
      ],
      reward: 400,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _showMissionBriefing();
  }

  @override
  void dispose() { _glowCtrl.dispose(); _scrollCtrl.dispose(); _inputCtrl.dispose(); super.dispose(); }

  void _showMissionBriefing() {
    final mission = _missions[_missionIndex];
    _addLine('═' * 40, LineType.divider);
    _addLine(mission.title, LineType.system);
    _addLine('BRIFING: ${mission.briefing}', LineType.info);
    _addLine('═' * 40, LineType.divider);
    Future.delayed(const Duration(milliseconds: 500), _runNextStep);
  }

  void _addLine(String text, LineType type) {
    setState(() => _output.add(_TermLine(text, type)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    });
  }

  Future<void> _runNextStep() async {
    final mission = _missions[_missionIndex];
    if (_stepIndex >= mission.steps.length) {
      _completeMission();
      return;
    }

    final step = mission.steps[_stepIndex];

    if (step.auto) {
      setState(() => _running = true);
      for (final line in step.lines) {
        await Future.delayed(Duration(milliseconds: step.delay + _rand.nextInt(100)));
        _addLine(line, line.startsWith('[+]') ? LineType.success : line.startsWith('[!]') ? LineType.warning : LineType.output);
        HapticFeedback.selectionClick();
      }
      setState(() => _running = false);
      _stepIndex++;
      await Future.delayed(const Duration(milliseconds: 500));
      _runNextStep();
    } else {
      _addLine('\n${step.prompt}', LineType.input);
      setState(() => _waitingInput = true);
    }
  }

  void _selectOption(int idx) {
    final step = _missions[_missionIndex].steps[_stepIndex];
    final correct = idx == step.correctIndex;
    setState(() => _waitingInput = false);

    _addLine('> ${step.options![idx]}', LineType.input);

    if (correct) {
      _addLine('[+] Doğru seçim! +50 bonus', LineType.success);
      _score += 50;
      HapticFeedback.heavyImpact();
    } else {
      _addLine('[!] Uyarı: Optimal seçim değil', LineType.warning);
      HapticFeedback.vibrate();
    }

    Future.delayed(const Duration(milliseconds: 300), () async {
      for (final line in step.lines) {
        await Future.delayed(Duration(milliseconds: 150 + _rand.nextInt(100)));
        _addLine(line, line.startsWith('[+]') ? LineType.success : line.startsWith('[!]') ? LineType.warning : LineType.output);
      }
      _stepIndex++;
      await Future.delayed(const Duration(milliseconds: 500));
      _runNextStep();
    });
  }

  void _completeMission() {
    final mission = _missions[_missionIndex];
    _score += mission.reward;
    setState(() => _missionComplete = true);
    HapticFeedback.heavyImpact();
    _addLine('\n✓ GÖREV TAMAMLANDI! +${mission.reward} puan', LineType.success);
    _addLine('Toplam: $_score puan', LineType.system);
  }

  void _nextMission() {
    if (_missionIndex >= _missions.length - 1) {
      widget.onComplete(200, _score);
      showDialog(context: context, barrierDismissible: false, builder: (_) => _FinalDialog(score: _score, onClose: () => Navigator.of(context)..pop()..pop()));
      return;
    }
    setState(() { _missionIndex++; _stepIndex = 0; _missionComplete = false; _output.clear(); });
    _showMissionBriefing();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final step = (!_waitingInput || _stepIndex >= _missions[_missionIndex].steps.length) ? null : _missions[_missionIndex].steps[_stepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF020A02),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020A02),
        title: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => Text('HACKER SİMÜLATÖRÜ',
            style: GoogleFonts.orbitron(color: primary.withOpacity(0.7 + _glowCtrl.value * 0.3), fontSize: 14, letterSpacing: 2)),
        ),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text('$_score PTS', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w900))))],
      ),
      body: Column(
        children: [
          // Mission progress
          Container(
            color: const Color(0xFF041004),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              ...List.generate(_missions.length, (i) => Container(
                width: 24, height: 24, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: i < _missionIndex ? primary.withOpacity(0.3) : i == _missionIndex ? primary.withOpacity(0.15) : Colors.transparent, border: Border.all(color: i <= _missionIndex ? primary : primary.withOpacity(0.2))),
                child: Center(child: Text('${i+1}', style: GoogleFonts.orbitron(color: i <= _missionIndex ? primary : Colors.white24, fontSize: 10, fontWeight: FontWeight.w900))),
              )),
              const Spacer(),
              Text('GÖREV ${_missionIndex + 1}/${_missions.length}', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
            ]),
          ),

          // Terminal output
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _output.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(_output[i].text, style: TextStyle(fontFamily: 'monospace', color: _output[i].color, fontSize: 12, height: 1.5)),
              ),
            ),
          ),

          // Options or running indicator
          Container(
            color: const Color(0xFF041004),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_running)
                  Padding(padding: const EdgeInsets.all(8), child: Row(children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: primary)),
                    const SizedBox(width: 8),
                    Text('çalışıyor...', style: GoogleFonts.jetBrainsMono(color: primary.withOpacity(0.6), fontSize: 11)),
                  ])),

                if (_waitingInput && step != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: step.options!.asMap().entries.map((e) => GestureDetector(
                        onTap: () => _selectOption(e.key),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(border: Border.all(color: primary.withOpacity(0.3)), borderRadius: BorderRadius.circular(8), color: primary.withOpacity(0.05)),
                          child: Text('[${e.key + 1}] ${e.value}', style: GoogleFonts.jetBrainsMono(color: primary, fontSize: 12)),
                        ),
                      )).toList(),
                    ),
                  ),

                if (_missionComplete)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: _nextMission,
                      style: ElevatedButton.styleFrom(backgroundColor: primary, minimumSize: const Size(double.infinity, 44)),
                      child: Text(_missionIndex >= _missions.length - 1 ? '🏆 TAMAMLA' : 'SONRAKİ GÖREV →', style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mission { final String title, briefing; final List<_Step> steps; final int reward; _Mission({required this.title, required this.briefing, required this.steps, required this.reward}); }
class _Step { final bool auto; final List<String> lines; final int delay; final String? prompt; final List<String>? options; final int? correctIndex; _Step({required this.auto, required this.lines, this.delay = 100, this.prompt, this.options, this.correctIndex}); }

enum LineType { input, output, success, warning, info, system, divider }
class _TermLine { final String text; final LineType type; _TermLine(this.text, this.type); Color get color { switch (type) { case LineType.input: return const Color(0xFF00FF88); case LineType.success: return const Color(0xFF00FF88); case LineType.warning: return const Color(0xFFFFAA00); case LineType.info: return const Color(0xFF00D4FF); case LineType.system: return const Color(0xFFAA44FF); case LineType.divider: return Colors.white12; default: return Colors.white60; } } }

class _FinalDialog extends StatelessWidget {
  final int score; final VoidCallback onClose;
  const _FinalDialog({required this.score, required this.onClose});
  @override Widget build(BuildContext context) => Dialog(
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('💻', style: TextStyle(fontSize: 56)).animate().scale(curve: Curves.elasticOut),
      const SizedBox(height: 12),
      Text('TÜM GÖREVLER TAMAMLANDI', style: GoogleFonts.orbitron(color: const Color(0xFF00FF88), fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text('$score', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.w900)),
      Text('toplam puan', style: GoogleFonts.jetBrainsMono(color: Colors.white38)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: onClose, child: const Text('KAPAT')),
    ])),
  );
}
