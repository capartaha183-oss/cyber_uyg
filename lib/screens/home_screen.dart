import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'password_manager_screen.dart';
import 'hash_tool_screen.dart';
import 'network_analyzer_screen.dart';
import 'qr_scanner_screen.dart';
import 'password_generator_screen.dart';
import 'security_dashboard_screen.dart';
import 'ssl_checker_screen.dart';
import 'ip_lookup_screen.dart';
import 'totp_screen.dart';
import 'jwt_decoder_screen.dart';
import 'dns_lookup_screen.dart';
import 'breach_checker_screen.dart';
import 'terminal_screen.dart';
import 'matrix_screen.dart';
import 'morse_screen.dart';
import 'base_converter_screen.dart';
import 'encrypted_notes_screen.dart';
import 'fake_identity_screen.dart';
import 'url_scanner_screen.dart';
import 'cyber_map_screen.dart';
import 'wifi_analyzer_screen.dart';
import 'dark_web_screen.dart';
import 'app_permission_screen.dart';
import 'cyber_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    final List<_ToolCategory> categories = [
      _ToolCategory(title: 'TEMEL ARAÇLAR', tools: [
        _ToolItem(icon: Icons.lock_outline,           title: 'ŞİFRE\nYÖNETİCİSİ',  subtitle: 'Güvenli şifre saklama',    color: primary,                     route: const PasswordManagerScreen()),
        _ToolItem(icon: Icons.vpn_key_outlined,       title: 'ŞİFRE\nÜRETİCİ',     subtitle: 'Güçlü şifre oluştur',     color: const Color(0xFFAA44FF),     route: const PasswordGeneratorScreen()),
        _ToolItem(icon: Icons.note_outlined,          title: 'ŞİFRELİ\nNOTLAR',    subtitle: 'AES ile notlar',          color: const Color(0xFFFF6B35),     route: const EncryptedNotesScreen()),
        _ToolItem(icon: Icons.dashboard_outlined,     title: 'GÜVENLİK\nPANELİ',   subtitle: 'Genel durum özeti',       color: const Color(0xFFFFD700),     route: const SecurityDashboardScreen()),
      ]),
      _ToolCategory(title: 'ŞİFRELEME & HASH', tools: [
        _ToolItem(icon: Icons.tag,                    title: 'HASH &\nŞİFRELEME',   subtitle: 'MD5, SHA, Base64',        color: secondary,                   route: const HashToolScreen()),
        _ToolItem(icon: Icons.lock_open_outlined,     title: 'JWT\nDECODER',        subtitle: 'Token çözümleme',         color: const Color(0xFFE040FB),     route: const JwtDecoderScreen()),
        _ToolItem(icon: Icons.calculate_outlined,     title: 'SAYI\nSİSTEMLERİ',   subtitle: 'Binary/Hex/Oct dönüşüm',  color: const Color(0xFF40C4FF),     route: const BaseConverterScreen()),
        _ToolItem(icon: Icons.signal_cellular_alt,    title: 'MORSE\nKODU',         subtitle: 'Metin ↔ Morse',          color: const Color(0xFFFF8C00),     route: const MorseScreen()),
      ]),
      _ToolCategory(title: 'AĞ & GÜVENLİK', tools: [
        _ToolItem(icon: Icons.wifi_find,              title: 'AĞ\nANALİZÖRÜ',      subtitle: 'Ağ taraması',             color: const Color(0xFFFF6B35),     route: const NetworkAnalyzerScreen()),
        _ToolItem(icon: Icons.verified_user_outlined, title: 'SSL\nKONTROLÜ',       subtitle: 'Sertifika kontrolü',      color: const Color(0xFF00D4FF),     route: const SslCheckerScreen()),
        _ToolItem(icon: Icons.location_on_outlined,   title: 'IP\nSORGULAMA',       subtitle: 'IP konum tespiti',        color: const Color(0xFFFF8C00),     route: const IpLookupScreen()),
        _ToolItem(icon: Icons.dns_outlined,           title: 'DNS\nSORGULAMA',      subtitle: 'Domain DNS kayıtları',    color: const Color(0xFF40C4FF),     route: const DnsLookupScreen()),
      ]),
      _ToolCategory(title: 'KİMLİK & TARAMA', tools: [
        _ToolItem(icon: Icons.phonelink_lock_outlined,title: '2FA\nDOĞRULAYICI',   subtitle: 'TOTP kod üretici',        color: const Color(0xFF00FF88),     route: const TotpScreen()),
        _ToolItem(icon: Icons.policy_outlined,        title: 'SIZINTI\nKONTROLÜ',  subtitle: 'E-posta & şifre sızıntı', color: const Color(0xFFFF5252),     route: const BreachCheckerScreen()),
        _ToolItem(icon: Icons.qr_code_scanner,        title: 'QR KOD\nTARAYICI',   subtitle: 'Güvenli QR tarama',       color: const Color(0xFFFF3366),     route: const QrScannerScreen()),
      ]),
      _ToolCategory(title: 'GİZLİLİK & ANONİMLİK', tools: [
        _ToolItem(icon: Icons.person_outline,         title: 'SAHTE\nKİMLİK',       subtitle: 'Test kimliği üret',       color: const Color(0xFFFF8C00),     route: const FakeIdentityScreen()),
        _ToolItem(icon: Icons.link,                   title: 'URL\nGÜVENLİK',       subtitle: 'Link güvenlik taraması',  color: const Color(0xFFFF5252),     route: const UrlScannerScreen()),
        _ToolItem(icon: Icons.wifi,                   title: 'Wi-Fi\nANALİZİ',      subtitle: 'Kablosuz ağ güvenliği',   color: const Color(0xFF40C4FF),     route: const WifiAnalyzerScreen()),
        _ToolItem(icon: Icons.travel_explore,         title: 'DARK WEB\nİZLEME',    subtitle: 'Sızıntı takibi',          color: const Color(0xFFAA44FF),     route: const DarkWebMonitorScreen()),
        _ToolItem(icon: Icons.public,                 title: 'SİBER\nHARİTA',       subtitle: 'Canlı saldırı haritası',  color: const Color(0xFFFF3366),     route: const CyberMapScreen()),
        _ToolItem(icon: Icons.security,               title: 'UYGULAMA\nİZİNLERİ', subtitle: 'İzin risk analizi',       color: Colors.orange,               route: const AppPermissionScreen()),
      ]),
      _ToolCategory(title: 'SİBER ARENA 🎮', tools: [
        _ToolItem(icon: Icons.sports_esports, title: 'SİBER\nARENA', subtitle: 'Oyun, XP, rozetler', color: const Color(0xFFFFD700), route: const CyberGameScreen()),
ARENA', subtitle: 'Oyun, XP, rozetler', color: const Color(0xFFFFD700), route: const CyberGameScreen()),
      ]),
      _ToolCategory(title: 'HACKER ARAÇLARI', tools: [
        _ToolItem(icon: Icons.terminal,               title: 'TERMİNAL',            subtitle: 'Komut satırı',            color: const Color(0xFF00FF88),     route: const TerminalScreen()),
        _ToolItem(icon: Icons.blur_on,                title: 'MATRIX\nYAĞMURU',     subtitle: 'Matrix animasyonu',       color: const Color(0xFF00FF88),     route: const MatrixScreen()),
      ]),
    ];

    final allTools = categories.expand((c) => c.tools).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('CYBERGUARD')),
      drawer: _CyberDrawer(categories: categories),
      body: Stack(
        children: [
          CustomPaint(painter: _GridPainter(primary.withOpacity(0.03)), size: MediaQuery.of(context).size),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: [primary.withOpacity(0.15), secondary.withOpacity(0.05)]),
                      border: Border.all(color: primary.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Icon(Icons.verified_user, color: primary, size: 32),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('SİSTEM GÜVENLİ', style: GoogleFonts.orbitron(color: primary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2)),
                        Text('${allTools.length} araç aktif • AES-256', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11)),
                      ]),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withOpacity(0.5))),
                        child: Text('● CANLI', style: GoogleFonts.jetBrainsMono(color: primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                  const SizedBox(height: 20),
                  Text('TÜM ARAÇLAR (${allTools.length})', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 11, letterSpacing: 4)).animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
                      itemCount: allTools.length,
                      itemBuilder: (context, index) => _ToolCard(tool: allTools[index], index: index),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberDrawer extends StatelessWidget {
  final List<_ToolCategory> categories;
  const _CyberDrawer({required this.categories});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Drawer(
      backgroundColor: const Color(0xFF080F14),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, bottom: 24, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primary.withOpacity(0.2), secondary.withOpacity(0.05)]),
              border: Border(bottom: BorderSide(color: primary.withOpacity(0.2))),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.shield, color: primary, size: 36),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CYBER', style: GoogleFonts.orbitron(color: primary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  Text('GUARD', style: GoogleFonts.orbitron(color: secondary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4)),
                ]),
              ]),
              const SizedBox(height: 12),
              Text('by Taha Çapar', style: GoogleFonts.jetBrainsMono(color: primary.withOpacity(0.5), fontSize: 11, letterSpacing: 2)),
              Text('v2.0.0 • AES-256', style: GoogleFonts.jetBrainsMono(color: Colors.white.withOpacity(0.2), fontSize: 10)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: Icon(Icons.home_outlined, color: primary),
                  title: Text('ANA EKRAN', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12, letterSpacing: 1)),
                  onTap: () => Navigator.pop(context),
                  dense: true,
                ),
                Divider(color: primary.withOpacity(0.1), height: 1),
                ...categories.map((cat) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(cat.title, style: GoogleFonts.orbitron(color: Colors.white30, fontSize: 9, letterSpacing: 3)),
                    ),
                    ...cat.tools.map((tool) => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: tool.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Icon(tool.icon, color: tool.color, size: 18),
                      ),
                      title: Text(tool.title.replaceAll('\n', ' '), style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 12)),
                      subtitle: Text(tool.subtitle, style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 10)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => tool.route));
                      },
                      dense: true,
                    )),
                    Divider(color: primary.withOpacity(0.08), height: 1),
                  ],
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Divider(color: primary.withOpacity(0.2)),
              Text('⚡ Taha Çapar', style: GoogleFonts.orbitron(color: primary.withOpacity(0.4), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
              Text('© 2025 All rights reserved', style: GoogleFonts.jetBrainsMono(color: Colors.white.withOpacity(0.15), fontSize: 9)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ToolCategory { final String title; final List<_ToolItem> tools; _ToolCategory({required this.title, required this.tools}); }
class _ToolItem { final IconData icon; final String title, subtitle; final Color color; final Widget route; _ToolItem({required this.icon, required this.title, required this.subtitle, required this.color, required this.route}); }

class _ToolCard extends StatefulWidget {
  final _ToolItem tool; final int index;
  const _ToolCard({required this.tool, required this.index});
  @override State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); Navigator.push(context, MaterialPageRoute(builder: (_) => widget.tool.route)); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: widget.tool.color.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: widget.tool.color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: widget.tool.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(widget.tool.icon, color: widget.tool.color, size: 28)),
            const Spacer(),
            Text(widget.tool.title, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, height: 1.3)),
            const SizedBox(height: 4),
            Text(widget.tool.subtitle, style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 10)),
          ]),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 300 + widget.index * 60)).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
  }
}

class _GridPainter extends CustomPainter {
  final Color color; _GridPainter(this.color);
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    const s = 40.0;
    for (double x = 0; x < size.width; x += s) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += s) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}
