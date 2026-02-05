import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/queue_models.dart';

/// Provider for ApiService instans
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provider for alle tilgjengelige køer
final queuesProvider = FutureProvider<List<Queue>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getQueues();
  return data.map((q) => Queue.fromJson(q)).toList();
});

/// Provider for søk i køer
final queueSearchProvider = FutureProvider.family<List<Queue>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final api = ref.watch(apiServiceProvider);
  final data = await api.searchQueues(query);
  return data.map((q) => Queue.fromJson(q)).toList();
});

/// Provider for spesifikk kø
final queueProvider = FutureProvider.family<Queue, String>((ref, queueId) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getQueue(queueId);
  return Queue.fromJson(data);
});
