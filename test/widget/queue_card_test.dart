import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_queue_mobile/widgets/queue_card.dart';

void main() {
  testWidgets('QueueCard displays correct info', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QueueCard(
            queueName: 'Test Queue',
            ticketNumber: 'A01',
            position: 5,
            estimatedTime: '10 min',
          ),
        ),
      ),
    );

    expect(find.text('Test Queue'), findsOneWidget);
    expect(find.text('A01'), findsOneWidget);
    expect(find.text('Plass 5 i køen'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
  });

  testWidgets('QueueCard triggers onTap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QueueCard(
            queueName: 'Test Queue',
            ticketNumber: 'A01',
            position: 5,
            estimatedTime: '10 min',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(QueueCard));
    await tester.pump();

    expect(tapped, true);
  });
}
