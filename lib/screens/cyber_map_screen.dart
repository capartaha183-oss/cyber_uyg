import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:async';

class CyberMapScreen extends StatefulWidget {
  const CyberMapScreen({super.key});
  @override State<CyberMapScreen> createState() => _CyberMapScreenState();
}

class _CyberMapScreenState extends State<CyberMapScreen> with TickerProviderStateMixin {
  final _rand = Random();
  final List<_Attack> _attacks = [];
  final List<_Attack> _activeAttacks = [];
  Timer? _timer;
  int _totalAttacks = 0;
  int _blockedAttacks = 0;

  // World cities with approximate screen positions (normalized 0-1)
  final _cities = [
    _City('İstanbul', 0.545, 0.30), _City('Ankara', 0.555, 0.29),
    _City('Londra', 0.475, 0.22), _City('Paris', 0.49, 0.24),
    _City('Berlin', 0.515, 0.21), _City('Moskova', 0.575, 0.18),
    _City('Dubai', 0.60, 0.35), _City('Mumbai', 0.635, 0.38),
    _City('Beijing', 0.72, 0.27), _City('Tokyo', 0.77, 0.28),
    _City('New York', 0.27, 0.27), _City('Los Angeles', 0.18, 0.30),
    _City('São Paulo', 0.32, 0.58), _City('Lagos', 0.49, 0.43),
    _City('Cairo', 0.555, 0.33), _City('Singapore', 0.705, 0.45),
    _City('Sydney', 0.78, 0.65), _City('Toronto', 0.26, 0.24),
    _City('Mexico', 0.21, 0.36), _City('Seoul', 0.755, 0.27),
  ];

  final _attackTypes = ['DDoS', 'SQL Inject', 'Brute Force', 'Phishing', 'Ransomware', 'XSS', 'MITM', 'Zero-Day'];
  final _attackColors = [Colors.red, Colors.orange, Colors.yellow, const Color(0xFFFF3366), Colors.purple, Colors.cyan, Colors.green, Colors.pink];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) => _addAttack());
  }

  void _addAttack() {
    if (!mounted) return;
    final src = _cities[_rand.nextInt(_cities.length)];
    final dst = _cities[_rand.nextInt(_cities.length)];
    if (src == dst) return;

    final typeIdx = _rand.nextInt(_attackTypes.length);
    final blocked = _rand.nextBool();

    final attack = _Attack(
      source: src, destination: dst,
      type: _attackTypes[typeIdx],
      color: _attackColors[typeIdx],
      blocked: blocked,
      id: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _activeAttacks.add(attack);
      if (_attacks.length >= 6) _attacks.removeAt(0);
      _attacks.add(attack);
      _totalAttacks++;
      if (blocked) _blockedAttacks++;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _activeAttacks.remove(attack));
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF030D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF030D1A),
        title: Text('SİBER SALDIRILARI HARİTASI', style: GoogleFonts.orbitron(color: primary, fontSize: 13, letterSpacing: 2)),
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF041022),
            child: Row(
              children: [
                _StatPill('TOPLAM', _totalAttacks.toString(), Colors.white54),
                const SizedBox(width: 12),
                _StatPill('ENGELLENDİ', _blockedAttacks.toString(), primary),
                const SizedBox(width: 12),
                _StatPill('GEÇTİ', (_totalAttacks - _blockedAttacks).toString(), Colors.red),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 600.ms),
                const SizedBox(width: 6),
                Text('CANLI', style: GoogleFonts.orbitron(color: Colors.red, fontSize: 9, letterSpacing: 2)),
              ],
            ),
          ),

          // Map
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Background map (simplified world outline)
                CustomPaint(
                  painter: _WorldMapPainter(_activeAttacks, _cities, primary),
                  size: Size(size.width, size.width * 0.55),
                ),
                const SizedBox.expand(),
              ],
            ),
          ),

          // Attack log
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF041022),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(children: [
                      Text('CANLI SALDIRI GÜNLÜĞÜ', style: GoogleFonts.orbitron(color: Colors.white30, fontSize: 9, letterSpacing: 3)),
                    ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _attacks.length,
                      itemBuilder: (context, i) {
                        final attack = _attacks[_attacks.length - 1 - i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: attack.blocked ? primary : Colors.red)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: attack.color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                              child: Text(attack.type, style: GoogleFonts.jetBrainsMono(color: attack.color, fontSize: 9, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            Text('${attack.source.name}', style: GoogleFonts.jetBrainsMono(color: Colors.red.withOpacity(0.8), fontSize: 10)),
                            Text(' → ', style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 10)),
                            Text('${attack.destination.name}', style: GoogleFonts.jetBrainsMono(color: Colors.white60, fontSize: 10)),
                            const Spacer(),
                            Text(attack.blocked ? '🛡 ENGELLENDİ' : '💀 GEÇTİ', style: GoogleFonts.jetBrainsMono(color: attack.blocked ? primary : Colors.red, fontSize: 9)),
                          ]),
                        );
                      },
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

