import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';
import 'ctf_screen.dart';
import 'password_crack_screen.dart';
import 'social_engineering_screen.dart';
import 'hacker_sim_screen.dart';
import 'security_quiz_screen.dart';

class CyberGameScreen extends StatefulWidget {
  const CyberGameScreen({super.key});
  @override State<CyberGameScreen> createState() => _CyberGameScreenState();
}

class _CyberGameScreenState extends State<CyberGameScreen> with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  int _xp = 0;
  int _level = 1;
  List<String> _badges = [];
  Map<String, int> _scores = {};

  final _games = [
    _GameItem(
      id: 'quiz',
      title: 'SİBER GÜVENLİK\nQUIZ',
      description: 'Bilgini test et',
      icon: Icons.quiz,
      color: const Color(0xFF00FF88),
      xpReward: 50,
      difficulty: 'KOLAY',
      route: (onComplete) => SecurityQuizScreen(onComplete: onComplete),
    ),
    _GameItem(
      id: 'crack',
      title: 'ŞİFRE KIRMA\nSİMÜLATÖRÜ',
      description: 'Hash kır, ödül kazan',
      icon: Icons.lock_open,
      color: const Color(0xFFFF3366),
      xpReward: 100,
      difficulty: 'ORTA',
      route: (onComplete) => PasswordCrackScreen(onComplete: onComplete),
    ),
    _GameItem(
      id: 'social',
      title: 'SOSYAL\nMÜHENDİSLİK',
      description: 'Phishing tespiti',
      icon: Icons.psychology,
      color: const Color(0xFFFF8C00),
      xpReward: 75,
      difficulty: 'ORTA',
      route: (onComplete) => SocialEngineeringScreen(onComplete: onComplete),
    ),
    _GameItem(
      id: 'ctf',
      title: 'CTF\nBULMACALARI',
      description: 'Bayrak yakala',
      icon: Icons.flag,
      color: const Color(0xFFAA44FF),
      xpReward: 150,
      difficulty: 'ZOR',
      route: (onComplete) => CtfScreen(onComplete: onComplete),
    ),
    _GameItem(
      id: 'hacker',
      title: 'HACKER\nSİMÜLATÖRÜ',
      description: 'Senaryo tabanlı',
      icon: Icons.terminal,
      color: const Color(0xFF00D4FF),
      xpReward: 200,
      difficulty: 'UZMAN',
      route: (onComplete) => HackerSimScreen(onComplete: onComplete),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _loadProgress();
  }

  @override
  void dispose() { _glowCtrl.dispose(); super.dispose(); }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _xp = prefs.getInt('xp') ?? 0;
      _level = (_xp ~/ 200) + 1;
      _badges = prefs.getStringList('badges') ?? [];
      for (final g in _games) {
        _scores[g.id] = prefs.getInt('score_${g.id}') ?? 0;
      }
    });
  }

  Future<void> _addXp(int amount, String gameId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final newXp = _xp + amount;
    await prefs.setInt('xp', newXp);
    await prefs.setInt('score_$gameId', score);

    // Check badges
    final newBadges = List<String>.from(_badges);
    if (newXp >= 100 && !newBadges.contains('rookie')) newBadges.add('rookie');
    if (newXp >= 300 && !newBadges.contains('hacker')) newBadges.add('hacker');
    if (newXp >= 600 && !newBadges.contains('elite')) newBadges.add('elite');
    if (_scores.values.every((s) => s > 0) && !newBadges.contains('completionist')) newBadges.add('completionist');
    await prefs.setStringList('badges', newBadges);

    setState(() {
      _xp = newXp;
      _level = (newXp ~/ 200) + 1;
      _badges = newBadges;
      _scores[gameId] = score;
    });

    HapticFeedback.heavyImpact();
    _showXpPopup(amount);
  }

  void _showXpPopup(int amount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1821),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00FF88), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.3), blurRadius: 40, spreadRadius: 10)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('⚡', style: const TextStyle(fontSize: 48)).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
            const SizedBox(height: 16),
            Text('+$amount XP', style: GoogleFonts.orbitron(color: const Color(0xFF00FF88), fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 4))
                .animate().scale(curve: Curves.elasticOut, delay: 200.ms),
            const SizedBox(height: 8),
            Text('KAZANILDI!', style: GoogleFonts.orbitron(color: Colors.white60, fontSize: 14, letterSpacing: 4)),
          ]),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.of(context, rootNavigator: true).pop(); });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final xpInLevel = _xp % 200;
    final xpProgress = xpInLevel / 200;

    final badgeData = {
      'rookie': ('🎯', 'Rookie', '100 XP'),
      'hacker': ('💻', 'Hacker', '300 XP'),
      'elite': ('👑', 'Elite', '600 XP'),
      'completionist': ('🏆', 'Completionist', 'Tüm oyunlar'),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('SİBER ARENA')),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    primary.withOpacity(0.08 + _glowCtrl.value * 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Player card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [primary.withOpacity(0.2), const Color(0xFF00D4FF).withOpacity(0.05)],
                    ),
                    border: Border.all(color: primary.withOpacity(0.4), width: 2),
                  ),
                  child: Column(children: [
                    Row(children: [
                      // Avatar
                      AnimatedBuilder(
                        animation: _glowCtrl,
                        builder: (_, __) => Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withOpacity(0.15),
                            border: Border.all(color: primary, width: 2),
                            boxShadow: [BoxShadow(color: primary.withOpacity(0.3 + _glowCtrl.value * 0.3), blurRadius: 20, spreadRadius: 3)],
                          ),
                          child: Center(child: Text('TC', style: GoogleFonts.orbitron(color: primary, fontSize: 22, fontWeight: FontWeight.w900))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('TAHA ÇAPAR', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 2),
                        Text(_levelTitle(_level), style: GoogleFonts.jetBrainsMono(color: primary, fontSize: 12)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Text('SEVİYE', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 9, letterSpacing: 2)),
                          const SizedBox(width: 8),
                          Text('$_level', style: GoogleFonts.orbitron(color: primary, fontSize: 20, fontWeight: FontWeight.w900)),
                        ]),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('$_xp XP', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w900)),
                        Text('toplam', style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 10)),
                      ]),
                    ]),
                    const SizedBox(height: 16),
                    // XP bar
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('$xpInLevel / 200 XP', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 10)),
                        Text('Seviye ${_level + 1} için', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 10)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          backgroundColor: primary.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                          minHeight: 10,
                        ),
                      ),
                    ]),
                  ]),
                ).animate().fadeIn().scale(curve: Curves.elasticOut),

                const SizedBox(height: 16),

                // Badges
                if (_badges.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('ROZETLER', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 11, letterSpacing: 3)),
                      const SizedBox(height: 12),
                      Row(children: _badges.map((b) {
                        final data = badgeData[b];
                        if (data == null) return const SizedBox();
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                          ),
                          child: Column(children: [
                            Text(data.$1, style: const TextStyle(fontSize: 24)),
                            Text(data.$2, style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.w700)),
                          ]),
                        );
                      }).toList()),
                    ]),
                  ).animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: 16),
                ],

                // Games
                Text('OYUNLAR', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 11, letterSpacing: 4)).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 12),

                ..._games.asMap().entries.map((entry) {
                  final game = entry.value;
                  final score = _scores[game.id] ?? 0;
                  final completed = score > 0;

                  return _GameCard(
                    game: game,
                    score: score,
                    completed: completed,
                    index: entry.key,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => game.route((xp, s) => _addXp(xp, game.id, s)),
                      ));
                    },
                  );
                }),

                const SizedBox(height: 20),

                // All badges unlock hint
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.15)),
                  ),
                  child: Row(children: [
                    const Text('🏆', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tüm rozetleri topla!', style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w700)),
                      Text('Rookie(100xp) • Hacker(300xp) • Elite(600xp) • Completionist(hepsi)', style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 9)),
                    ])),
                  ]),
                ).animate(delay: 600.ms).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _levelTitle(int level) {
    if (level <= 2) return 'Script Kiddie';
    if (level <= 4) return 'Junior Hacker';
    if (level <= 6) return 'Penetration Tester';
    if (level <= 9) return 'Cyber Warrior';
    return 'Elite Hacker 👑';
  }
}

