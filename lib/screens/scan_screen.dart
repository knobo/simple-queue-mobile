import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/providers.dart';
import 'ticket_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _isScanning = true;
  String? _lastScan;
  MobileScannerController controller = MobileScannerController();

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
    // Vi antar at koden er queueCode. I fremtiden kan vi parse URL.
    // Vis bekreftelsesdialog før vi joiner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bli med i kø?'),
        content: Text('Funnet kode: $code\nVil du stille deg i denne køen?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Lukk dialog
              setState(() {
                _isScanning = true;
                _lastScan = null; // Tillat ny scan av samme kode
              });
            },
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Lukk dialog
              _joinQueue(code);
            },
            child: const Text('Bli med'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinQueue(String code) async {
    // Kall på provider for å joine
    await ref.read(ticketNotifierProvider.notifier).joinQueue(code);
  }

  @override
  Widget build(BuildContext context) {
    // Lytt på status for join
    ref.listen(ticketNotifierProvider, (previous, next) {
      next.when(
        data: (ticket) {
          if (ticket != null) {
            // Suksess! Naviger til TicketScreen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Du er nå i køen!'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TicketScreen(ticketId: ticket.id),
              ),
            );
          }
        },
        error: (err, stack) {
          // Feil oppstod
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kunne ikke bli med i køen: $err'),
              backgroundColor: Colors.red,
            ),
          );
          // Start scanning igjen
          setState(() {
            _isScanning = true;
            _lastScan = null;
          });
        },
        loading: () {
          // Viser loading overlay via build-metoden under
        },
      );
    });

    final isLoading = ref.watch(ticketNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR-kode'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
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

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
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
    controller.dispose();
    super.dispose();
  }
}
