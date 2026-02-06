import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_queue_mobile/services/api_service.dart';

@GenerateMocks([
  Dio,
  ApiService,
  SharedPreferences,
])
void main() {}
