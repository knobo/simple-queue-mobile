import 'package:dio/dio.dart';

/// API Service for Simple Queue backend
/// 
/// Håndterer alle HTTP-kall til backend API
/// Base URL bør konfigureres basert på miljø (dev/prod)
class ApiService {
  late final Dio _dio;
  
  // TODO: Flytt til miljøvariabel eller konfigurasjon
  static const String _baseUrl = 'https://api.simplequeue.knobo.no';
  
  ApiService({Dio? dio}) {
    _dio = dio ?? Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Legg til interceptors for logging og auth
    if (dio == null) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
    
    // TODO: Legg til auth interceptor for JWT-token
  }

  // ============== QUEUE OPERATIONS ==============

  /// Hent alle tilgjengelige køer
  Future<List<Map<String, dynamic>>> getQueues() async {
    try {
      final response = await _dio.get('/queues');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Hent spesifikk kø med detaljer
  Future<Map<String, dynamic>> getQueue(String queueId) async {
    try {
      final response = await _dio.get('/queues/$queueId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Søk etter køer
  Future<List<Map<String, dynamic>>> searchQueues(String query) async {
    try {
      final response = await _dio.get('/queues/search', 
        queryParameters: {'q': query},
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============== TICKET OPERATIONS ==============

  /// Bli med i en kø (via QR-kode eller kø-ID)
  Future<Map<String, dynamic>> joinQueue(String queueCode) async {
    try {
      final response = await _dio.post('/tickets', data: {
        'queueCode': queueCode,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Hent billett-detaljer
  Future<Map<String, dynamic>> getTicket(String ticketId) async {
    try {
      final response = await _dio.get('/tickets/$ticketId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Forlat køen (slett billett)
  Future<void> leaveQueue(String ticketId) async {
    try {
      await _dio.delete('/tickets/$ticketId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Hent aktive billetter for bruker
  Future<List<Map<String, dynamic>>> getActiveTickets() async {
    try {
      final response = await _dio.get('/tickets/active');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Hent billett-historikk
  Future<List<Map<String, dynamic>>> getTicketHistory() async {
    try {
      final response = await _dio.get('/tickets/history');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============== ERROR HANDLING ==============

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['message'] ?? 'Ukjent feil';
      
      switch (statusCode) {
        case 400:
          return BadRequestException(message);
        case 401:
          return UnauthorizedException(message);
        case 403:
          return ForbiddenException(message);
        case 404:
          return NotFoundException(message);
        case 409:
          return ConflictException(message);
        case 500:
        case 502:
        case 503:
          return ServerException('Serverfeil. Prøv igjen senere.');
        default:
          return ApiException('Feil: $message');
      }
    }
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('Forespørselen tok for lang tid. Sjekk internettforbindelsen.');
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return ConnectionException('Ingen internettforbindelse.');
    }
    
    return ApiException('En uventet feil oppstod: ${error.message}');
  }
}

// ============== CUSTOM EXCEPTIONS ==============

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super('Ikke autorisert: $message');
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super('Ingen tilgang: $message');
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super('Ikke funnet: $message');
}

class ConflictException extends ApiException {
  ConflictException(String message) : super('Konflikt: $message');
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

class ConnectionException extends ApiException {
  ConnectionException(String message) : super(message);
}