class _StatPill extends StatelessWidget {
  final String label, value; final Color color;
  const _StatPill(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
      Text(label, style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 8, letterSpacing: 1)),
    ],
  );
}

class _City { final String name; final double x, y; const _City(this.name, this.x, this.y); }
class _Attack {
  final _City source, destination; final String type; final Color color; final bool blocked; final int id;
  _Attack({required this.source, required this.destination, required this.type, required this.color, required this.blocked, required this.id});
}

class _WorldMapPainter extends CustomPainter {
  final List<_Attack> attacks;
  final List<_City> cities;
  final Color primary;
  _WorldMapPainter(this.attacks, this.cities, this.primary);

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF030D1A));

    // Grid lines
    final gridPaint = Paint()..color = primary.withOpacity(0.05)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

    // Simplified continent shapes
    _drawContinents(canvas, size);

    // Draw attack lines
    for (final attack in attacks) {
      final src = Offset(attack.source.x * size.width, attack.source.y * size.height);
      final dst = Offset(attack.destination.x * size.width, attack.destination.y * size.height);
      final progress = (DateTime.now().millisecondsSinceEpoch - attack.id) / 3000.0;
      final clampedProgress = progress.clamp(0.0, 1.0);

      // Draw arc line
      final linePaint = Paint()
        ..color = attack.color.withOpacity(0.6 - clampedProgress * 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(src.dx, src.dy);
      final ctrl = Offset((src.dx + dst.dx) / 2, (src.dy + dst.dy) / 2 - 40);
      path.quadraticBezierTo(ctrl.dx, ctrl.dy, dst.dx * clampedProgress + src.dx * (1 - clampedProgress), dst.dy * clampedProgress + src.dy * (1 - clampedProgress));
      canvas.drawPath(path, linePaint);

      // Moving dot
      final t = clampedProgress;
      final dotX = (1-t)*(1-t)*src.dx + 2*(1-t)*t*ctrl.dx + t*t*dst.dx;
      final dotY = (1-t)*(1-t)*src.dy + 2*(1-t)*t*ctrl.dy + t*t*dst.dy;
      canvas.drawCircle(Offset(dotX, dotY), 4, Paint()..color = attack.color);
      canvas.drawCircle(Offset(dotX, dotY), 7, Paint()..color = attack.color.withOpacity(0.3));
    }

    // Draw cities
    for (final city in cities) {
      final pos = Offset(city.x * size.width, city.y * size.height);
      canvas.drawCircle(pos, 3, Paint()..color = primary.withOpacity(0.8));
      canvas.drawCircle(pos, 6, Paint()..color = primary.withOpacity(0.15));
    }
  }

  void _drawContinents(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A2A1A)..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = const Color(0xFF00FF88).withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1;

    // Europe
    final europe = Path()..moveTo(size.width*0.46,size.height*0.18)..lineTo(size.width*0.58,size.height*0.18)..lineTo(size.width*0.58,size.height*0.32)..lineTo(size.width*0.46,size.height*0.32)..close();
    canvas.drawPath(europe, paint); canvas.drawPath(europe, borderPaint);

    // Asia
    final asia = Path()..moveTo(size.width*0.57,size.height*0.15)..lineTo(size.width*0.82,size.height*0.15)..lineTo(size.width*0.82,size.height*0.50)..lineTo(size.width*0.57,size.height*0.50)..close();
    canvas.drawPath(asia, paint); canvas.drawPath(asia, borderPaint);

    // North America
    final namerica = Path()..moveTo(size.width*0.10,size.height*0.15)..lineTo(size.width*0.35,size.height*0.15)..lineTo(size.width*0.30,size.height*0.45)..lineTo(size.width*0.10,size.height*0.45)..close();
    canvas.drawPath(namerica, paint); canvas.drawPath(namerica, borderPaint);

    // South America
    final samerica = Path()..moveTo(size.width*0.20,size.height*0.46)..lineTo(size.width*0.38,size.height*0.46)..lineTo(size.width*0.35,size.height*0.75)..lineTo(size.width*0.22,size.height*0.75)..close();
    canvas.drawPath(samerica, paint); canvas.drawPath(samerica, borderPaint);

    // Africa
    final africa = Path()..moveTo(size.width*0.44,size.height*0.30)..lineTo(size.width*0.58,size.height*0.30)..lineTo(size.width*0.56,size.height*0.68)..lineTo(size.width*0.46,size.height*0.68)..close();
    canvas.drawPath(africa, paint); canvas.drawPath(africa, borderPaint);

    // Australia
    final australia = Path()..moveTo(size.width*0.73,size.height*0.56)..lineTo(size.width*0.85,size.height*0.56)..lineTo(size.width*0.85,size.height*0.72)..lineTo(size.width*0.73,size.height*0.72)..close();
    canvas.drawPath(australia, paint); canvas.drawPath(australia, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter old) => true;
}
