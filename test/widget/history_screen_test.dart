import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';
import 'package:simple_queue_mobile/providers/providers.dart';
import 'package:simple_queue_mobile/screens/history_screen.dart';

void main() {
  testWidgets('HistoryScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketHistoryProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ingen historikk ennå'), findsOneWidget);
    expect(find.text('Dine tidligere køer vil vises her'), findsOneWidget);
  });

  testWidgets('HistoryScreen shows history list', (tester) async {
    final tickets = [
      Ticket(
        id: '1', queueId: 'q1', queueName: 'Queue 1', number: 'A01',
        position: 0, status: TicketStatus.completed,
        createdAt: DateTime(2023, 1, 1, 10, 0),
        calledAt: DateTime(2023, 1, 1, 10, 30),
        completedAt: DateTime(2023, 1, 1, 10, 45),
        estimatedWaitMinutes: 0,
      ),
      Ticket(
        id: '2', queueId: 'q2', queueName: 'Queue 2', number: 'B02',
        position: 0, status: TicketStatus.cancelled,
        createdAt: DateTime(2023, 1, 1, 12, 0),
        estimatedWaitMinutes: 0,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketHistoryProvider.overrideWith((ref) => Future.value(tickets)),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Queue 1'), findsOneWidget);
    expect(find.text('A01'), findsOneWidget);
    expect(find.text('Fullført'), findsOneWidget);
    expect(find.text('Ventetid: 30 min'), findsOneWidget); // 10:30 - 10:00

    expect(find.text('Queue 2'), findsOneWidget);
    expect(find.text('B02'), findsOneWidget);
    expect(find.text('Kansellert'), findsOneWidget);
  });

  testWidgets('HistoryScreen shows error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketHistoryProvider.overrideWith((ref) => Future.error('History Error')),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Kunne ikke laste historikk'), findsOneWidget);
  });
}
