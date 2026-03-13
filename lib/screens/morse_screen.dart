import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MorseScreen extends StatefulWidget {
  const MorseScreen({super.key});
  @override State<MorseScreen> createState() => _MorseScreenState();
}

class _MorseScreenState extends State<MorseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textCtrl = TextEditingController();
  final TextEditingController _morseCtrl = TextEditingController();
  String _textToMorseResult = '';
  String _morseToTextResult = '';

  static const Map<String, String> _morseMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
    '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
    '8': '---..', '9': '----.', '.': '.-.-.-', ',': '--..--', '?': '..--..',
    '!': '-.-.--', ' ': '/',
  };

  void _textToMorse(String text) {
    final result = text.toUpperCase().split('').map((c) => _morseMap[c] ?? '?').join(' ');
    setState(() => _textToMorseResult = result);
  }

  void _morseToText(String morse) {
    final reversedMap = {for (final e in _morseMap.entries) e.value: e.key};
    final words = morse.split(' / ');
    final decoded = words.map((word) {
      return word.split(' ').map((code) => reversedMap[code] ?? '?').join();
    }).join(' ');
    setState(() => _morseToTextResult = decoded);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); _textCtrl.dispose(); _morseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MORSE KODU'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelStyle: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 1),
          tabs: const [Tab(text: 'METİN → MORSE'), Tab(text: 'MORSE → METİN')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Text to Morse
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(
                controller: _textCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Metin girin', prefixIcon: Icon(Icons.text_fields, color: primary)),
                onChanged: _textToMorse,
              ),
              const SizedBox(height: 16),
              if (_textToMorseResult.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('MORSE KODU', style: GoogleFonts.orbitron(color: primary, fontSize: 10, letterSpacing: 3)),
                      const Spacer(),
                      IconButton(icon: Icon(Icons.copy, color: primary, size: 18), onPressed: () => Clipboard.setData(ClipboardData(text: _textToMorseResult)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ]),
                    const SizedBox(height: 12),
                    SelectableText(
                      _textToMorseResult,
                      style: GoogleFonts.jetBrainsMono(color: primary, fontSize: 16, letterSpacing: 3, height: 1.8),
                    ),
                  ]),
                ).animate().fadeIn(),

              // Morse reference table
              const SizedBox(height: 20),
              Text('REFERANS TABLOSU', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10, letterSpacing: 3)),
              const SizedBox(height: 8),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withOpacity(0.15)),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 2.5, crossAxisSpacing: 4, mainAxisSpacing: 4),
                  itemCount: _morseMap.entries.where((e) => e.key != ' ').length,
                  itemBuilder: (context, i) {
                    final entry = _morseMap.entries.where((e) => e.key != ' ').elementAt(i);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: primary.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                      child: Row(children: [
                        Text(entry.key, style: GoogleFonts.orbitron(color: primary, fontSize: 10, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(entry.value, style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 9), overflow: TextOverflow.ellipsis)),
                      ]),
                    );
                  },
                ),
              ),
            ]),
          ),

          // Morse to Text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(
                controller: _morseCtrl,
                maxLines: 3,
                style: GoogleFonts.jetBrainsMono(color: secondary, fontSize: 14, letterSpacing: 2),
                decoration: InputDecoration(
                  labelText: 'Morse kodu girin',
                  hintText: '.... . .-.. .-.. ---',
                  prefixIcon: Icon(Icons.code, color: secondary),
                ),
                onChanged: _morseToText,
              ),
              const SizedBox(height: 8),
              Text('Kelimeler arası: /    Harfler arası: boşluk', style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 10)),
              const SizedBox(height: 16),
              if (_morseToTextResult.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: secondary.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ÇÖZÜLEN METİN', style: GoogleFonts.orbitron(color: secondary, fontSize: 10, letterSpacing: 3)),
                    const SizedBox(height: 12),
                    SelectableText(
                      _morseToTextResult,
                      style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 4),
                    ),
                  ]),
                ).animate().fadeIn(),
            ]),
          ),
        ],
      ),
    );
  }
}
