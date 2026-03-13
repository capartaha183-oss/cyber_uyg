import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // Background grid
          CustomPaint(
            painter: GridPainter(primary.withOpacity(0.05)),
            size: MediaQuery.of(context).size,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shield logo
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(
                              0.3 + _pulseController.value * 0.4,
                            ),
                            blurRadius: 40 + _pulseController.value * 20,
                            spreadRadius: 5 + _pulseController.value * 10,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primary, width: 2),
                      color: primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: primary,
                      size: 60,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 32),

                Text(
                  'CYBER',
                  style: GoogleFonts.orbitron(
                    color: primary,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                Text(
                  'GUARD',
                  style: GoogleFonts.orbitron(
                    color: secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                Text(
                  'güvenliğiniz bizim önceliğimiz',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white30,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ).animate(delay: 900.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 60),

                // Loading bar
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      backgroundColor: primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                      minHeight: 2,
                    ),
                  ),
                ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 12),

                Text(
                  'SİSTEM BAŞLATILIYOR...',
                  style: GoogleFonts.jetBrainsMono(
                    color: primary.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 3,
                  ),
                ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
