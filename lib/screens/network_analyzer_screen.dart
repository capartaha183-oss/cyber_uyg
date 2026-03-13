import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:async';

class NetworkAnalyzerScreen extends StatefulWidget {
  const NetworkAnalyzerScreen({super.key});

  @override
  State<NetworkAnalyzerScreen> createState() => _NetworkAnalyzerScreenState();
}

class _NetworkAnalyzerScreenState extends State<NetworkAnalyzerScreen> {
  bool _isScanning = false;
  int _scanProgress = 0;
  List<_NetworkDevice> _devices = [];
  final TextEditingController _ipCtrl = TextEditingController(text: '192.168.1');
  Timer? _timer;
  String _status = 'Taramaya başlamak için butona basın';

  final _random = Random();

  final List<String> _deviceTypes = [
    'Router', 'Smartphone', 'Laptop', 'Smart TV',
    'IoT Cihazı', 'Tablet', 'Masaüstü', 'Yazıcı',
  ];

  final List<IconData> _deviceIcons = [
    Icons.router, Icons.smartphone, Icons.laptop, Icons.tv,
    Icons.devices_other, Icons.tablet, Icons.desktop_windows, Icons.print,
  ];

  void _startScan() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _scanProgress = 0;
      _devices = [];
      _status = 'Ağ taranıyor...';
    });

    // Simulate network scan
    for (int i = 1; i <= 50; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() {
        _scanProgress = i * 2;
        if (_random.nextDouble() < 0.15) {
          final typeIndex = _random.nextInt(_deviceTypes.length);
          final ip = '${_ipCtrl.text}.${_random.nextInt(254) + 1}';
          final risk = _random.nextDouble();
          _devices.add(_NetworkDevice(
            ip: ip,
            type: _deviceTypes[typeIndex],
            icon: _deviceIcons[typeIndex],
            mac: _generateMac(),
            openPorts: _generatePorts(),
            riskLevel: risk < 0.5
                ? RiskLevel.low
                : risk < 0.8
                    ? RiskLevel.medium
                    : RiskLevel.high,
          ));
        }
      });
    }

    setState(() {
      _isScanning = false;
      _status = '${_devices.length} cihaz bulundu';
    });
  }

  String _generateMac() {
    return List.generate(
        6,
        (i) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
  }

  List<int> _generatePorts() {
    final commonPorts = [22, 80, 443, 8080, 3306, 5432, 21, 23, 25, 53];
    final count = _random.nextInt(4);
    return commonPorts.take(count).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: const Text('AĞ ANALİZÖRÜ')),
      body: Column(
        children: [
          // Control panel
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ipCtrl,
                        style: GoogleFonts.jetBrainsMono(color: primary),
                        decoration: InputDecoration(
                          labelText: 'IP Aralığı',
                          suffixText: '.0/24',
                          suffixStyle: GoogleFonts.jetBrainsMono(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      icon: Icon(_isScanning ? Icons.stop : Icons.search),
                      label: Text(_isScanning ? 'DURDU' : 'TARA'),
                    ),
                  ],
                ),
                if (_isScanning) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _scanProgress / 100,
                      backgroundColor: primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _status,
                        style: GoogleFonts.jetBrainsMono(
                            color: Colors.white38, fontSize: 11),
                      ),
                      Text(
                        '%$_scanProgress',
                        style: GoogleFonts.jetBrainsMono(
                            color: primary, fontSize: 11),
                      ),
                    ],
                  ),
                ] else if (_devices.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: GoogleFonts.jetBrainsMono(
                        color: primary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(),

          // Stats
          if (_devices.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatChip('DÜŞÜK', _devices.where((d) => d.riskLevel == RiskLevel.low).length, Colors.green),
                  const SizedBox(width: 8),
                  _StatChip('ORTA', _devices.where((d) => d.riskLevel == RiskLevel.medium).length, Colors.orange),
                  const SizedBox(width: 8),
                  _StatChip('YÜKSEK', _devices.where((d) => d.riskLevel == RiskLevel.high).length, Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Device list
          Expanded(
            child: _devices.isEmpty && !_isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_find,
                            size: 64, color: primary.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'Ağ taraması başlatın',
                          style: GoogleFonts.jetBrainsMono(
                              color: Colors.white30, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      return _DeviceCard(
                          device: _devices[index], index: index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                  color: color.withOpacity(0.7), fontSize: 9, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

enum RiskLevel { low, medium, high }

class _NetworkDevice {
  final String ip;
  final String type;
  final IconData icon;
  final String mac;
  final List<int> openPorts;
  final RiskLevel riskLevel;

  _NetworkDevice({
    required this.ip,
    required this.type,
    required this.icon,
    required this.mac,
    required this.openPorts,
    required this.riskLevel,
  });
}

class _DeviceCard extends StatelessWidget {
  final _NetworkDevice device;
  final int index;

  const _DeviceCard({required this.device, required this.index});

  Color get _riskColor {
    switch (device.riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  String get _riskLabel {
    switch (device.riskLevel) {
      case RiskLevel.low:
        return 'DÜŞÜK';
      case RiskLevel.medium:
        return 'ORTA';
      case RiskLevel.high:
        return 'YÜKSEK';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(device.icon, color: _riskColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.type,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.ip,
                    style: GoogleFonts.jetBrainsMono(
                        color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    device.mac,
                    style: GoogleFonts.jetBrainsMono(
                        color: Colors.white30, fontSize: 10),
                  ),
                  if (device.openPorts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Açık portlar: ${device.openPorts.join(', ')}',
                      style: GoogleFonts.jetBrainsMono(
                          color: Colors.orange.withOpacity(0.7), fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _riskColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _riskColor.withOpacity(0.4)),
              ),
              child: Text(
                _riskLabel,
                style: GoogleFonts.orbitron(
                  color: _riskColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
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
