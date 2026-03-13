import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SocialEngineeringScreen extends StatefulWidget {
  final Function(int xp, int score) onComplete;
  const SocialEngineeringScreen({super.key, required this.onComplete});
  @override State<SocialEngineeringScreen> createState() => _SocialEngineeringScreenState();
}

class _SocialEngineeringScreenState extends State<SocialEngineeringScreen> {
  int _current = 0;
  int _score = 0;
  bool _answered = false;
  int? _selected;

  final _scenarios = [
    _Scenario(
      type: 'E-POSTA',
      title: 'Şüpheli E-posta',
      content: 'Gönderen: support@g00gle-security.com\n\nKonu: ACİL: Hesabınız tehlikede!\n\nSayın Kullanıcı,\nHesabınızda şüpheli aktivite tespit ettik. 24 saat içinde aşağıdaki linke tıklayarak şifrenizi güncelleyin:\n\nhttp://g00gle-login.tk/verify\n\nAksi takdirde hesabınız silinecektir.',
      question: 'Bu e-posta güvenli mi?',
      options: ['Güvenli, Google\'dan geliyor', 'Phishing! Tıklama!', 'Emin değilim, linke tıklayacağım', 'Şifremi değiştireceğim'],
      correctIndex: 1,
      explanation: '🚨 PHISHING! "g00gle-security.com" sahte domain. Google hiçbir zaman sizi tehdit etmez. "24 saat" baskısı ve ".tk" uzantılı link şüpheli işaretlerdir.',
      redFlags: ['Sahte domain (g00gle)', 'Acele/tehdit dili', '.tk uzantılı link', 'Genel "Sayın Kullanıcı" ifadesi'],
    ),
    _Scenario(
      type: 'SMS',
      title: 'Şüpheli SMS',
      content: 'Gönderen: +90-555-0000\n\nZiraat Bankası: Kartınız geçici olarak durduruldu. Bilgilerinizi güncellemek için: bit.ly/ziraat-verify adresini ziyaret edin.',
      question: 'Bu SMS\'e nasıl tepki verirsiniz?',
      options: ['Linke tıklar bilgilerimi girerim', 'SMS\'i silerim, bankayı resmi numarasından ararım', 'Sadece adresime bakarım', 'Başkasına sorarım'],
      correctIndex: 1,
      explanation: '✅ Doğru! Banka hiçbir zaman SMS ile link göndermez. Her zaman resmi numarayı arayın veya uygulamayı kullanın.',
      redFlags: ['Bilinmeyen numara', 'bit.ly kısaltılmış link', 'Acele ifadeler', 'SMS ile kişisel bilgi isteme'],
    ),
    _Scenario(
      type: 'TELEFON',
      title: 'Telefon Dolandırıcılığı',
      content: 'Arayan: "İyi günler, Microsoft Teknik Destek\'ten arıyorum. Bilgisayarınızda ciddi bir virüs tespit ettik. Hemen müdahale etmemiz gerekiyor. Size uzaktan bağlanmamız için TeamViewer kurmanızı istiyoruz."',
      question: 'Ne yaparsınız?',
      options: ['TeamViewer kurarım', 'Bilgilerimi veririm', 'Telefonu kapatırım', 'Arkadaşıma sorarım'],
      correctIndex: 2,
      explanation: '🛑 Doğru! Microsoft asla sizi aramaz. Bu klasik "Tech Support Scam" dolandırıcılığıdır. Uzaktan erişim vermeyin!',
      redFlags: ['Microsoft sizi aramaz', 'Uzaktan erişim isteği', 'Acil/korku oluşturma', 'Çözüm için ödeme isteyebilir'],
    ),
    _Scenario(
      type: 'SOSYAL MEDYA',
      title: 'Facebook Mesajı',
      content: 'Arkadaşınızdan mesaj: "Merhaba! Çok acil bir durum var, cüzdanımı kaybettim yurt dışındayım. 500 TL gönderebilir misin? Döndüğümde iade ederim. İşte hesap no: TR12 3456..."',
      question: 'Bu mesaj gerçek mi?',
      options: ['Arkadaşım olduğu için gönderirim', 'Hesap numarasını kaydederim', 'Arkadaşımı başka yoldan arayarak doğrularım', 'Diğer arkadaşlara sorarım'],
      correctIndex: 2,
      explanation: '⚠️ Hesap çalınmış olabilir! Önce arkadaşınızı telefon veya farklı platformdan arayın. Para göndermeden ÖNCE her zaman doğrulayın.',
      redFlags: ['Acil para isteği', 'Hesap numarası verme', 'Yurt dışı/kayıp hikayesi', 'Sosyal baskı'],
    ),
    _Scenario(
      type: 'WEB SİTESİ',
      title: 'Sahte Banka Sayfası',
      content: 'Tarayıcınızda açılan sayfa:\n\n🔒 https://isbank-giris.net\n\nT. İş Bankası görünümlü giriş sayfası. Kullanıcı adı ve şifrenizi girin.',
      question: 'Bu sayfa güvenli mi?',
      options: ['HTTPS var, güvenli', 'Banka gibi görünüyor, giriş yapabilirim', 'Sahte! Alan adı yanlış', 'Tarayıcı izin verdi, giriş yaparım'],
      correctIndex: 2,
      explanation: '🚫 SAHTE SİTE! İş Bankası\'nın resmi adresi "isbank.com.tr"dir. HTTPS olması sitenin güvenli olduğunu garanti etmez, sadece şifreli bağlantı olduğunu gösterir.',
      redFlags: ['"isbank.com.tr" değil', 'HTTPS ≠ güvenli site', '.net uzantısı', 'URL\'yi dikkatli okuyun'],
    ),
  ];

