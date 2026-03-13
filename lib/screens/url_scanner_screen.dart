import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class UrlScannerScreen extends StatefulWidget {
  const UrlScannerScreen({super.key});
  @override State<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends State<UrlScannerScreen> {
  final TextEditingController _urlCtrl = TextEditingController();
  bool _loading = false;
  _UrlResult? _result;
  final _rand = Random();

  final _suspiciousKeywords = ['free-money','win-prize','click-here','login-verify','account-suspended','bit.ly','tinyurl.com','goo.gl','ow.ly','phish','malware','hack','crack','keygen','warez','torrent','xxxfree','casino-bonus'];
  final _trustedDomains = ['google.com','microsoft.com','apple.com','github.com','amazon.com','twitter.com','facebook.com','instagram.com','youtube.com','wikipedia.org','stackoverflow.com','cloudflare.com'];

  Future<void> _scan() async {
    String url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) url = 'https://$url';

    setState(() { _loading = true; _result = null; });
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final uri = Uri.parse(url);
      final domain = uri.host.toLowerCase();
      final path = uri.path.toLowerCase();
      final fullUrl = url.toLowerCase();

      final issues = <_UrlIssue>[];
      int riskScore = 0;

      // HTTPS check
      if (!url.startsWith('https')) {
        issues.add(_UrlIssue('HTTP Bağlantısı', 'Şifreli değil, veriler açık taşınıyor', IssueLevel.warning));
        riskScore += 20;
      }

      // Suspicious keywords
      for (final kw in _suspiciousKeywords) {
        if (fullUrl.contains(kw)) {
          issues.add(_UrlIssue('Şüpheli Kelime', '"$kw" tespit edildi', IssueLevel.danger));
          riskScore += 30;
          break;
        }
      }

      // IP address as host
      final ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
      if (ipRegex.hasMatch(domain)) {
        issues.add(_UrlIssue('IP Adresi', 'Domain yerine IP kullanılmış, şüpheli', IssueLevel.danger));
        riskScore += 40;
      }

      // Long URL
      if (url.length > 100) {
        issues.add(_UrlIssue('Uzun URL', 'Aşırı uzun URL, gizleme amaçlı olabilir', IssueLevel.warning));
        riskScore += 10;
      }

      // Many subdomains
      final parts = domain.split('.');
      if (parts.length > 4) {
        issues.add(_UrlIssue('Çok Alt Domain', '${parts.length} alt domain seviyesi şüpheli', IssueLevel.warning));
        riskScore += 15;
      }

      // Trusted domain
      bool isTrusted = _trustedDomains.any((t) => domain.endsWith(t));
      if (isTrusted) {
        issues.add(_UrlIssue('Güvenilir Domain', 'Bilinen güvenilir domain', IssueLevel.safe));
        riskScore = (riskScore * 0.3).round();
      }

      // Special chars in path
      if (path.contains('%') && path.split('%').length > 3) {
        issues.add(_UrlIssue('URL Encoding', 'Aşırı URL encoding, gizleme olabilir', IssueLevel.warning));
        riskScore += 15;
      }

      riskScore = riskScore.clamp(0, 100);

      setState(() {
        _result = _UrlResult(
          url: url,
          domain: domain,
          protocol: uri.scheme.toUpperCase(),
          riskScore: riskScore,
          issues: issues,
          isHttps: url.startsWith('https'),
          isTrusted: isTrusted,
        );
      });
    } catch (e) {
      setState(() {
        _result = _UrlResult(
          url: url, domain: '', protocol: '', riskScore: 50,
          issues: [_UrlIssue('Geçersiz URL', 'URL parse edilemedi', IssueLevel.danger)],
          isHttps: false, isTrusted: false,
        );
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _riskColor(int score) {
    if (score < 20) return Colors.green;
    if (score < 50) return Colors.orange;
    return Colors.red;
  }

  String _riskLabel(int score) {
    if (score < 20) return 'GÜVENLİ';
    if (score < 50) return 'ORTA RİSK';
    return 'TEHLİKELİ';
  }

  @override
  void dispose() { _urlCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('URL GÜVENLİK TARAYICI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Column(children: [
                TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://ornek.com/sayfa',
                    prefixIcon: Icon(Icons.link, color: primary),
                  ),
                  onSubmitted: (_) => _scan(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _scan,
                    icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.security),
                    label: Text(_loading ? 'TARANYOR...' : 'URL TARA'),
                  ),
                ),
              ]),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            if (_result != null) ...[
              // Risk score
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_riskColor(_result!.riskScore).withOpacity(0.15), Colors.transparent]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _riskColor(_result!.riskScore).withOpacity(0.4), width: 2),
                ),
                child: Column(children: [
                  Row(children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: Stack(alignment: Alignment.center, children: [
                        CircularProgressIndicator(
                          value: _result!.riskScore / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(_riskColor(_result!.riskScore)),
                        ),
                        Text('${_result!.riskScore}', style: GoogleFonts.orbitron(color: _riskColor(_result!.riskScore), fontSize: 20, fontWeight: FontWeight.w900)),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_riskLabel(_result!.riskScore), style: GoogleFonts.orbitron(color: _riskColor(_result!.riskScore), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(_result!.domain, style: GoogleFonts.jetBrainsMono(color: Colors.white60, fontSize: 12)),
                      Row(children: [
                        _Badge(_result!.protocol, _result!.isHttps ? Colors.green : Colors.orange),
                        const SizedBox(width: 6),
                        if (_result!.isTrusted) _Badge('TRUSTED', Colors.green),
                      ]),
                    ])),
                  ]),
                ]),
              ).animate().fadeIn().scale(curve: Curves.elasticOut),

              const SizedBox(height: 12),

              // Issues
              ..._result!.issues.asMap().entries.map((entry) {
                final issue = entry.value;
                final colors = {IssueLevel.safe: Colors.green, IssueLevel.warning: Colors.orange, IssueLevel.danger: Colors.red};
                final icons = {IssueLevel.safe: Icons.check_circle_outline, IssueLevel.warning: Icons.warning_amber_outlined, IssueLevel.danger: Icons.dangerous_outlined};
                final c = colors[issue.level]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Icon(icons[issue.level]!, color: c, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(issue.title, style: GoogleFonts.orbitron(color: c, fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(issue.description, style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 11)),
                      ])),
                    ]),
                  ),
                ).animate(delay: Duration(milliseconds: entry.key * 80)).fadeIn().slideX(begin: 0.2);
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge(this.label, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
    child: Text(label, style: GoogleFonts.orbitron(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
  );
}

enum IssueLevel { safe, warning, danger }
class _UrlIssue { final String title, description; final IssueLevel level; _UrlIssue(this.title, this.description, this.level); }
class _UrlResult {
  final String url, domain, protocol; final int riskScore; final List<_UrlIssue> issues; final bool isHttps, isTrusted;
  _UrlResult({required this.url, required this.domain, required this.protocol, required this.riskScore, required this.issues, required this.isHttps, required this.isTrusted});
}