class _GameItem {
  final String id, title, description, difficulty;
  final IconData icon;
  final Color color;
  final int xpReward;
  final Widget Function(Function(int, int)) route;
  _GameItem({required this.id, required this.title, required this.description, required this.icon, required this.color, required this.xpReward, required this.difficulty, required this.route});
}

class _GameCard extends StatelessWidget {
  final _GameItem game;
  final int score, index;
  final bool completed;
  final VoidCallback onTap;
  const _GameCard({required this.game, required this.score, required this.completed, required this.index, required this.onTap});

  Color get _diffColor {
    switch (game.difficulty) {
      case 'KOLAY': return Colors.green;
      case 'ORTA': return Colors.orange;
      case 'ZOR': return Colors.red;
      default: return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: game.color.withOpacity(completed ? 0.6 : 0.3), width: completed ? 2 : 1.5),
          boxShadow: [BoxShadow(color: game.color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: game.color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(game.icon, color: game.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(game.title.replaceAll('\n', ' '), style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(game.description, style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _diffColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(game.difficulty, style: GoogleFonts.orbitron(color: _diffColor, fontSize: 8, fontWeight: FontWeight.w700))),
              const SizedBox(width: 6),
              Text('+${game.xpReward} XP', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFFD700), fontSize: 10)),
              if (completed) ...[const SizedBox(width: 6), Text('✓ $score puan', style: GoogleFonts.jetBrainsMono(color: Colors.green, fontSize: 10))],
            ]),
          ])),
          Icon(completed ? Icons.check_circle : Icons.play_circle_outline, color: completed ? Colors.green : game.color, size: 32),
        ]),
      ),
    ).animate(delay: Duration(milliseconds: 300 + index * 100)).fadeIn().slideX(begin: 0.3);
  }
}
