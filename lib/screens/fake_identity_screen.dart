import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class FakeIdentityScreen extends StatefulWidget {
  const FakeIdentityScreen({super.key});
  @override State<FakeIdentityScreen> createState() => _FakeIdentityScreenState();
}

class _FakeIdentityScreenState extends State<FakeIdentityScreen> {
  final _rand = Random();
  Map<String, String> _identity = {};
  String _selectedGender = 'Erkek';
  String _selectedNationality = 'Türk';

  final _maleNames = ['Ahmet','Mehmet','Ali','Mustafa','Hasan','Hüseyin','İbrahim','Yusuf','Emre','Burak','Kaan','Enes','Berk','Çağan','Taha'];
  final _femaleNames = ['Ayşe','Fatma','Zeynep','Elif','Emine','Hatice','Merve','Selin','Büşra','Ebru','Derya','Ceren','İrem','Buse','Nisa'];
  final _surnames = ['Yılmaz','Kaya','Demir','Çelik','Şahin','Yıldız','Yıldırım','Öztürk','Aydın','Özdemir','Arslan','Doğan','Kılıç','Çetin','Koç','Kurt','Acar','Şimşek','Polat','Çapar'];
  final _cities = ['İstanbul','Ankara','İzmir','Bursa','Antalya','Adana','Konya','Gaziantep','Mersin','Kayseri','Eskişehir','Trabzon','Samsun','Diyarbakır','Malatya'];
  final _streets = ['Atatürk Cad.','Cumhuriyet Sok.','İnönü Bulv.','Bağlar Mah.','Gül Sok.','Çiçek Apt.','Mimar Sinan Cad.','Karanfil Sok.'];
  final _domains = ['gmail.com','yahoo.com','hotmail.com','outlook.com','icloud.com'];
  final _bloodTypes = ['A+','A-','B+','B-','AB+','AB-','0+','0-'];
  final _jobs = ['Yazılım Mühendisi','Doktor','Öğretmen','Muhasebeci','Mimar','Avukat','Grafik Tasarımcı','Eczacı','Hemşire','Elektrikçi','Çevre Mühendisi','Biyolog'];

  @override
  void initState() { super.initState(); _generate(); }

  void _generate() {
    final isMale = _selectedGender == 'Erkek';
    final firstName = isMale ? _maleNames[_rand.nextInt(_maleNames.length)] : _femaleNames[_rand.nextInt(_femaleNames.length)];
    final lastName = _surnames[_rand.nextInt(_surnames.length)];
    final birthYear = 1970 + _rand.nextInt(35);
    final birthMonth = 1 + _rand.nextInt(12);
    final birthDay = 1 + _rand.nextInt(28);
    final city = _cities[_rand.nextInt(_cities.length)];
    final street = _streets[_rand.nextInt(_streets.length)];
    final domain = _domains[_rand.nextInt(_domains.length)];
    final emailName = '${firstName.toLowerCase()}${lastName.toLowerCase()}${_rand.nextInt(999)}';
    final phone = '05${_rand.nextInt(9)}${_rand.nextInt(9)} ${100 + _rand.nextInt(900)} ${10 + _rand.nextInt(90)} ${10 + _rand.nextInt(90)}';
    final tc = List.generate(11, (_) => _rand.nextInt(10)).join();
    final iban = 'TR${_rand.nextInt(99).toString().padLeft(2,'0')} 0001 ${List.generate(4, (_) => _rand.nextInt(10000).toString().padLeft(4,'0')).join(' ')}';

    setState(() {
      _identity = {
        'Ad Soyad': '$firstName $lastName',
        'Cinsiyet': isMale ? 'Erkek' : 'Kadın',
        'Doğum Tarihi': '${birthDay.toString().padLeft(2,'0')}.${birthMonth.toString().padLeft(2,'0')}.$birthYear',
        'Yaş': '${DateTime.now().year - birthYear}',
        'TC Kimlik No': tc,
        'Telefon': phone,
        'E-posta': '$emailName@$domain',
        'Şehir': city,
        'Adres': '$street No:${1 + _rand.nextInt(200)}, $city',
        'Kan Grubu': _bloodTypes[_rand.nextInt(_bloodTypes.length)],
        'Meslek': _jobs[_rand.nextInt(_jobs.length)],
        'IBAN': iban,
        'Tarayıcı UA': 'Mozilla/5.0 (${isMale ? "Windows NT 10.0" : "iPhone; CPU iPhone OS 16_0"}) AppleWebKit/537.36',
      };
    });
  }

  void _copyAll() {
    final text = _identity.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Tüm kimlik kopyalandı', style: GoogleFonts.jetBrainsMono()),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAHTE KİMLİK ÜRETİCİ'),
        actions: [
          IconButton(icon: Icon(Icons.copy_all, color: primary), onPressed: _copyAll),
        ],
      ),
      body: Column(
        children: [
          // Controls
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
                // Gender
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CİNSİYET', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 9, letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Row(children: ['Erkek','Kadın'].map((g) => GestureDetector(
                      onTap: () { setState(() => _selectedGender = g); _generate(); },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedGender == g ? primary.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _selectedGender == g ? primary : Colors.white24),
                        ),
                        child: Text(g, style: GoogleFonts.jetBrainsMono(color: _selectedGender == g ? primary : Colors.white54, fontSize: 12)),
                      ),
                    )).toList()),
                  ]),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('YENİ'),
                ),
              ],
            ),
          ).animate().fadeIn(),

          // Identity cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Avatar card
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary.withOpacity(0.15), secondary.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withOpacity(0.2), border: Border.all(color: primary, width: 2)),
                        child: Center(
                          child: Text(
                            (_identity['Ad Soyad'] ?? 'XX').split(' ').map((n) => n[0]).take(2).join(),
                            style: GoogleFonts.orbitron(color: primary, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_identity['Ad Soyad'] ?? '', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(_identity['Meslek'] ?? '', style: GoogleFonts.jetBrainsMono(color: secondary, fontSize: 12)),
                          Text('${_identity['Şehir'] ?? ''} • ${_identity['Yaş'] ?? ''} yaş', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11)),
                        ]),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(curve: Curves.elasticOut),

                // Info rows
                ..._identity.entries.where((e) => e.key != 'Ad Soyad' && e.key != 'Meslek' && e.key != 'Şehir' && e.key != 'Yaş').toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        SizedBox(width: 110, child: Text(e.key, style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11))),
                        Expanded(child: Text(e.value, style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 12))),
                        IconButton(
                          icon: Icon(Icons.copy, color: primary.withOpacity(0.5), size: 16),
                          onPressed: () => Clipboard.setData(ClipboardData(text: e.value)),
                          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        ),
                      ]),
                    ),
                  ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideX(begin: 0.1);
                }),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Sadece test amaçlıdır. Gerçek kimlik bilgisi değildir.', style: GoogleFonts.jetBrainsMono(color: Colors.orange.withOpacity(0.7), fontSize: 10))),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
