import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});
  @override State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _cmdCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_TermLine> _lines = [];
  String _currentDir = '~/cyberguard';
  final _rand = Random();

  @override
  void initState() { super.initState(); _boot(); }

  void _boot() {
    setState(() {
      _lines.addAll([
        _TermLine('CyberGuard Terminal v2.0', type: LineType.system),
        _TermLine('Developed by Taha Capar', type: LineType.system),
        _TermLine('─' * 38, type: LineType.divider),
        _TermLine('Sistem hazir. "help" yazin.', type: LineType.info),
        _TermLine('', type: LineType.empty),
      ]);
    });
  }

  void _execute(String cmd) {
    cmd = cmd.trim();
    if (cmd.isEmpty) return;
    setState(() => _lines.add(_TermLine('\$$_currentDir > $cmd', type: LineType.input)));
    _cmdCtrl.clear();
    final parts = cmd.split(' ');
    final command = parts[0].toLowerCase();
    final args = parts.sublist(1);

    switch (command) {
      case 'help':
        _out(['Komutlar:', '  help  clear  whoami  pwd  ls', '  ping <host>  scan <ip>  hash <text>', '  b64 <text>  sysinfo  date  about  matrix']);
        break;
      case 'clear':
        setState(() => _lines.clear()); _boot(); return;
      case 'whoami':
        _out(['taha_capar@cyberguard', 'uid=1000 groups=sudo,security']);
        break;
      case 'pwd':
        _out([_currentDir]);
        break;
      case 'ls':
        _out(['drwxr-xr-x  passwords/','drwxr-xr-x  keys/','drwxr-xr-x  logs/','-rw-r--r--  config.enc','-rwxr-xr-x  scanner.sh'], type: LineType.success);
        break;
      case 'ping':
        if (args.isEmpty) { _err('Kullanim: ping <host>'); break; }
        final host = args[0];
        _out(['PING $host (56 bayt)']);
        for (int i = 0; i < 4; i++) _out(['64 bayt: icmp_seq=$i time=${10 + _rand.nextInt(50)} ms']);
        _out(['4 paket iletildi, 4 alindi, %0 kayip']);
        break;
      case 'scan':
        if (args.isEmpty) { _err('Kullanim: scan <ip>'); break; }
        _out(['Taranıyor: ${args[0]}...','PORT      DURUM     SERVIS']);
        _out(['22/tcp    ACIK      SSH'],   type: LineType.warning);
        _out(['80/tcp    ACIK      HTTP'],  type: LineType.warning);
        _out(['443/tcp   ACIK      HTTPS'], type: LineType.warning);
        _out(['3306/tcp  KAPALI    MySQL']); _out(['Tarama tamamlandi.']);
        break;
      case 'hash':
        if (args.isEmpty) { _err('Kullanim: hash <metin>'); break; }
        final fakeHash = List.generate(64, (_) => _rand.nextInt(16).toRadixString(16)).join();
        _out(['SHA256: $fakeHash'], type: LineType.success);
        break;
      case 'b64':
        if (args.isEmpty) { _err('Kullanim: b64 <metin>'); break; }
        final text = args.join(' ');
        final bytes = text.codeUnits;
        final b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        var result = '';
        for (int i = 0; i < bytes.length; i += 3) {
          final b = (i < bytes.length ? bytes[i] << 16 : 0) | (i+1 < bytes.length ? bytes[i+1] << 8 : 0) | (i+2 < bytes.length ? bytes[i+2] : 0);
          result += b64chars[(b >> 18) & 63];
          result += b64chars[(b >> 12) & 63];
          result += i+1 < bytes.length ? b64chars[(b >> 6) & 63] : '=';
          result += i+2 < bytes.length ? b64chars[b & 63] : '=';
        }
        _out(['Encoded: $result'], type: LineType.success);
        break;
      case 'sysinfo':
        _out(['OS        : CyberGuard OS 2.0','Platform  : Android/iOS','Sifrelem  : AES-256-GCM','Gelistirici: Taha Capar','Guvenlik  : AKTIF'], type: LineType.info);
        break;
      case 'date':
        final now = DateTime.now();
        _out(['${now.day}.${now.month}.${now.year} ${now.hour}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}']);
        break;
      case 'matrix':
        _out(['Wake up, Neo...','The Matrix has you...','Follow the white rabbit.'], type: LineType.system);
        break;
      case 'about':
        _out(['╔══════════════════════════════╗','║      CYBERGUARD v2.0         ║','║  Developed by Taha Capar     ║','║  AES-256 | SHA-512 | TOTP    ║','╚══════════════════════════════╝'], type: LineType.system);
        break;
      case 'cd':
        if (args.isNotEmpty) setState(() => _currentDir = '~/${args[0]}');
        break;
      default:
        _err('Komut bulunamadi: $command — "help" yazin');
    }
    _scrollToBottom();
  }

  void _out(List<String> lines, {LineType type = LineType.output}) => setState(() { for (final l in lines) _lines.add(_TermLine(l, type: type)); });
  void _err(String msg) => setState(() => _lines.add(_TermLine('hata: $msg', type: LineType.error)));
  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) { if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut); });

  @override
  void dispose() { _cmdCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00FF88);
    return Scaffold(
      backgroundColor: const Color(0xFF020A02),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020A02),
        title: Text('TERMINAL', style: TextStyle(fontFamily: 'monospace', color: primary, fontSize: 16, letterSpacing: 3, fontWeight: FontWeight.w900)),
        actions: [IconButton(icon: const Icon(Icons.delete_sweep, color: primary), onPressed: () { setState(() => _lines.clear()); _boot(); })],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: _lines.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: SelectableText(_lines[i].text, style: TextStyle(fontFamily: 'monospace', color: _lines[i].color, fontSize: 12, height: 1.5)),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF041004),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text('\$$_currentDir > ', style: const TextStyle(fontFamily: 'monospace', color: primary, fontSize: 12, fontWeight: FontWeight.w700)),
                Expanded(
                  child: TextField(
                    controller: _cmdCtrl,
                    style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false, isDense: true, contentPadding: EdgeInsets.zero),
                    onSubmitted: (cmd) { _execute(cmd); _scrollToBottom(); },
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: primary, size: 18), onPressed: () { _execute(_cmdCtrl.text); _scrollToBottom(); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum LineType { input, output, error, success, warning, info, system, divider, empty }
class _TermLine {
  final String text; final LineType type;
  _TermLine(this.text, {this.type = LineType.output});
  Color get color { switch (type) { case LineType.input: return const Color(0xFF00FF88); case LineType.error: return const Color(0xFFFF3366); case LineType.success: return const Color(0xFF00FF88); case LineType.warning: return const Color(0xFFFFAA00); case LineType.info: return const Color(0xFF00D4FF); case LineType.system: return const Color(0xFFAA44FF); case LineType.divider: return Colors.white12; default: return Colors.white60; } }
}
