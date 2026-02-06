import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';
import 'package:simple_queue_mobile/providers/providers.dart';
import 'package:simple_queue_mobile/providers/queue_provider.dart';

import '../mocks.mocks.dart';

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  group('Queue Providers', () {
    test('queuesProvider returns list of queues', () async {
      final queueData = [
        {
          'id': '1', 'name': 'Queue 1', 'description': '', 'code': 'Q1',
          'status': 'active', 'currentPosition': 0, 'totalInQueue': 0, 'averageWaitTime': 0.0
        }
      ];

      when(mockApiService.getQueues()).thenAnswer((_) async => queueData);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final result = await container.read(queuesProvider.future);

      expect(result.length, 1);
      expect(result.first.name, 'Queue 1');
      verify(mockApiService.getQueues()).called(1);
    });

    test('queueProvider returns specific queue', () async {
      final queueData = {
        'id': '1', 'name': 'Queue 1', 'description': '', 'code': 'Q1',
        'status': 'active', 'currentPosition': 0, 'totalInQueue': 0, 'averageWaitTime': 0.0
      };

      when(mockApiService.getQueue('1')).thenAnswer((_) async => queueData);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final result = await container.read(queueProvider('1').future);

      expect(result.id, '1');
      expect(result.name, 'Queue 1');
      verify(mockApiService.getQueue('1')).called(1);
    });

    test('queueSearchProvider returns matching queues', () async {
      final queueData = [
        {
          'id': '1', 'name': 'Found Queue', 'description': '', 'code': 'Q1',
          'status': 'active', 'currentPosition': 0, 'totalInQueue': 0, 'averageWaitTime': 0.0
        }
      ];

      when(mockApiService.searchQueues('found')).thenAnswer((_) async => queueData);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final result = await container.read(queueSearchProvider('found').future);

      expect(result.length, 1);
      expect(result.first.name, 'Found Queue');
      verify(mockApiService.searchQueues('found')).called(1);
    });

    test('queueSearchProvider returns empty list for empty query', () async {
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final result = await container.read(queueSearchProvider('').future);

      expect(result, isEmpty);
      verifyNever(mockApiService.searchQueues(any));
    });
  });
}
