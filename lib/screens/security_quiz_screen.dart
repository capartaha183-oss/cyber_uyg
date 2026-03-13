import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class SecurityQuizScreen extends StatefulWidget {
  final Function(int xp, int score) onComplete;
  const SecurityQuizScreen({super.key, required this.onComplete});
  @override State<SecurityQuizScreen> createState() => _SecurityQuizScreenState();
}

class _SecurityQuizScreenState extends State<SecurityQuizScreen> with TickerProviderStateMixin {
  late AnimationController _timerCtrl;
  int _currentQ = 0;
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 15;
  Timer? _timer;
  int? _selectedAnswer;
  bool _answered = false;

  final _questions = [
    _Question('Hangi şifreleme algoritması en güvenlidir?', ['MD5', 'SHA-1', 'AES-256', 'DES'], 2, 'AES-256, günümüzde en güçlü simetrik şifreleme algoritmasıdır.'),
    _Question('Phishing saldırısı nedir?', ['Ağ taraması', 'Sahte e-posta ile bilgi çalma', 'Şifre deneme', 'Virüs yerleştirme'], 1, 'Phishing, kullanıcıları kandırarak kişisel bilgilerini çalmaya çalışan sosyal mühendislik saldırısıdır.'),
    _Question('VPN ne işe yarar?', ['İnterneti hızlandırır', 'Bilgisayarı korur', 'IP adresini gizler ve trafiği şifreler', 'Virüsleri temizler'], 2, 'VPN, internet trafiğinizi şifreleyerek IP adresinizi gizler.'),
    _Question('2FA (İki Faktörlü Kimlik) neden önemlidir?', ['Daha hızlı giriş sağlar', 'Şifre unutulduğunda kullanılır', 'Şifre çalınsa bile hesabı korur', 'İnternet hızını artırır'], 2, '2FA, şifreniz ele geçirilse bile hesabınıza erişimi engeller.'),
    _Question('SQL Injection nedir?', ['Veritabanına virüs ekleme', 'Kötü amaçlı SQL kodu enjekte etme', 'Ağ paketlerini izleme', 'Şifreyi brute force ile kırma'], 1, 'SQL Injection, web uygulamalarındaki güvenlik açıklarından yararlanarak veritabanını manipüle etmektir.'),
    _Question('HTTPS bağlantısında hangi port kullanılır?', ['80', '21', '443', '8080'], 2, 'HTTPS, 443 numaralı port üzerinden SSL/TLS ile şifreli bağlantı kurar.'),
    _Question('Bir şifreden en az kaç karakter olmalıdır?', ['6', '8', '12', '16'], 2, '12 karakter, günümüz brute force saldırılarına karşı minimum güvenli uzunluktur.'),
    _Question('Zero-Day açığı nedir?', ['Sıfır gün içinde düzeltilen açık', 'Henüz bilinmeyen ve yaması olmayan açık', 'Her gün tekrar eden saldırı', 'Sıfır riskli yazılım'], 1, 'Zero-Day açıkları, yazılım üreticisinin henüz haberdar olmadığı güvenlik açıklarıdır.'),
    _Question('Man-in-the-Middle saldırısı ne demektir?', ['Bilgisayarın ortasındaki virüs', 'İki taraf arasına girerek iletişimi dinleme', 'Orta şiddetli DDoS saldırısı', 'Fiziksel sunucu saldırısı'], 1, 'MITM saldırısında saldırgan, iki taraf arasındaki iletişimi gizlice dinler veya değiştirir.'),
    _Question('Hangi protokol e-posta şifrelemede kullanılır?', ['FTP', 'HTTP', 'PGP', 'DNS'], 2, 'PGP (Pretty Good Privacy), e-posta şifrelemesinde yaygın olarak kullanılır.'),
  ];

  @override
  void initState() {
    super.initState();
    _timerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _startTimer();
  }

