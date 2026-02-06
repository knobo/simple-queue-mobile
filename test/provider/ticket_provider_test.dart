import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_queue_mobile/models/queue_models.dart';
import 'package:simple_queue_mobile/providers/providers.dart';
import 'package:simple_queue_mobile/providers/ticket_provider.dart';

import '../mocks.mocks.dart';

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  final ticketData = {
    'id': 't1', 'queueId': 'q1', 'queueName': 'Q', 'number': 'A1',
    'position': 1, 'status': 'waiting', 'createdAt': DateTime.now().toIso8601String(),
    'estimatedWaitMinutes': 10
  };

  group('Ticket Providers', () {
    test('activeTicketsProvider returns list', () async {
      when(mockApiService.getActiveTickets()).thenAnswer((_) async => [ticketData]);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final result = await container.read(activeTicketsProvider.future);
      expect(result.length, 1);
      expect(result.first.id, 't1');
    });

    test('ticketHistoryProvider returns list', () async {
      when(mockApiService.getTicketHistory()).thenAnswer((_) async => [ticketData]);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final result = await container.read(ticketHistoryProvider.future);
      expect(result.length, 1);
      expect(result.first.id, 't1');
    });

    test('ticketProvider returns ticket', () async {
      when(mockApiService.getTicket('t1')).thenAnswer((_) async => ticketData);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final result = await container.read(ticketProvider('t1').future);
      expect(result.id, 't1');
    });
  });

  group('TicketNotifier', () {
    test('joinQueue success', () async {
      when(mockApiService.joinQueue('CODE')).thenAnswer((_) async => ticketData);

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final notifier = container.read(ticketNotifierProvider.notifier);
      
      await notifier.joinQueue('CODE');

      final state = container.read(ticketNotifierProvider);
      
      expect(state, isA<AsyncData>());
      expect(state.value?.id, 't1');
      verify(mockApiService.joinQueue('CODE')).called(1);
    });

    test('joinQueue failure', () async {
      when(mockApiService.joinQueue('CODE')).thenThrow(Exception('Error'));

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final notifier = container.read(ticketNotifierProvider.notifier);
      
      await notifier.joinQueue('CODE');

      final state = container.read(ticketNotifierProvider);
      
      expect(state, isA<AsyncError>());
    });

    test('leaveQueue success', () async {
      when(mockApiService.leaveQueue('t1')).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
        ],
      );

      final notifier = container.read(ticketNotifierProvider.notifier);
      
      await notifier.leaveQueue('t1');

      final state = container.read(ticketNotifierProvider);
      
      expect(state, isA<AsyncData>());
      expect(state.value, null);
      verify(mockApiService.leaveQueue('t1')).called(1);
    });
  });
}
