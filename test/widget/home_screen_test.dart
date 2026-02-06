import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';
import 'package:simple_queue_mobile/providers/providers.dart';
import 'package:simple_queue_mobile/screens/home_screen.dart';
import 'package:simple_queue_mobile/screens/ticket_screen.dart';

void main() {
  testWidgets('HomeScreen shows loading state initially', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTicketsProvider.overrideWith((ref) => Completer<List<Ticket>>().future),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen shows loading indicator', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTicketsProvider.overrideWith((ref) => Future.delayed(const Duration(seconds: 1), () => [])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Initial frame
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Finish loading
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('HomeScreen shows list of tickets', (tester) async {
    final tickets = [
      Ticket(
        id: '1', queueId: 'q1', queueName: 'Queue 1', number: 'A01',
        position: 1, status: TicketStatus.waiting, createdAt: DateTime.now(), estimatedWaitMinutes: 10,
      ),
      Ticket(
        id: '2', queueId: 'q2', queueName: 'Queue 2', number: 'B02',
        position: 2, status: TicketStatus.waiting, createdAt: DateTime.now(), estimatedWaitMinutes: 20,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTicketsProvider.overrideWith((ref) => Future.value(tickets)),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Queue 1'), findsOneWidget);
    expect(find.text('A01'), findsOneWidget);
    expect(find.text('Queue 2'), findsOneWidget);
    expect(find.text('B02'), findsOneWidget);
  });

  testWidgets('HomeScreen shows error message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTicketsProvider.overrideWith((ref) => Future.error('Network Error')),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Kunne ikke laste billetter'), findsOneWidget);
    expect(find.textContaining('Network Error'), findsOneWidget);
  });

  testWidgets('HomeScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTicketsProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Du har ingen aktive billetter'), findsOneWidget);
  });

  testWidgets('Navigates to TicketScreen on tap', (tester) async {
    final tickets = [
      Ticket(
        id: '1', queueId: 'q1', queueName: 'Queue 1', number: 'A01',
        position: 1, status: TicketStatus.waiting, createdAt: DateTime.now(), estimatedWaitMinutes: 10,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTicketsProvider.overrideWith((ref) => Future.value(tickets)),
          // We need to override ticketProvider for the next screen too, 
          // or it will try to fetch real data
          ticketProvider('1').overrideWith((ref) => Future.value(tickets[0])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Queue 1'));
    await tester.pumpAndSettle();

    expect(find.byType(TicketScreen), findsOneWidget);
  });
}
