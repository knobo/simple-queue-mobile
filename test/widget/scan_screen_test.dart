import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';
import 'package:simple_queue_mobile/providers/providers.dart';
import 'package:simple_queue_mobile/screens/scan_screen.dart';

import '../mocks.mocks.dart';

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  // Helper to pump ScanScreen
  Future<void> pumpScanScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
        child: const MaterialApp(home: ScanScreen()),
      ),
    );
  }

  testWidgets('ScanScreen shows manual entry button', (tester) async {
    await pumpScanScreen(tester);
    
    // Ignore MobileScanner errors if any?
    // MobileScanner might throw on init. 
    // If so, we might need to mock platform channels.
    
    expect(find.text('Skriv inn kode manuelt'), findsOneWidget);
    expect(find.text('Hold QR-koden innenfor rammen'), findsOneWidget);
  });

  testWidgets('Manual entry opens dialog', (tester) async {
    await pumpScanScreen(tester);

    await tester.tap(find.text('Skriv inn kode manuelt'));
    await tester.pumpAndSettle();

    expect(find.text('Skriv inn kø-kode'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Submitting code triggers joinQueue', (tester) async {
    final ticketJson = {
      'id': 't1',
      'queueId': 'q1',
      'queueName': 'Test Q',
      'number': 'A01',
      'position': 1,
      'status': 'waiting',
      'createdAt': DateTime.now().toIso8601String(),
      'estimatedWaitMinutes': 5,
    };

    when(mockApiService.joinQueue(any)).thenAnswer((_) async => ticketJson);

    await pumpScanScreen(tester);

    // Open manual entry
    await tester.tap(find.text('Skriv inn kode manuelt'));
    await tester.pumpAndSettle();

    // Enter code
    await tester.enterText(find.byType(TextField), 'CODE123');
    await tester.tap(find.text('Fortsett'));
    await tester.pumpAndSettle();

    // Confirm dialog
    expect(find.text('Bli med i kø?'), findsOneWidget);
    expect(find.textContaining('CODE123'), findsOneWidget);

    // Click "Bli med"
    await tester.tap(find.text('Bli med'));
    
    // Wait for async operation
    await tester.pump(); 
    
    verify(mockApiService.joinQueue('CODE123')).called(1);
  });
}
