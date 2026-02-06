import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:simple_queue_mobile/services/api_service.dart';

import '../mocks.mocks.dart';

void main() {
  late MockDio mockDio;
  late ApiService apiService;

  setUp(() {
    mockDio = MockDio();
    apiService = ApiService(dio: mockDio);
  });

  group('ApiService', () {
    test('getQueues returns list of queues', () async {
      final responseData = [
        {'id': '1', 'name': 'Queue 1'},
        {'id': '2', 'name': 'Queue 2'},
      ];

      when(mockDio.get(any)).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/queues'),
          ));

      final result = await apiService.getQueues();

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 2);
      expect(result[0]['name'], 'Queue 1');
      verify(mockDio.get('/queues')).called(1);
    });

    test('getQueue returns specific queue', () async {
      final responseData = {'id': '1', 'name': 'Queue 1'};

      when(mockDio.get(any)).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/queues/1'),
          ));

      final result = await apiService.getQueue('1');

      expect(result['id'], '1');
      verify(mockDio.get('/queues/1')).called(1);
    });

    test('searchQueues passes query parameter', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: [],
                statusCode: 200,
                requestOptions: RequestOptions(path: '/queues/search'),
              ));

      await apiService.searchQueues('test');

      verify(mockDio.get(
        '/queues/search',
        queryParameters: {'q': 'test'},
      )).called(1);
    });

    test('joinQueue posts to /tickets', () async {
      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: {'ticketId': '123'},
                statusCode: 200,
                requestOptions: RequestOptions(path: '/tickets'),
              ));

      await apiService.joinQueue('CODE123');

      verify(mockDio.post(
        '/tickets',
        data: {'queueCode': 'CODE123'},
      )).called(1);
    });

    test('error handling - 404 throws NotFoundException', () async {
      when(mockDio.get(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/queues/999'),
        response: Response(
          statusCode: 404,
          data: {'message': 'Not found'},
          requestOptions: RequestOptions(path: '/queues/999'),
        ),
      ));

      expect(
        () => apiService.getQueue('999'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('error handling - timeout throws TimeoutException', () async {
      when(mockDio.get(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/queues'),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
        () => apiService.getQueues(),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('error handling - 500 throws ServerException', () async {
      when(mockDio.get(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/queues'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/queues'),
        ),
      ));

      expect(
        () => apiService.getQueues(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
