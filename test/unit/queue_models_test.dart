import 'package:flutter_test/flutter_test.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';

void main() {
  group('Queue Model', () {
    test('fromJson creates correct Queue instance', () {
      final json = {
        'id': '123',
        'name': 'Test Queue',
        'description': 'Test Description',
        'code': 'TEST',
        'status': 'active',
        'currentPosition': 5,
        'totalInQueue': 10,
        'averageWaitTime': 15.5,
        'opensAt': '2023-01-01T08:00:00.000',
        'closesAt': '2023-01-01T16:00:00.000',
        'location': {
          'address': 'Test Address',
          'latitude': 10.0,
          'longitude': 20.0,
        },
        'metadata': {'key': 'value'},
      };

      final queue = Queue.fromJson(json);

      expect(queue.id, '123');
      expect(queue.name, 'Test Queue');
      expect(queue.description, 'Test Description');
      expect(queue.code, 'TEST');
      expect(queue.status, QueueStatus.active);
      expect(queue.currentPosition, 5);
      expect(queue.totalInQueue, 10);
      expect(queue.averageWaitTime, 15.5);
      expect(queue.opensAt, DateTime(2023, 1, 1, 8, 0, 0));
      expect(queue.closesAt, DateTime(2023, 1, 1, 16, 0, 0));
      expect(queue.location?.address, 'Test Address');
      expect(queue.metadata?['key'], 'value');
    });

    test('toJson returns correct map', () {
      final queue = Queue(
        id: '123',
        name: 'Test Queue',
        description: 'Test Description',
        code: 'TEST',
        status: QueueStatus.active,
        currentPosition: 5,
        totalInQueue: 10,
        averageWaitTime: 15.5,
        opensAt: DateTime(2023, 1, 1, 8, 0, 0),
        closesAt: DateTime(2023, 1, 1, 16, 0, 0),
        location: Location(address: 'Test Address'),
        metadata: {'key': 'value'},
      );

      final json = queue.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test Queue');
      expect(json['status'], 'active');
      expect(json['averageWaitTime'], 15.5);
      expect(json['opensAt'], contains('2023-01-01T08:00:00'));
    });

    test('formattedWaitTime returns minutes when less than 1 hour', () {
      final queue = Queue(
        id: '1', name: 'Q', description: '', code: 'Q',
        status: QueueStatus.active, currentPosition: 0, totalInQueue: 0,
        averageWaitTime: 0.5, // 30 min
      );
      expect(queue.formattedWaitTime, '30 min');
    });

    test('formattedWaitTime returns hours when 1 hour or more', () {
      final queue1 = Queue(
        id: '1', name: 'Q', description: '', code: 'Q',
        status: QueueStatus.active, currentPosition: 0, totalInQueue: 0,
        averageWaitTime: 1.0, // 1 hour
      );
      expect(queue1.formattedWaitTime, '1 t');

      final queue2 = Queue(
        id: '1', name: 'Q', description: '', code: 'Q',
        status: QueueStatus.active, currentPosition: 0, totalInQueue: 0,
        averageWaitTime: 2.4, // ~2 hours
      );
      expect(queue2.formattedWaitTime, '2 t');
    });

    test('isOpenNow returns correct status', () {
      final now = DateTime.now();
      final openQueue = Queue(
        id: '1', name: 'Q', description: '', code: 'Q',
        status: QueueStatus.active, currentPosition: 0, totalInQueue: 0, averageWaitTime: 0,
        opensAt: now.subtract(const Duration(hours: 1)),
        closesAt: now.add(const Duration(hours: 1)),
      );
      expect(openQueue.isOpenNow, true);

      final closedQueue = Queue(
        id: '1', name: 'Q', description: '', code: 'Q',
        status: QueueStatus.active, currentPosition: 0, totalInQueue: 0, averageWaitTime: 0,
        opensAt: now.subtract(const Duration(hours: 2)),
        closesAt: now.subtract(const Duration(hours: 1)),
      );
      expect(closedQueue.isOpenNow, false);

      final pausedQueue = Queue(
        id: '1', name: 'Q', description: '', code: 'Q',
        status: QueueStatus.paused, currentPosition: 0, totalInQueue: 0, averageWaitTime: 0,
        opensAt: now.subtract(const Duration(hours: 1)),
        closesAt: now.add(const Duration(hours: 1)),
      );
      expect(pausedQueue.isOpenNow, false);
    });

    test('QueueStatus.fromString handles invalid values', () {
      expect(QueueStatus.fromString('active'), QueueStatus.active);
      expect(QueueStatus.fromString('invalid'), QueueStatus.closed);
    });
  });
}
