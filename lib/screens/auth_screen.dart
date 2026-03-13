import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticating = false;
  bool _showPinInput = false;
  bool _biometricAvailable = false;
  String _statusMessage = 'Parmak izinizi kullanın';
  bool _isError = false;
  late AnimationController _fingerController;

  // PIN buradan değiştirilir
  static const String _correctPin = '0000';

  @override
  void initState() {
    super.initState();
    _fingerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _checkBiometrics();
  }

  @override
  void dispose() {
    _fingerController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isAvailable = await _localAuth.isDeviceSupported();
      setState(() {
        _biometricAvailable = canCheck && isAvailable;
        if (!_biometricAvailable) { _showPinInput = true; _statusMessage = 'PIN ile giriş yapın'; }
      });
      if (_biometricAvailable) { await Future.delayed(const Duration(milliseconds: 500)); _authenticate(); }
    } catch (e) {
      setState(() { _showPinInput = true; _statusMessage = 'PIN ile giriş yapın'; });
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() { _isAuthenticating = true; _isError = false; _statusMessage = 'Parmak izinizi tarayın...'; });
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'CyberGuard\'a erişmek için kimliğinizi doğrulayın',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      if (authenticated && mounted) {
        setState(() { _statusMessage = 'KİMLİK DOĞRULANDI ✓'; _isError = false; });
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() { _statusMessage = 'Doğrulama başarısız.'; _isError = true; });
        HapticFeedback.vibrate();
      }
    } on PlatformException catch (e) {
      setState(() { _statusMessage = 'Hata: ${e.message}'; _isError = true; _showPinInput = true; });
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  void _verifyPin() {
    if (_pinController.text == _correctPin) {
      HapticFeedback.lightImpact();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() { _isError = true; _statusMessage = 'Yanlış PIN!'; });
      HapticFeedback.vibrate();
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final error = Theme.of(context).colorScheme.error;

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(painter: _GridPainter(primary.withOpacity(0.04)), size: MediaQuery.of(context).size),
          // Köşe dekorasyonları
          Positioned(top: -60, left: -60, child: _CornerGlow(primary)),
          Positioned(bottom: -60, right: -60, child: _CornerGlow(secondary)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Shield logo
                  AnimatedBuilder(
                    animation: _fingerController,
                    builder: (context, child) => Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: primary.withOpacity(0.3 + _fingerController.value * 0.4), blurRadius: 40 + _fingerController.value * 20, spreadRadius: 5 + _fingerController.value * 10)],
                      ),
                      child: child,
                    ),
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primary, width: 2), color: primary.withOpacity(0.1)),
                      child: Icon(Icons.shield_outlined, color: primary, size: 50),
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).fadeIn(duration: 500.ms),

                  const SizedBox(height: 28),

                  Text('CYBER', style: GoogleFonts.orbitron(color: primary, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 8))
                      .animate(delay: 300.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                  Text('GUARD', style: GoogleFonts.orbitron(color: secondary, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 8))
                      .animate(delay: 500.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),
                  Text('by Taha Çapar', style: GoogleFonts.jetBrainsMono(color: primary.withOpacity(0.5), fontSize: 12, letterSpacing: 3))
                      .animate(delay: 700.ms).fadeIn(),

                  const SizedBox(height: 40),

                  // Fingerprint
                  if (_biometricAvailable)
                    GestureDetector(
                      onTap: _authenticate,
                      child: AnimatedBuilder(
                        animation: _fingerController,
                        builder: (context, child) => Container(
                          width: 110, height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _isError ? error : primary.withOpacity(0.4 + _fingerController.value * 0.6), width: 2),
                            boxShadow: [BoxShadow(color: (_isError ? error : primary).withOpacity(_fingerController.value * 0.3), blurRadius: 30, spreadRadius: 5)],
                            color: (_isError ? error : primary).withOpacity(0.05),
                          ),
                          child: Icon(Icons.fingerprint, size: 56, color: _isError ? error : primary),
                        ),
                      ),
                    ).animate(delay: 400.ms).scale(curve: Curves.elasticOut),

                  const SizedBox(height: 20),

                  Text(_statusMessage, style: GoogleFonts.jetBrainsMono(color: _isError ? error : Colors.white54, fontSize: 12, letterSpacing: 1), textAlign: TextAlign.center),

                  const SizedBox(height: 28),

                  // PIN Input
                  if (_showPinInput)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary.withOpacity(0.3)),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text('GİZLİ KOD', style: GoogleFonts.orbitron(color: secondary, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(color: primary, fontSize: 28, letterSpacing: 10),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '• • • •',
                              hintStyle: GoogleFonts.orbitron(color: primary.withOpacity(0.3), fontSize: 28, letterSpacing: 10),
                            ),
                            onSubmitted: (_) => _verifyPin(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(onPressed: _verifyPin, child: Text('GİRİŞ YAP', style: GoogleFonts.orbitron(letterSpacing: 2))),
                          ),
                        ],
                      ),
                    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),

                  if (_biometricAvailable && !_showPinInput)
                    TextButton(
                      onPressed: () => setState(() => _showPinInput = !_showPinInput),
                      child: Text('PIN ile giriş', style: GoogleFonts.jetBrainsMono(color: secondary.withOpacity(0.7), fontSize: 12)),
                    ),

                  const Spacer(flex: 3),

                  // İMZA
                  Column(
                    children: [
                      Container(width: 40, height: 1, color: primary.withOpacity(0.3)),
                      const SizedBox(height: 10),
                      Text('⚡ developed by', style: GoogleFonts.jetBrainsMono(color: Colors.white.withOpacity(0.15), fontSize: 9, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('TAHA ÇAPAR', style: GoogleFonts.orbitron(color: primary.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 4)),
                      const SizedBox(height: 4),
                      Text('v2.0.0 • AES-256 • 2025', style: GoogleFonts.jetBrainsMono(color: Colors.white.withOpacity(0.15), fontSize: 9, letterSpacing: 2)),
                      Container(width: 40, height: 1, color: primary.withOpacity(0.3)),
                    ],
                  ).animate(delay: 1200.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerGlow extends StatelessWidget {
  final Color color;
  const _CornerGlow(this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withOpacity(0.15), Colors.transparent]),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += spacing) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
