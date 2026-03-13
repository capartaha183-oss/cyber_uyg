import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

class SslCheckerScreen extends StatefulWidget {
  const SslCheckerScreen({super.key});

  @override
  State<SslCheckerScreen> createState() => _SslCheckerScreenState();
}

class _SslCheckerScreenState extends State<SslCheckerScreen> {
  final TextEditingController _urlCtrl =
      TextEditingController(text: 'google.com');
  bool _loading = false;
  _SslResult? _result;
  String? _error;

  Future<void> _checkSsl() async {
    final host = _urlCtrl.text
        .trim()
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .split('/')[0];

    if (host.isEmpty) return;

    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    try {
      final socket = await SecureSocket.connect(
        host,
        443,
        timeout: const Duration(seconds: 10),
        onBadCertificate: (cert) => true,
      );

      final cert = socket.peerCertificate;
      socket.destroy();

      if (cert != null) {
        final now = DateTime.now();
        final expiry = cert.endValidity;
        final daysLeft = expiry.difference(now).inDays;

        setState(() {
          _result = _SslResult(
            host: host,
            subject: cert.subject,
            issuer: cert.issuer,
            validFrom: cert.startValidity,
            validUntil: expiry,
            daysLeft: daysLeft,
            isValid: now.isAfter(cert.startValidity) &&
                now.isBefore(cert.endValidity),
            isExpiringSoon: daysLeft < 30 && daysLeft > 0,
          );
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bağlantı hatası: ${e.toString().split(':').first}';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('SSL SERTİFİKA KONTROLÜ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input
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
                    controller: _urlCtrl,
                    decoration: InputDecoration(
                      labelText: 'Domain',
                      hintText: 'örn: google.com',
                      prefixIcon: Icon(Icons.lock, color: primary),
                    ),
                    onSubmitted: (_) => _checkSsl(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _checkSsl,
                      icon: _loading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(_loading ? 'KONTROL EDİLİYOR...' : 'KONTROL ET'),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Error
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
                      child: Text(
                        _error!,
                        style: GoogleFonts.jetBrainsMono(
                            color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            // Result
            if (_result != null) ...[
              // Status card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (_result!.isValid ? primary : Colors.red)
                          .withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (_result!.isValid
                            ? _result!.isExpiringSoon
                                ? Colors.orange
                                : primary
                            : Colors.red)
                        .withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _result!.isValid
                              ? Icons.verified_user
                              : Icons.security,
                          color: _result!.isValid
                              ? _result!.isExpiringSoon
                                  ? Colors.orange
                                  : primary
                              : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _result!.isValid
                                    ? _result!.isExpiringSoon
                                        ? 'YAKINDA SÜRESİ DOLACAK!'
                                        : 'GEÇERLİ SERTİFİKA'
                                    : 'GEÇERSİZ SERTİFİKA!',
                                style: GoogleFonts.orbitron(
                                  color: _result!.isValid
                                      ? _result!.isExpiringSoon
                                          ? Colors.orange
                                          : primary
                                      : Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                _result!.host,
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (primary).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_result!.daysLeft} GÜN',
                            style: GoogleFonts.orbitron(
                              color: _result!.daysLeft < 30
                                  ? Colors.orange
                                  : primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow('Konu', _result!.subject, primary),
                    _InfoRow('Yayıncı', _result!.issuer, secondary),
                    _InfoRow(
                      'Başlangıç',
                      _formatDate(_result!.validFrom),
                      Colors.white54,
                    ),
                    _InfoRow(
                      'Bitiş',
                      _formatDate(_result!.validUntil),
                      _result!.isExpiringSoon ? Colors.orange : Colors.white54,
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(curve: Curves.elasticOut),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white30, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  GoogleFonts.jetBrainsMono(color: color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _SslResult {
  final String host;
  final String subject;
  final String issuer;
  final DateTime validFrom;
  final DateTime validUntil;
  final int daysLeft;
  final bool isValid;
  final bool isExpiringSoon;

  _SslResult({
    required this.host,
    required this.subject,
    required this.issuer,
    required this.validFrom,
    required this.validUntil,
    required this.daysLeft,
    required this.isValid,
    required this.isExpiringSoon,
  });
}
