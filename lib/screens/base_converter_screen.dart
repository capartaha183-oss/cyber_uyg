import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BaseConverterScreen extends StatefulWidget {
  const BaseConverterScreen({super.key});
  @override State<BaseConverterScreen> createState() => _BaseConverterScreenState();
}

class _BaseConverterScreenState extends State<BaseConverterScreen> {
  final _decCtrl = TextEditingController();
  final _binCtrl = TextEditingController();
  final _hexCtrl = TextEditingController();
  final _octCtrl = TextEditingController();
  bool _updating = false;

  void _fromDec(String val) {
    if (_updating) return;
    _updating = true;
    try {
      final n = int.parse(val.isEmpty ? '0' : val);
      _binCtrl.text = n.toRadixString(2);
      _hexCtrl.text = n.toRadixString(16).toUpperCase();
      _octCtrl.text = n.toRadixString(8);
    } catch (_) {}
    _updating = false;
  }

  void _fromBin(String val) {
    if (_updating) return;
    _updating = true;
    try {
      final n = int.parse(val.isEmpty ? '0' : val, radix: 2);
      _decCtrl.text = n.toString();
      _hexCtrl.text = n.toRadixString(16).toUpperCase();
      _octCtrl.text = n.toRadixString(8);
    } catch (_) {}
    _updating = false;
  }

  void _fromHex(String val) {
    if (_updating) return;
    _updating = true;
    try {
      final n = int.parse(val.isEmpty ? '0' : val, radix: 16);
      _decCtrl.text = n.toString();
      _binCtrl.text = n.toRadixString(2);
      _octCtrl.text = n.toRadixString(8);
    } catch (_) {}
    _updating = false;
  }

  void _fromOct(String val) {
    if (_updating) return;
    _updating = true;
    try {
      final n = int.parse(val.isEmpty ? '0' : val, radix: 8);
      _decCtrl.text = n.toString();
      _binCtrl.text = n.toRadixString(2);
      _hexCtrl.text = n.toRadixString(16).toUpperCase();
    } catch (_) {}
    _updating = false;
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label kopyalandı', style: GoogleFonts.jetBrainsMono()),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  void dispose() { _decCtrl.dispose(); _binCtrl.dispose(); _hexCtrl.dispose(); _octCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    final bases = [
      _BaseItem(label: 'DECIMAL', sublabel: 'Base 10', ctrl: _decCtrl, color: primary, onChanged: _fromDec, hint: '255', keyboard: TextInputType.number),
      _BaseItem(label: 'BINARY', sublabel: 'Base 2', ctrl: _binCtrl, color: secondary, onChanged: _fromBin, hint: '11111111', keyboard: TextInputType.number),
      _BaseItem(label: 'HEX', sublabel: 'Base 16', ctrl: _hexCtrl, color: const Color(0xFFFF6B35), onChanged: _fromHex, hint: 'FF', keyboard: TextInputType.text),
      _BaseItem(label: 'OCTAL', sublabel: 'Base 8', ctrl: _octCtrl, color: const Color(0xFFAA44FF), onChanged: _fromOct, hint: '377', keyboard: TextInputType.number),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('SAYI SİSTEMLERİ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...bases.asMap().entries.map((entry) {
              final b = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: b.color.withOpacity(0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: b.color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(b.label, style: GoogleFonts.orbitron(color: b.color, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    ),
                    const SizedBox(width: 8),
                    Text(b.sublabel, style: GoogleFonts.jetBrainsMono(color: Colors.white30, fontSize: 11)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.copy, color: b.color.withOpacity(0.6), size: 18),
                      onPressed: () => _copy(b.ctrl.text, b.label),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  TextField(
                    controller: b.ctrl,
                    keyboardType: b.keyboard,
                    style: GoogleFonts.jetBrainsMono(color: b.color, fontSize: 20, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: b.hint,
                      hintStyle: GoogleFonts.jetBrainsMono(color: b.color.withOpacity(0.2), fontSize: 20),
                      border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                      filled: false, isDense: true, contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: b.onChanged,
                  ),
                ]),
              ).animate(delay: Duration(milliseconds: entry.key * 100)).fadeIn().slideX(begin: 0.2);
            }),

            const SizedBox(height: 8),

            // Quick conversions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.15)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('HIZLI REFERANS', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10, letterSpacing: 3)),
                const SizedBox(height: 12),
                Table(
                  children: [
                    TableRow(children: [
                      Text('DEC', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10)),
                      Text('BIN', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10)),
                      Text('HEX', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10)),
                      Text('OCT', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10)),
                    ]),
                    ...[0,1,2,4,8,16,32,64,128,255].map((n) => TableRow(children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(n.toString(), style: GoogleFonts.jetBrainsMono(color: primary, fontSize: 11))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(n.toRadixString(2), style: GoogleFonts.jetBrainsMono(color: secondary, fontSize: 11))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(n.toRadixString(16).toUpperCase(), style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFF6B35), fontSize: 11))),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text(n.toRadixString(8), style: GoogleFonts.jetBrainsMono(color: const Color(0xFFAA44FF), fontSize: 11))),
                    ])),
                  ],
                ),
              ]),
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _BaseItem {
  final String label, sublabel, hint;
  final TextEditingController ctrl;
  final Color color;
  final ValueChanged<String> onChanged;
  final TextInputType keyboard;
  _BaseItem({required this.label, required this.sublabel, required this.ctrl, required this.color, required this.onChanged, required this.hint, required this.keyboard});
}
