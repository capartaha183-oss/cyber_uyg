import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';

class JwtDecoderScreen extends StatefulWidget {
  const JwtDecoderScreen({super.key});

  @override
  State<JwtDecoderScreen> createState() => _JwtDecoderScreenState();
}

class _JwtDecoderScreenState extends State<JwtDecoderScreen> {
  final TextEditingController _jwtCtrl = TextEditingController();
  Map<String, dynamic>? _header;
  Map<String, dynamic>? _payload;
  String? _signature;
  String? _error;
  bool _isExpired = false;
  int? _expiresIn;

  final _sampleJwt =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

  void _decode(String token) {
    token = token.trim();
    if (token.isEmpty) return;

    setState(() {
      _header = null;
      _payload = null;
      _signature = null;
      _error = null;
      _isExpired = false;
      _expiresIn = null;
    });

    final parts = token.split('.');
    if (parts.length != 3) {
      setState(() => _error = 'Geçersiz JWT formatı! 3 bölüm olmalı.');
      return;
    }

    try {
      final header = _decodeBase64(parts[0]);
      final payload = _decodeBase64(parts[1]);

      final headerJson = jsonDecode(header) as Map<String, dynamic>;
      final payloadJson = jsonDecode(payload) as Map<String, dynamic>;

      // Check expiry
      bool isExpired = false;
      int? expiresIn;
      if (payloadJson.containsKey('exp')) {
        final exp = payloadJson['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        isExpired = exp < now;
        expiresIn = exp - now;
      }

      setState(() {
        _header = headerJson;
        _payload = payloadJson;
        _signature = parts[2];
        _isExpired = isExpired;
        _expiresIn = expiresIn;
      });
    } catch (e) {
      setState(() => _error = 'Decode hatası: Geçersiz JWT içeriği');
    }
  }

  String _decodeBase64(String str) {
    String normalized = str.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return utf8.decode(base64.decode(normalized));
  }

  String _formatValue(dynamic value) {
    if (value is int) {
      // Check if it's a timestamp
      if (value > 1000000000 && value < 9999999999) {
        final dt = DateTime.fromMillisecondsSinceEpoch(value * 1000);
        return '$value (${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')})';
      }
    }
    return value.toString();
  }

  @override
  void dispose() {
    _jwtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('JWT DECODER')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _jwtCtrl,
                    maxLines: 4,
                    style: GoogleFonts.jetBrainsMono(
                        color: Colors.white70, fontSize: 11),
                    decoration: InputDecoration(
                      labelText: 'JWT Token',
                      alignLabelWithHint: true,
                      hintText: 'eyJhbGci...',
                    ),
                    onChanged: _decode,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _decode(_jwtCtrl.text),
                          icon: const Icon(Icons.lock_open),
                          label: const Text('DECODE ET'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          _jwtCtrl.text = _sampleJwt;
                          _decode(_sampleJwt);
                        },
                        child: Text(
                          'ÖRNEK',
                          style: GoogleFonts.orbitron(
                              color: secondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_error!,
                          style: GoogleFonts.jetBrainsMono(
                              color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            // Status banner
            if (_payload != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isExpired ? Colors.red : primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_isExpired ? Colors.red : primary).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isExpired ? Icons.warning : Icons.check_circle,
                      color: _isExpired ? Colors.red : primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isExpired
                          ? 'TOKEN SÜRESİ DOLMUŞ!'
                          : _expiresIn != null
                              ? 'GEÇERLİ • ${(_expiresIn! / 3600).toStringAsFixed(1)} saat kaldı'
                              : 'GEÇERLİ • Süresiz',
                      style: GoogleFonts.orbitron(
                        color: _isExpired ? Colors.red : primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            if (_header != null) ...[
              _JwtSection(
                title: 'HEADER',
                data: _header!,
                color: secondary,
                formatValue: _formatValue,
              ),
              const SizedBox(height: 12),
            ],

            if (_payload != null) ...[
              _JwtSection(
                title: 'PAYLOAD',
                data: _payload!,
                color: primary,
                formatValue: _formatValue,
              ),
              const SizedBox(height: 12),
            ],

            if (_signature != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SIGNATURE',
                            style: GoogleFonts.orbitron(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.copy,
                              color: Colors.orange.withOpacity(0.7), size: 16),
                          onPressed: () =>
                              Clipboard.setData(ClipboardData(text: _signature!)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _signature!,
                      style: GoogleFonts.jetBrainsMono(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _JwtSection extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final Color color;
  final String Function(dynamic) formatValue;

  const _JwtSection({
    required this.title,
    required this.data,
    required this.color,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              title,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...data.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        e.key,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        formatValue(e.value),
                        style: GoogleFonts.jetBrainsMono(
                          color: color.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
