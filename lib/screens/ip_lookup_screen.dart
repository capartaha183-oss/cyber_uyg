import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'dart:io';

class IpLookupScreen extends StatefulWidget {
  const IpLookupScreen({super.key});

  @override
  State<IpLookupScreen> createState() => _IpLookupScreenState();
}

class _IpLookupScreenState extends State<IpLookupScreen> {
  final TextEditingController _ipCtrl = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;
  String? _myIp;

  @override
  void initState() {
    super.initState();
    _getMyIp();
  }

  Future<void> _getMyIp() async {
    try {
      final client = HttpClient();
      final request =
          await client.getUrl(Uri.parse('https://api.ipify.org?format=json'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      setState(() => _myIp = data['ip']);
      client.close();
    } catch (_) {}
  }

  Future<void> _lookup(String ip) async {
    if (ip.isEmpty) return;
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    try {
      final client = HttpClient();
      final request = await client
          .getUrl(Uri.parse('http://ip-api.com/json/$ip?lang=tr'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      client.close();

      if (data['status'] == 'success') {
        setState(() => _result = data);
      } else {
        setState(() => _error = 'IP bulunamadı veya geçersiz.');
      }
    } catch (e) {
      setState(() => _error = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('IP SORGULAMA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // My IP card
            if (_myIp != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location, color: secondary, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KENDİ IP\'NİZ',
                          style: GoogleFonts.orbitron(
                            color: Colors.white38,
                            fontSize: 9,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          _myIp!,
                          style: GoogleFonts.jetBrainsMono(
                            color: secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.copy, color: secondary, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _myIp!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kopyalandı',
                                    style: GoogleFonts.jetBrainsMono()),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            _ipCtrl.text = _myIp!;
                            _lookup(_myIp!);
                          },
                          child: Text(
                            'SORGULA',
                            style: GoogleFonts.orbitron(
                              color: secondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            // Search
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
                    controller: _ipCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'IP Adresi',
                      hintText: 'örn: 8.8.8.8',
                      prefixIcon: Icon(Icons.search, color: primary),
                    ),
                    onSubmitted: _lookup,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : () => _lookup(_ipCtrl.text.trim()),
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.radar),
                      label: Text(_loading ? 'SORGULANYOR...' : 'IP SORGULA'),
                    ),
                  ),
                ],
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

            if (_result != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _result!['query'] ?? '',
                          style: GoogleFonts.orbitron(
                            color: primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (_result!['mobile'] == true)
                          _Tag('MOBİL', Colors.orange),
                        if (_result!['proxy'] == true)
                          _Tag('PROXY', Colors.red),
                        if (_result!['hosting'] == true)
                          _Tag('VPS', Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ResultRow(Icons.flag, 'Ülke',
                        '${_result!['country'] ?? '-'} (${_result!['countryCode'] ?? '-'})', primary),
                    _ResultRow(Icons.location_city, 'Şehir',
                        _result!['city'] ?? '-', secondary),
                    _ResultRow(Icons.map, 'Bölge',
                        _result!['regionName'] ?? '-', Colors.white70),
                    _ResultRow(Icons.business, 'ISP',
                        _result!['isp'] ?? '-', Colors.white70),
                    _ResultRow(Icons.corporate_fare, 'Organizasyon',
                        _result!['org'] ?? '-', Colors.white70),
                    _ResultRow(Icons.my_location, 'Koordinat',
                        '${_result!['lat']}, ${_result!['lon']}', Colors.white54),
                    _ResultRow(Icons.access_time, 'Zaman Dilimi',
                        _result!['timezone'] ?? '-', Colors.white54),
                    _ResultRow(Icons.numbers, 'AS',
                        _result!['as'] ?? '-', Colors.white38),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultRow(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                  color: Colors.white30, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(color: color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
