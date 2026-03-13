import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerCtrl = MobileScannerController();
  final TextEditingController _generateCtrl = TextEditingController();

  String? _scannedData;
  bool _isScanning = true;
  bool _isSafe = true;
  bool _analyzed = false;

  final List<String> _suspiciousPatterns = [
    'phishing', 'malware', 'hack', 'free-money',
    'bit.ly', 'tinyurl', 'exe', 'download',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerCtrl.dispose();
    _generateCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      final data = barcode!.rawValue!;
      setState(() {
        _isScanning = false;
        _scannedData = data;
        _analyzed = true;
        _isSafe = !_suspiciousPatterns.any(
            (p) => data.toLowerCase().contains(p));
      });
      HapticFeedback.lightImpact();
    }
  }

  void _resetScan() {
    setState(() {
      _isScanning = true;
      _scannedData = null;
      _analyzed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR KOD TARAYICI'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelStyle: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 1),
          tabs: const [
            Tab(text: 'TARA'),
            Tab(text: 'OLUŞTUR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scanner tab
          Column(
            children: [
              // Camera view
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      child: MobileScanner(
                        controller: _scannerCtrl,
                        onDetect: _onDetect,
                      ),
                    ),
                    // Scan overlay
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: primary, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            // Corner decorations
                            ...['tl', 'tr', 'bl', 'br'].map((corner) {
                              return Positioned(
                                top: corner.startsWith('t') ? -1 : null,
                                bottom: corner.startsWith('b') ? -1 : null,
                                left: corner.endsWith('l') ? -1 : null,
                                right: corner.endsWith('r') ? -1 : null,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: corner.startsWith('t')
                                          ? BorderSide(
                                              color: primary, width: 3)
                                          : BorderSide.none,
                                      bottom: corner.startsWith('b')
                                          ? BorderSide(
                                              color: primary, width: 3)
                                          : BorderSide.none,
                                      left: corner.endsWith('l')
                                          ? BorderSide(
                                              color: primary, width: 3)
                                          : BorderSide.none,
                                      right: corner.endsWith('r')
                                          ? BorderSide(
                                              color: primary, width: 3)
                                          : BorderSide.none,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    // Scanning line
                    if (_isScanning)
                      Center(
                        child: SizedBox(
                          width: 250,
                          child: Divider(
                            color: primary.withOpacity(0.8),
                            thickness: 2,
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .slideY(
                              begin: -5,
                              end: 5,
                              duration: 2.seconds,
                              curve: Curves.easeInOut,
                            ),
                      ),
                    // Top overlay
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isScanning ? 'QR kodu çerçeveye hizalayın' : 'Tarama tamamlandı',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Result panel
              if (_analyzed && _scannedData != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_isSafe ? primary : Colors.red).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isSafe ? Icons.check_circle : Icons.warning,
                            color: _isSafe ? primary : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSafe ? 'GÜVENLİ GÖRÜNÜYOR' : 'ŞÜPHELİ İÇERİK!',
                            style: GoogleFonts.orbitron(
                              color: _isSafe ? primary : Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _resetScan,
                            child: Text(
                              'YENİ',
                              style: GoogleFonts.orbitron(
                                color: secondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'TARAMA SONUCU:',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _scannedData!,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: _scannedData!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Kopyalandı',
                                        style: GoogleFonts.jetBrainsMono()),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('KOPYALA'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.3),
            ],
          ),

          // Generate tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _generateCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'QR içeriği girin',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.qr_code),
                    hintText: 'URL, metin, telefon...',
                  ),
                  onChanged: (v) => setState(() {}),
                ).animate().fadeIn(),

                const SizedBox(height: 24),

                if (_generateCtrl.text.isNotEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _generateCtrl.text,
                        version: QrVersions.auto,
                        size: 220.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ).animate().scale(curve: Curves.elasticOut),

                if (_generateCtrl.text.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.qr_code_2,
                            size: 100, color: primary.withOpacity(0.15)),
                        Text(
                          'Metin girerek QR oluşturun',
                          style: GoogleFonts.jetBrainsMono(
                              color: Colors.white30, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