  void _startTimer() {
    _timerCtrl.forward(from: 0);
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { t.cancel(); _timeUp(); }
    });
  }

  void _timeUp() {
    if (_answered) return;
    setState(() { _answered = true; _streak = 0; });
    HapticFeedback.vibrate();
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _answer(int idx) {
    if (_answered) return;
    _timer?.cancel();
    _timerCtrl.stop();

    final correct = idx == _questions[_currentQ].correctIndex;
    final timeBonus = (_timeLeft * 2);
    final points = correct ? (100 + timeBonus + (_streak * 20)) : 0;

    setState(() {
      _selectedAnswer = idx;
      _answered = true;
      if (correct) {
        _score += points;
        _streak++;
        HapticFeedback.lightImpact();
      } else {
        _streak = 0;
        HapticFeedback.vibrate();
      }
    });

    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentQ >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() { _currentQ++; _selectedAnswer = null; _answered = false; });
    _startTimer();
  }

  void _finish() {
    _timer?.cancel();
    final xp = (_score / 10).round().clamp(10, 50);
    widget.onComplete(xp, _score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(score: _score, total: _questions.length * 100, onClose: () => Navigator.of(context)..pop()..pop()),
    );
  }

  @override
  void dispose() { _timerCtrl.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final q = _questions[_currentQ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('GÜVENLİK QUİZ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('$_score PTS', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w900))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress & timer
            Row(children: [
              Text('${_currentQ + 1}/${_questions.length}', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 12)),
              const SizedBox(width: 12),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentQ + 1) / _questions.length,
                  backgroundColor: primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                  minHeight: 6,
                ),
              )),
              const SizedBox(width: 12),
              // Timer circle
              SizedBox(
                width: 40, height: 40,
                child: Stack(alignment: Alignment.center, children: [
                  AnimatedBuilder(
                    animation: _timerCtrl,
                    builder: (_, __) => CircularProgressIndicator(
                      value: 1 - _timerCtrl.value,
                      strokeWidth: 4,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(_timeLeft <= 5 ? Colors.red : primary),
                    ),
                  ),
                  Text('$_timeLeft', style: GoogleFonts.orbitron(color: _timeLeft <= 5 ? Colors.red : primary, fontSize: 12, fontWeight: FontWeight.w900)),
                ]),
              ),
            ]).animate().fadeIn(),

            if (_streak >= 2)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('🔥 $_streak\'lı seri! +${_streak * 20} bonus XP', style: GoogleFonts.jetBrainsMono(color: Colors.orange, fontSize: 11)),
                ),
              ),

            const SizedBox(height: 24),

            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Text(q.question, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.4), textAlign: TextAlign.center),
            ).animate(key: ValueKey(_currentQ)).fadeIn().slideY(begin: -0.2),

            const SizedBox(height: 20),

            // Answers
            ...q.answers.asMap().entries.map((entry) {
              final i = entry.key;
              final ans = entry.value;
              Color borderColor = primary.withOpacity(0.25);
              Color bgColor = Theme.of(context).colorScheme.surface;
              Color textColor = Colors.white70;

              if (_answered) {
                if (i == q.correctIndex) { borderColor = Colors.green; bgColor = Colors.green.withOpacity(0.15); textColor = Colors.green; }
                else if (i == _selectedAnswer) { borderColor = Colors.red; bgColor = Colors.red.withOpacity(0.15); textColor = Colors.red; }
                else { borderColor = Colors.white12; textColor = Colors.white30; }
              }

              return GestureDetector(
                onTap: () => _answer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: 1.5)),
                  child: Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor.withOpacity(0.2), border: Border.all(color: borderColor)),
                      child: Center(child: Text(['A','B','C','D'][i], style: GoogleFonts.orbitron(color: borderColor, fontSize: 11, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(ans, style: GoogleFonts.jetBrainsMono(color: textColor, fontSize: 13))),
                    if (_answered && i == q.correctIndex) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    if (_answered && i == _selectedAnswer && i != q.correctIndex) const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ]),
                ),
              ).animate(key: ValueKey('$_currentQ-$i'), delay: Duration(milliseconds: i * 80)).fadeIn().slideX(begin: 0.2);
            }),

            // Explanation
            if (_answered)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(q.explanation, style: GoogleFonts.jetBrainsMono(color: Colors.white60, fontSize: 11))),
                ]),
              ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _Question {
  final String question, explanation;
  final List<String> answers;
  final int correctIndex;
  _Question(this.question, this.answers, this.correctIndex, this.explanation);
}

class _ResultDialog extends StatelessWidget {
  final int score, total;
  final VoidCallback onClose;
  const _ResultDialog({required this.score, required this.total, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final pct = (score / total * 100).clamp(0, 100).round();
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(pct >= 70 ? '🏆' : pct >= 40 ? '👍' : '💀', style: const TextStyle(fontSize: 56)).animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text('QUIZ TAMAMLANDI', style: GoogleFonts.orbitron(color: primary, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text('$score', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.w900)).animate().scale(curve: Curves.elasticOut, delay: 300.ms),
          Text('puan', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 8),
          Text('%$pct başarı', style: GoogleFonts.orbitron(color: pct >= 70 ? primary : Colors.orange, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onClose, child: const Text('TAMAM')),
        ]),
      ),
    );
  }
}
