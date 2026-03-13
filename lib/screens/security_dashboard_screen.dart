import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() =>
      _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  final _random = Random();

  final int _securityScore = 78;
  final List<_SecurityCheck> _checks = [
    _SecurityCheck(
      title: 'Şifre Yöneticisi',
      status: CheckStatus.good,
      description: 'Aktif ve çalışıyor',
      icon: Icons.lock,
    ),
    _SecurityCheck(
      title: 'Biyometrik Kimlik',
      status: CheckStatus.good,
      description: 'Parmak izi aktif',
      icon: Icons.fingerprint,
    ),
    _SecurityCheck(
      title: 'Ağ Güvenliği',
      status: CheckStatus.warning,
      description: '2 şüpheli cihaz',
      icon: Icons.wifi,
    ),
    _SecurityCheck(
      title: 'Uygulama İzinleri',
      status: CheckStatus.good,
      description: 'Tüm izinler kontrollü',
      icon: Icons.security,
    ),
    _SecurityCheck(
      title: 'Güncellemeler',
      status: CheckStatus.danger,
      description: '3 bekleyen güncelleme',
      icon: Icons.system_update,
    ),
    _SecurityCheck(
      title: 'VPN Bağlantısı',
      status: CheckStatus.warning,
      description: 'VPN bağlı değil',
      icon: Icons.vpn_lock,
    ),
  ];

  final List<_ThreatItem> _recentThreats = [
    _ThreatItem(
      type: 'Phishing Girişimi',
      time: '2 saat önce',
      blocked: true,
      severity: 'YÜKSEK',
    ),
    _ThreatItem(
      type: 'Şüpheli Ağ Etkinliği',
      time: '5 saat önce',
      blocked: true,
      severity: 'ORTA',
    ),
    _ThreatItem(
      type: 'Yetkisiz Erişim',
      time: 'Dün',
      blocked: true,
      severity: 'YÜKSEK',
    ),
    _ThreatItem(
      type: 'Zayıf Şifre Tespiti',
      time: '2 gün önce',
      blocked: false,
      severity: 'DÜŞÜK',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: _securityScore / 100)
        .animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOut,
    ));
    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (_securityScore < 50) return Colors.red;
    if (_securityScore < 75) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('GÜVENLİK PANELİ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _scoreColor.withOpacity(0.2),
                    _scoreColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _scoreColor.withOpacity(0.4), width: 2),
              ),
              child: Row(
                children: [
                  // Circular progress
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _scoreAnimation.value,
                              strokeWidth: 8,
                              backgroundColor: Colors.white10,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_scoreColor),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(_scoreAnimation.value * 100).toInt()}',
                                  style: GoogleFonts.orbitron(
                                    color: _scoreColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '/100',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white30,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GÜVENLİK SKORU',
                          style: GoogleFonts.orbitron(
                            color: Colors.white38,
                            fontSize: 10,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _securityScore >= 75 ? 'İYİ' : 'GELİŞTİRİLEBİLİR',
                          style: GoogleFonts.orbitron(
                            color: _scoreColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_checks.where((c) => c.status == CheckStatus.danger).length} kritik sorun',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${_checks.where((c) => c.status == CheckStatus.warning).length} uyarı',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.orange.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(curve: Curves.elasticOut),

            const SizedBox(height: 20),

            Text(
              'GÜVENLİK KONTROLLERİ',
              style: GoogleFonts.orbitron(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),

            ..._checks.asMap().entries.map((entry) {
              return _SecurityCheckCard(
                check: entry.value,
                index: entry.key,
              );
            }),

            const SizedBox(height: 20),

            Text(
              'SON TEHDİTLER',
              style: GoogleFonts.orbitron(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),

            ..._recentThreats.asMap().entries.map((entry) {
              return _ThreatCard(
                threat: entry.value,
                index: entry.key,
              );
            }),

            const SizedBox(height: 20),

            // Live stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: secondary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'CANLI İSTATİSTİKLER',
                        style: GoogleFonts.orbitron(
                          color: secondary,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox('247', 'Engellenen\nTehdit', Colors.red),
                      _StatBox('1,284', 'Taranan\nDosya', primary),
                      _StatBox('99.8%', 'Uptime\nOranı', secondary),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 600.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

Widget _StatBox(String value, String label, Color color) {
  return Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white38,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

enum CheckStatus { good, warning, danger }

class _SecurityCheck {
  final String title;
  final CheckStatus status;
  final String description;
  final IconData icon;

  _SecurityCheck({
    required this.title,
    required this.status,
    required this.description,
    required this.icon,
  });
}

class _SecurityCheckCard extends StatelessWidget {
  final _SecurityCheck check;
  final int index;

  const _SecurityCheckCard({required this.check, required this.index});

  Color get _color {
    switch (check.status) {
      case CheckStatus.good:
        return Colors.green;
      case CheckStatus.warning:
        return Colors.orange;
      case CheckStatus.danger:
        return Colors.red;
    }
  }

  IconData get _statusIcon {
    switch (check.status) {
      case CheckStatus.good:
        return Icons.check_circle_outline;
      case CheckStatus.warning:
        return Icons.warning_amber_outlined;
      case CheckStatus.danger:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(check.icon, color: _color.withOpacity(0.7), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    check.title,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    check.description,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(_statusIcon, color: _color, size: 22),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 200 + index * 80))
        .fadeIn()
        .slideX(begin: 0.2);
  }
}

class _ThreatItem {
  final String type;
  final String time;
  final bool blocked;
  final String severity;

  _ThreatItem({
    required this.type,
    required this.time,
    required this.blocked,
    required this.severity,
  });
}

class _ThreatCard extends StatelessWidget {
  final _ThreatItem threat;
  final int index;

  const _ThreatCard({required this.threat, required this.index});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (threat.blocked ? Colors.green : Colors.red)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                threat.blocked ? Icons.shield : Icons.warning,
                color: threat.blocked ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    threat.type,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    threat.time,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white30,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (threat.severity == 'YÜKSEK'
                            ? Colors.red
                            : threat.severity == 'ORTA'
                                ? Colors.orange
                                : Colors.green)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    threat.severity,
                    style: GoogleFonts.orbitron(
                      color: threat.severity == 'YÜKSEK'
                          ? Colors.red
                          : threat.severity == 'ORTA'
                              ? Colors.orange
                              : Colors.green,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  threat.blocked ? 'ENGELLENDİ' : 'UYARI',
                  style: GoogleFonts.orbitron(
                    color: threat.blocked
                        ? Colors.green.withOpacity(0.7)
                        : Colors.orange.withOpacity(0.7),
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 400 + index * 80))
        .fadeIn()
        .slideX(begin: 0.2);
  }
}
