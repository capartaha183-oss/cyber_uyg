import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});
  @override State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_MatrixColumn> _columns;
  Timer? _timer;
  final _rand = Random();
  bool _initialized = false;
  Color _rainColor = const Color(0xFF00FF88);
  double _speed = 1.0;

  final _colorOptions = [
    const Color(0xFF00FF88), // Yeşil
    const Color(0xFF00D4FF), // Siyan
    const Color(0xFFFF3366), // Kırmızı
    const Color(0xFFAA44FF), // Mor
    const Color(0xFFFFD700), // Altın
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 50))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initColumns());
  }

  void _initColumns() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final colCount = (width / 16).ceil();

    _columns = List.generate(colCount, (i) => _MatrixColumn(
      x: i * 16.0,
      screenHeight: height,
      rand: _rand,
    ));

    setState(() => _initialized = true);

    _timer = Timer.periodic(Duration(milliseconds: (50 / _speed).round()), (_) {
      if (mounted) setState(() { for (final col in _columns) col.update(); });
    });
  }

  void _updateSpeed(double s) {
    setState(() => _speed = s);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: (50 / _speed).round()), (_) {
      if (mounted) setState(() { for (final col in _columns) col.update(); });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_initialized)
            CustomPaint(
              painter: _MatrixPainter(_columns, _rainColor),
              size: Size.infinite,
            ),

          // Controls overlay
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black, Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _colorOptions.map((c) => GestureDetector(
                      onTap: () => setState(() => _rainColor = c),
                      child: Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.withOpacity(0.3),
                          border: Border.all(
                            color: _rainColor == c ? c : Colors.white24,
                            width: _rainColor == c ? 3 : 1,
                          ),
                        ),
                        child: _rainColor == c ? Icon(Icons.check, color: c, size: 16) : null,
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Speed slider
                  Row(
                    children: [
                      Icon(Icons.slow_motion_video, color: _rainColor.withOpacity(0.5), size: 16),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _rainColor,
                            thumbColor: _rainColor,
                            inactiveTrackColor: _rainColor.withOpacity(0.2),
                            overlayColor: _rainColor.withOpacity(0.1),
                          ),
                          child: Slider(value: _speed, min: 0.2, max: 3.0, onChanged: _updateSpeed),
                        ),
                      ),
                      Icon(Icons.fast_forward, color: _rainColor.withOpacity(0.5), size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: _rainColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0, right: 0,
            child: Center(
              child: Text(
                'MATRIX RAIN',
                style: GoogleFonts.orbitron(
                  color: _rainColor.withOpacity(0.8),
                  fontSize: 14,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixColumn {
  final double x;
  final double screenHeight;
  final Random rand;
  double y = 0;
  List<String> chars = [];
  double speed = 0;
  int length = 0;

  static const _charSet = 'アイウエオカキクケコサシスセソタチツテトナニヌネノABCDEFGHIJKLMNOP0123456789@#\$%&*';

  _MatrixColumn({required this.x, required this.screenHeight, required this.rand}) {
    _reset(initial: true);
  }

  void _reset({bool initial = false}) {
    speed = 2 + rand.nextDouble() * 6;
    length = 10 + rand.nextInt(20);
    y = initial ? -rand.nextDouble() * screenHeight : -length * 16.0;
    chars = List.generate(length + 5, (_) => _charSet[rand.nextInt(_charSet.length)]);
  }

  void update() {
    y += speed;
    if (rand.nextInt(8) == 0 && chars.isNotEmpty) {
      final idx = rand.nextInt(chars.length);
      chars[idx] = _charSet[rand.nextInt(_charSet.length)];
    }
    if (y > screenHeight + length * 16) _reset();
  }
}

class _MatrixPainter extends CustomPainter {
  final List<_MatrixColumn> columns;
  final Color color;
  _MatrixPainter(this.columns, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const charHeight = 16.0;

    for (final col in columns) {
      for (int i = 0; i < col.chars.length; i++) {
        final charY = col.y - i * charHeight;
        if (charY < -charHeight || charY > size.height) continue;

        final progress = i / col.chars.length;
        Color charColor;
        if (i == 0) {
          charColor = Colors.white;
        } else if (i < 3) {
          charColor = color.withOpacity(1.0 - progress * 0.3);
        } else {
          charColor = color.withOpacity(max(0, 0.8 - progress * 0.9));
        }

        final tp = TextPainter(
          text: TextSpan(
            text: col.chars[i],
            style: TextStyle(
              fontFamily: 'monospace',
              color: charColor,
              fontSize: 14,
              fontWeight: i < 2 ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(col.x, charY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter old) => true;
}
