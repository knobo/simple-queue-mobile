import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';

void main() {
  group('Ticket Model', () {
    test('fromJson creates correct Ticket instance', () {
      final json = {
        'id': 't1',
        'queueId': 'q1',
        'queueName': 'Test Q',
        'number': 'A01',
        'position': 3,
        'status': 'waiting',
        'createdAt': '2023-01-01T10:00:00.000',
        'estimatedWaitMinutes': 45,
      };

      final ticket = Ticket.fromJson(json);

      expect(ticket.id, 't1');
      expect(ticket.queueId, 'q1');
      expect(ticket.status, TicketStatus.waiting);
      expect(ticket.estimatedWaitMinutes, 45);
    });

    test('toJson returns correct map', () {
      final ticket = Ticket(
        id: 't1',
        queueId: 'q1',
        queueName: 'Test Q',
        number: 'A01',
        position: 3,
        status: TicketStatus.waiting,
        createdAt: DateTime(2023, 1, 1, 10, 0, 0),
        estimatedWaitMinutes: 45,
      );

      final json = ticket.toJson();
      expect(json['id'], 't1');
      expect(json['status'], 'waiting');
    });

    test('formattedEstimatedWait returns correct string', () {
      final t1 = Ticket(
        id: '', queueId: '', queueName: '', number: '', position: 0,
        status: TicketStatus.waiting, createdAt: DateTime.now(),
        estimatedWaitMinutes: 30,
      );
      expect(t1.formattedEstimatedWait, '30 min');

      final t2 = Ticket(
        id: '', queueId: '', queueName: '', number: '', position: 0,
        status: TicketStatus.waiting, createdAt: DateTime.now(),
        estimatedWaitMinutes: 60,
      );
      expect(t2.formattedEstimatedWait, '1 t');

      final t3 = Ticket(
        id: '', queueId: '', queueName: '', number: '', position: 0,
        status: TicketStatus.waiting, createdAt: DateTime.now(),
        estimatedWaitMinutes: 90,
      );
      expect(t3.formattedEstimatedWait, '1 t 30 min');
    });

    test('isActive returns true only for waiting and called', () {
      final waiting = Ticket(
        id: '', queueId: '', queueName: '', number: '', position: 0,
        status: TicketStatus.waiting, createdAt: DateTime.now(), estimatedWaitMinutes: 0,
      );
      expect(waiting.isActive, true);

      final called = Ticket(
        id: '', queueId: '', queueName: '', number: '', position: 0,
        status: TicketStatus.called, createdAt: DateTime.now(), estimatedWaitMinutes: 0,
      );
      expect(called.isActive, true);

      final completed = Ticket(
        id: '', queueId: '', queueName: '', number: '', position: 0,
        status: TicketStatus.completed, createdAt: DateTime.now(), estimatedWaitMinutes: 0,
      );
      expect(completed.isActive, false);
    });

    test('TicketStatus has correct display name and color', () {
      expect(TicketStatus.waiting.displayName, 'Venter');
      expect(TicketStatus.waiting.color, const Color(0xFF6366F1));

      expect(TicketStatus.called.displayName, 'Din tur!');
      expect(TicketStatus.called.color, const Color(0xFF22C55E));

      expect(TicketStatus.cancelled.displayName, 'Kansellert');
      expect(TicketStatus.cancelled.color, const Color(0xFFEF4444));
    });
  });
}
