import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = true;
  String? _lastScan;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isNotEmpty && _isScanning) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code != _lastScan) {
        setState(() {
          _isScanning = false;
          _lastScan = code;
        });
        _handleQRCode(code);
      }
    }
  }

  void _handleQRCode(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR-kode scannet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Innhold:'),
            const SizedBox(height: 8),
            SelectableText(code),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
            },
            child: const Text('Scan igjen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Send til API for å bli med i kø
              _showJoinQueueDialog(code);
            },
            child: const Text('Bli med i kø'),
          ),
        ],
      ),
    );
  }

  void _showJoinQueueDialog(String queueCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bli med i kø?'),
        content: Text('Vil du bli med i køen med kode: $queueCode?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
            },
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementer API-kall
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meldt deg på køen!')),
              );
              setState(() => _isScanning = true);
            },
            child: const Text('Bli med'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR-kode'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          
          // Overlay med scan-ramme
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Hjørner for scan-ramme
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  // Topp venstre
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(),
                  ),
                  // Topp høyre
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Transform.rotate(
                      angle: 1.5708,
                      child: _buildCorner(),
                    ),
                  ),
                  // Bunn høyre
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Transform.rotate(
                      angle: 3.14159,
                      child: _buildCorner(),
                    ),
                  ),
                  // Bunn venstre
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Transform.rotate(
                      angle: 4.71239,
                      child: _buildCorner(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Instruksjoner
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Hold QR-koden innenfor rammen',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          
          // Manuell input-knapp
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: FilledButton.tonalIcon(
              onPressed: () {
                _showManualEntryDialog();
              },
              icon: const Icon(Icons.keyboard),
              label: const Text('Skriv inn kode manuelt'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF6366F1), width: 4),
          left: BorderSide(color: Color(0xFF6366F1), width: 4),
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skriv inn kø-kode'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'f.eks. ABC123',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                _handleQRCode(code);
              }
            },
            child: const Text('Fortsett'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup
    super.dispose();
  }
}
