import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class WifiAnalyzerScreen extends StatefulWidget {
  const WifiAnalyzerScreen({super.key});
  @override State<WifiAnalyzerScreen> createState() => _WifiAnalyzerScreenState();
}

class _WifiAnalyzerScreenState extends State<WifiAnalyzerScreen> {
  final _rand = Random();
  List<_WifiNetwork> _networks = [];
  bool _scanning = false;

  final _ssids = ['EV_WIFI','Turktelekom_5G','Superonline_Fiber','TP-Link_2G','NETGEAR_Pro','AndroidAP','iPhone_Hotspot','Modem_HUAWEI','TTNET_Ev','Vodafone_Home','Ortak_Wifi','Misafir_Ag','Galaxy_S23','RedmiNote','ASUS_RT'];
  final _securities = ['WPA3','WPA2','WPA2-Enterprise','WEP','Open','WPA'];

  Future<void> _scan() async {
    setState(() { _scanning = true; _networks = []; });
    await Future.delayed(const Duration(seconds: 2));

    final count = 5 + _rand.nextInt(8);
    final nets = <_WifiNetwork>[];
    final usedSsids = <String>{};

    for (int i = 0; i < count; i++) {
      String ssid;
      do { ssid = _ssids[_rand.nextInt(_ssids.length)]; } while (usedSsids.contains(ssid));
      usedSsids.add(ssid);

      final security = _securities[_rand.nextInt(_securities.length)];
      final signal = -30 - _rand.nextInt(60);
      final channel = [1,2,3,4,5,6,7,8,9,10,11,36,40,44,48][_rand.nextInt(15)];
      final is5G = channel > 14;

      nets.add(_WifiNetwork(
        ssid: ssid,
        bssid: List.generate(6, (_) => _rand.nextInt(256).toRadixString(16).padLeft(2,'0')).join(':').toUpperCase(),
        signal: signal,
        security: security,
        channel: channel,
        is5G: is5G,
        isHidden: _rand.nextInt(10) == 0,
      ));
    }

    nets.sort((a, b) => b.signal.compareTo(a.signal));
    setState(() { _networks = nets; _scanning = false; });
  }

  int _securityScore(_WifiNetwork net) {
    if (net.security == 'WPA3') return 100;
    if (net.security == 'WPA2-Enterprise') return 95;
    if (net.security == 'WPA2') return 75;
    if (net.security == 'WPA') return 45;
    if (net.security == 'WEP') return 15;
    return 0;
  }

  Color _securityColor(_WifiNetwork net) {
    final score = _securityScore(net);
    if (score >= 75) return Colors.green;
    if (score >= 45) return Colors.orange;
    return Colors.red;
  }

  Color _signalColor(int signal) {
    if (signal > -50) return Colors.green;
    if (signal > -70) return Colors.orange;
    return Colors.red;
  }

  IconData _signalIcon(int signal) {
    if (signal > -50) return Icons.wifi;
    if (signal > -70) return Icons.wifi_2_bar;
    return Icons.wifi_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Wi-Fi ŞIFRE ANALİZİ')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Column(children: [
              Row(children: [
                Icon(Icons.wifi_find, color: primary, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('YAKIN AĞ TARAMASI', style: GoogleFonts.orbitron(color: primary, fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w700)),
                  Text('Güvenlik açıkları analiz edilir', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11)),
                ])),
                ElevatedButton.icon(
                  onPressed: _scanning ? null : _scan,
                  icon: _scanning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.radar),
                  label: Text(_scanning ? 'TARANIYOR' : 'TARA'),
                ),
              ]),
              if (_networks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  _SmallStat('BULUNAN', _networks.length.toString(), primary),
                  _SmallStat('GÜVENLİ', _networks.where((n) => _securityScore(n) >= 75).length.toString(), Colors.green),
                  _SmallStat('RİSKLİ', _networks.where((n) => _securityScore(n) < 45).length.toString(), Colors.red),
                  _SmallStat('5 GHz', _networks.where((n) => n.is5G).length.toString(), Colors.blue),
                ]),
              ],
            ]),
          ).animate().fadeIn(),

          Expanded(
            child: _networks.isEmpty && !_scanning
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.wifi_off, size: 64, color: primary.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('Tara butonuna basın', style: GoogleFonts.jetBrainsMono(color: Colors.white30)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _networks.length,
                    itemBuilder: (context, i) {
                      final net = _networks[i];
                      final secScore = _securityScore(net);
                      final secColor = _securityColor(net);
                      final sigColor = _signalColor(net.signal);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(_signalIcon(net.signal), color: sigColor, size: 24),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Text(net.ssid, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                                  if (net.isHidden) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text('GİZLİ', style: GoogleFonts.jetBrainsMono(color: Colors.orange, fontSize: 8)))],
                                  if (net.is5G) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text('5G', style: GoogleFonts.jetBrainsMono(color: Colors.blue, fontSize: 8)))],
                                ]),
                                Text(net.bssid, style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 10)),
                              ])),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text('${net.signal} dBm', style: GoogleFonts.jetBrainsMono(color: sigColor, fontSize: 11)),
                                Text('Ch ${net.channel}', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 10)),
                              ]),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: secColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: secColor.withOpacity(0.4))),
                                child: Text(net.security, style: GoogleFonts.orbitron(color: secColor, fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(value: secScore / 100, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(secColor), minHeight: 6),
                              )),
                              const SizedBox(width: 8),
                              Text('$secScore/100', style: GoogleFonts.jetBrainsMono(color: secColor, fontSize: 10)),
                            ]),
                            if (secScore < 45) ...[
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.warning_amber, color: Colors.orange, size: 14),
                                const SizedBox(width: 4),
                                Text(net.security == 'WEP' ? 'WEP şifresi saniyeler içinde kırılabilir!' : net.security == 'Open' ? 'Şifresiz ağ! Verileriniz açıkta!' : 'Zayıf güvenlik protokolü', style: GoogleFonts.jetBrainsMono(color: Colors.orange, fontSize: 10)),
                              ]),
                            ],
                          ]),
                        ),
                      ).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideX(begin: 0.2);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label, value; final Color color;
  const _SmallStat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
    Text(label, style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 9)),
  ]));
}

class _WifiNetwork {
  final String ssid, bssid, security; final int signal, channel; final bool is5G, isHidden;
  _WifiNetwork({required this.ssid, required this.bssid, required this.signal, required this.security, required this.channel, required this.is5G, required this.isHidden});
}