  void _answer(int idx) {
    if (_answered) return;
    final correct = idx == _scenarios[_current].correctIndex;
    setState(() { _selected = idx; _answered = true; if (correct) _score += 100; });
    HapticFeedback.lightImpact();
  }

  void _next() {
    if (_current >= _scenarios.length - 1) {
      widget.onComplete((_score / 20).round(), _score);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ResultDialog(score: _score, total: _scenarios.length * 100, onClose: () => Navigator.of(context)..pop()..pop()),
      );
      return;
    }
    setState(() { _current++; _answered = false; _selected = null; });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final scenario = _scenarios[_current];
    final typeColors = {'E-POSTA': Colors.blue, 'SMS': Colors.green, 'TELEFON': Colors.orange, 'SOSYAL MEDYA': Colors.purple, 'WEB SİTESİ': Colors.red};
    final typeColor = typeColors[scenario.type] ?? primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOSYAL MÜHENDİSLİK'),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text('$_score PTS', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w900))))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress
            Row(children: List.generate(_scenarios.length, (i) => Expanded(child: Container(
              height: 4, margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: i < _current ? primary : i == _current ? primary.withOpacity(0.6) : Colors.white12),
            )))).animate().fadeIn(),

            const SizedBox(height: 16),

            // Type badge
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: typeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: typeColor.withOpacity(0.5))), child: Text(scenario.type, style: GoogleFonts.orbitron(color: typeColor, fontSize: 11, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Text(scenario.title, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ]).animate(key: ValueKey(_current)).fadeIn(),

            const SizedBox(height: 12),

            // Content bubble
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1821),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Text(scenario.content, style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 12, height: 1.6)),
            ).animate(key: ValueKey('c$_current')).fadeIn(),

            const SizedBox(height: 20),

            Text(scenario.question, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, height: 1.4), textAlign: TextAlign.center),
            const SizedBox(height: 12),

            // Options
            ...scenario.options.asMap().entries.map((entry) {
              final i = entry.key;
              final correct = i == scenario.correctIndex;
              final selected = i == _selected;
              Color border = primary.withOpacity(0.25);
              Color bg = Theme.of(context).colorScheme.surface;
              if (_answered) {
                if (correct) { border = Colors.green; bg = Colors.green.withOpacity(0.15); }
                else if (selected) { border = Colors.red; bg = Colors.red.withOpacity(0.15); }
                else { border = Colors.white12; }
              }
              return GestureDetector(
                onTap: () => _answer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 1.5)),
                  child: Row(children: [
                    Expanded(child: Text(entry.value, style: GoogleFonts.jetBrainsMono(color: _answered && !correct && !selected ? Colors.white30 : Colors.white70, fontSize: 12))),
                    if (_answered && correct) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    if (_answered && selected && !correct) const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ]),
                ),
              ).animate(delay: Duration(milliseconds: i * 80)).fadeIn();
            }),

            // Result
            if (_answered) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_selected == scenario.correctIndex ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (_selected == scenario.correctIndex ? Colors.green : Colors.red).withOpacity(0.4)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(scenario.explanation, style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 12, height: 1.5)),
                  const SizedBox(height: 10),
                  Text('🚩 UYARI İŞARETLERİ:', style: GoogleFonts.orbitron(color: Colors.orange, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  ...scenario.redFlags.map((f) => Padding(padding: const EdgeInsets.only(bottom: 3), child: Row(children: [const Text('• ', style: TextStyle(color: Colors.orange)), Expanded(child: Text(f, style: GoogleFonts.jetBrainsMono(color: Colors.orange.withOpacity(0.7), fontSize: 11)))]))),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: _next,
                    child: Text(_current >= _scenarios.length - 1 ? 'TAMAMLA' : 'SONRAKI →', style: GoogleFonts.orbitron(fontWeight: FontWeight.w900)),
                  )),
                ]),
              ).animate().fadeIn(),
            ],
          ],
        ),
      ),
    );
  }
}

class _Scenario { final String type, title, content, question, explanation; final List<String> options, redFlags; final int correctIndex; _Scenario({required this.type, required this.title, required this.content, required this.question, required this.options, required this.correctIndex, required this.explanation, required this.redFlags}); }

class _ResultDialog extends StatelessWidget {
  final int score, total; final VoidCallback onClose;
  const _ResultDialog({required this.score, required this.total, required this.onClose});
  @override Widget build(BuildContext context) => Dialog(
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(score >= total * 0.7 ? '🛡️' : '⚠️', style: const TextStyle(fontSize: 56)).animate().scale(curve: Curves.elasticOut),
      const SizedBox(height: 12),
      Text('TEST TAMAMLANDI', style: GoogleFonts.orbitron(color: Theme.of(context).colorScheme.primary, fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w900)),
      const SizedBox(height: 16),
      Text('$score', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 48, fontWeight: FontWeight.w900)),
      Text('/ $total puan', style: GoogleFonts.jetBrainsMono(color: Colors.white38)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: onClose, child: const Text('KAPAT')),
    ])),
  );
}
