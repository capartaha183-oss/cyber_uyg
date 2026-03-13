import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class AppPermissionScreen extends StatefulWidget {
  const AppPermissionScreen({super.key});
  @override State<AppPermissionScreen> createState() => _AppPermissionScreenState();
}

class _AppPermissionScreenState extends State<AppPermissionScreen> {
  final _rand = Random();
  List<_AppInfo> _apps = [];
  bool _loading = false;
  String _filter = 'Tümü';
  int _riskFilter = 0;

  final _appNames = ['WhatsApp','Instagram','TikTok','YouTube','Twitter','Snapchat','Facebook','Telegram','Spotify','Netflix','Uber','Google Maps','Chrome','Gmail','Zoom','Discord','LinkedIn','Pinterest','Reddit','Shazam','VPN Master','Flashlight','Battery Saver','Phone Cleaner','Free Games','Unknown App 1','Unknown App 2'];
  final _permissions = ['Kamera','Mikrofon','Konum','Rehber','SMS','Telefon','Depolama','Bluetooth','Biyometrik','Ağ Erişimi','Bildirimler','Takvim','Sağlık','NFC','Ekran Kaydı'];

  void _scan() {
    setState(() { _loading = true; _apps = []; });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final apps = _appNames.map((name) {
        final permCount = 1 + _rand.nextInt(8);
        final perms = List<String>.from(_permissions)..shuffle(_rand);
        final appPerms = perms.take(permCount).toList();
        return _AppInfo(name: name, permissions: appPerms, version: '${1 + _rand.nextInt(10)}.${_rand.nextInt(10)}.${_rand.nextInt(10)}', isSystemApp: _rand.nextInt(5) == 0);
      }).toList();
      apps.sort((a, b) => b.riskScore.compareTo(a.riskScore));
      setState(() { _apps = apps; _loading = false; });
    });
  }

  List<_AppInfo> get _filteredApps {
    var list = _apps;
    if (_riskFilter == 1) list = list.where((a) => a.riskScore >= 60).toList();
    if (_riskFilter == 2) list = list.where((a) => a.riskScore >= 80).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('UYGULAMA İZİN TARAYICI')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withOpacity(0.3))),
            child: Column(children: [
              Row(children: [
                Icon(Icons.apps, color: primary, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('İZİN ANALİZİ', style: GoogleFonts.orbitron(color: primary, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  Text('Yüklü uygulamaların izinleri', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11)),
                ])),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _scan,
                  icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.search),
                  label: Text(_loading ? 'TARANIYOR' : 'TARA'),
                ),
              ]),
              if (_apps.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  _MiniStat('TOPLAM', _apps.length.toString(), primary),
                  _MiniStat('RİSKLİ', _apps.where((a) => a.riskScore >= 60).length.toString(), Colors.orange),
                  _MiniStat('TEHLİKELİ', _apps.where((a) => a.riskScore >= 80).length.toString(), Colors.red),
                ]),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _FilterChip('Tümü', _riskFilter == 0, primary, () => setState(() => _riskFilter = 0)),
                    const SizedBox(width: 8),
                    _FilterChip('Riskli (60+)', _riskFilter == 1, Colors.orange, () => setState(() => _riskFilter = 1)),
                    const SizedBox(width: 8),
                    _FilterChip('Tehlikeli (80+)', _riskFilter == 2, Colors.red, () => setState(() => _riskFilter = 2)),
                  ]),
                ),
              ],
            ]),
          ).animate().fadeIn(),

          Expanded(
            child: _apps.isEmpty && !_loading
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.apps, size: 64, color: primary.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('Tara butonuna basın', style: GoogleFonts.jetBrainsMono(color: Colors.white30)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, i) {
                      final app = _filteredApps[i];
                      Color riskColor = app.riskScore >= 80 ? Colors.red : app.riskScore >= 60 ? Colors.orange : Colors.green;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: riskColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text(app.name[0], style: GoogleFonts.orbitron(color: riskColor, fontSize: 16, fontWeight: FontWeight.w900))),
                          ),
                          title: Text(app.name, style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          subtitle: Text('${app.permissions.length} izin • v${app.version}', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 10)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: riskColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: riskColor.withOpacity(0.4))),
                            child: Text('${app.riskScore}', style: GoogleFonts.orbitron(color: riskColor, fontSize: 13, fontWeight: FontWeight.w900)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Wrap(
                                spacing: 6, runSpacing: 6,
                                children: app.permissions.map((p) {
                                  final isDangerous = ['Kamera','Mikrofon','Konum','SMS','Rehber','Biyometrik','Ekran Kaydı'].contains(p);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDangerous ? Colors.red.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isDangerous ? Colors.red.withOpacity(0.4) : Colors.white12),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      if (isDangerous) ...[Icon(Icons.warning_amber, color: Colors.red, size: 10), const SizedBox(width: 4)],
                                      Text(p, style: GoogleFonts.jetBrainsMono(color: isDangerous ? Colors.red : Colors.white54, fontSize: 10)),
                                    ]),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _FilterChip(String label, bool selected, Color color, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: selected ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: selected ? color : Colors.white24),
    ),
    child: Text(label, style: GoogleFonts.jetBrainsMono(color: selected ? color : Colors.white54, fontSize: 11)),
  ),
);

class _MiniStat extends StatelessWidget {
  final String label, value; final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
    Text(label, style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 9)),
  ]));
}

class _AppInfo {
  final String name, version; final List<String> permissions; final bool isSystemApp;
  _AppInfo({required this.name, required this.permissions, required this.version, required this.isSystemApp});
  int get riskScore {
    final dangerous = ['Kamera','Mikrofon','Konum','SMS','Rehber','Biyometrik','Ekran Kaydı'];
    int score = permissions.where((p) => dangerous.contains(p)).length * 15;
    score += permissions.length * 3;
    return score.clamp(0, 100);
  }
}
