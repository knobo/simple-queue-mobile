import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';
import 'package:simple_queue_mobile/providers/providers.dart';
import 'package:simple_queue_mobile/screens/ticket_screen.dart';

import '../mocks.mocks.dart';

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  final testTicket = Ticket(
    id: 't1',
    queueId: 'q1',
    queueName: 'Test Queue',
    number: 'A01',
    position: 5,
    status: TicketStatus.waiting,
    createdAt: DateTime(2023, 1, 1, 10, 0),
    estimatedWaitMinutes: 15,
  );

  testWidgets('TicketScreen shows ticket info', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketProvider('t1').overrideWith((ref) => Future.value(testTicket)),
        ],
        child: const MaterialApp(home: TicketScreen(ticketId: 't1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Queue'), findsOneWidget);
    expect(find.text('A01'), findsOneWidget);
    expect(find.text('Plass 5 i køen'), findsOneWidget);
    expect(find.text('15 min'), findsOneWidget); // formattedEstimatedWait
    expect(find.text('10:00'), findsOneWidget); // joinedAtFormatted
  });

  testWidgets('TicketScreen shows loading state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketProvider('t1').overrideWith((ref) => Future.delayed(const Duration(seconds: 1), () => testTicket)),
        ],
        child: const MaterialApp(home: TicketScreen(ticketId: 't1')),
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('TicketScreen shows error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketProvider('t1').overrideWith((ref) => Future.error('Some Error')),
        ],
        child: const MaterialApp(home: TicketScreen(ticketId: 't1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Kunne ikke laste billett'), findsOneWidget);
    expect(find.textContaining('Some Error'), findsOneWidget);
  });

  testWidgets('Leave queue dialog works', (tester) async {
    // Setup API mock for leaveQueue
    when(mockApiService.leaveQueue(any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketProvider('t1').overrideWith((ref) => Future.value(testTicket)),
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
        child: const MaterialApp(home: TicketScreen(ticketId: 't1')),
      ),
    );

    await tester.pumpAndSettle();

    // Tap "Forlat køen"
    final buttonFinder = find.text('Forlat køen');
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Verify dialog
    expect(find.text('Forlate køen?'), findsOneWidget);
    expect(find.text('Hvis du forlater køen mister du din plass. Er du sikker?'), findsOneWidget);

    // Confirm
    await tester.tap(find.text('Forlat'));
    await tester.pumpAndSettle();

    verify(mockApiService.leaveQueue('t1')).called(1);
  });
}
