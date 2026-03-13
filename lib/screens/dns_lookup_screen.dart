import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

class DnsLookupScreen extends StatefulWidget {
  const DnsLookupScreen({super.key});

  @override
  State<DnsLookupScreen> createState() => _DnsLookupScreenState();
}

class _DnsLookupScreenState extends State<DnsLookupScreen> {
  final TextEditingController _domainCtrl =
      TextEditingController(text: 'google.com');
  bool _loading = false;
  List<_DnsRecord> _records = [];
  String? _error;
  String? _reverseDns;

  final List<String> _quickDomains = [
    'google.com', 'cloudflare.com', 'github.com', 'amazon.com', 'microsoft.com'
  ];

  Future<void> _lookup() async {
    final domain = _domainCtrl.text.trim()
        .replaceAll('https://', '').replaceAll('http://', '').split('/')[0];
    if (domain.isEmpty) return;

    setState(() {
      _loading = true;
      _records = [];
      _error = null;
      _reverseDns = null;
    });

    try {
      // A records
      final addresses = await InternetAddress.lookup(domain);
      final aRecords = addresses
          .where((a) => a.type == InternetAddressType.IPv4)
          .map((a) => _DnsRecord(type: 'A', value: a.address))
          .toList();

      final aaaaRecords = addresses
          .where((a) => a.type == InternetAddressType.IPv6)
          .map((a) => _DnsRecord(type: 'AAAA', value: a.address))
          .toList();

      // Reverse DNS for first IP
      String? reverse;
      if (aRecords.isNotEmpty) {
        try {
          final addr = await InternetAddress(aRecords.first.value).reverse();
          reverse = addr.host;
        } catch (_) {}
      }

      setState(() {
        _records = [...aRecords, ...aaaaRecords];
        _reverseDns = reverse;
        if (_records.isEmpty) {
          _error = 'DNS kaydı bulunamadı.';
        }
      });
    } on SocketException catch (e) {
      setState(() => _error = 'DNS hatası: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Hata: ${e.toString().split(':').first}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _domainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('DNS SORGULAMA')),
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
                    controller: _domainCtrl,
                    decoration: InputDecoration(
                      labelText: 'Domain',
                      hintText: 'örn: google.com',
                      prefixIcon: Icon(Icons.dns, color: primary),
                    ),
                    onSubmitted: (_) => _lookup(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _lookup,
                      icon: _loading
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.search),
                      label: Text(_loading ? 'SORGULANYOR...' : 'DNS SORGULA'),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 12),

            // Quick domains
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickDomains.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () {
                    _domainCtrl.text = _quickDomains[i];
                    _lookup();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      _quickDomains[i],
                      style: GoogleFonts.jetBrainsMono(
                          color: Colors.white54, fontSize: 11),
                    ),
                  ),
                ),
              ),
            ).animate(delay: 100.ms).fadeIn(),

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

            if (_records.isNotEmpty) ...[
              Text(
                'DNS KAYITLARI',
                style: GoogleFonts.orbitron(
                    color: Colors.white38, fontSize: 11, letterSpacing: 4),
              ),
              const SizedBox(height: 12),

              ..._records.asMap().entries.map((entry) => _DnsCard(
                    record: entry.value,
                    index: entry.key,
                    primary: primary,
                    secondary: secondary,
                  )),

              if (_reverseDns != null) ...[
                const SizedBox(height: 8),
                _DnsCard(
                  record: _DnsRecord(type: 'PTR', value: _reverseDns!),
                  index: _records.length,
                  primary: Colors.orange,
                  secondary: Colors.orange.withOpacity(0.7),
                ),
              ],
            ],

            if (_records.isEmpty && !_loading && _error == null)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.dns, size: 64, color: primary.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'Domain girerek DNS sorgulayın',
                      style: GoogleFonts.jetBrainsMono(
                          color: Colors.white30, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DnsRecord {
  final String type;
  final String value;
  _DnsRecord({required this.type, required this.value});
}

class _DnsCard extends StatelessWidget {
  final _DnsRecord record;
  final int index;
  final Color primary;
  final Color secondary;

  const _DnsCard({
    required this.record,
    required this.index,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: primary.withOpacity(0.4)),
              ),
              child: Text(
                record.type,
                style: GoogleFonts.orbitron(
                  color: primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectableText(
                record.value,
                style: GoogleFonts.jetBrainsMono(
                    color: Colors.white70, fontSize: 12),
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: primary.withOpacity(0.5), size: 16),
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: record.value)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn()
        .slideX(begin: 0.2);
  }
}
