import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/queue_models.dart';
import 'queue_provider.dart';

/// Provider for aktive billetter
final activeTicketsProvider = FutureProvider<List<Ticket>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getActiveTickets();
  return data.map((t) => Ticket.fromJson(t)).toList();
});

/// Provider for billett-historikk
final ticketHistoryProvider = FutureProvider<List<Ticket>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getTicketHistory();
  return data.map((t) => Ticket.fromJson(t)).toList();
});

/// Provider for spesifikk billett
final ticketProvider = FutureProvider.family<Ticket, String>((ref, ticketId) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.getTicket(ticketId);
  return Ticket.fromJson(data);
});

/// StateNotifier for å administrere en billett (oppdateringer, etc.)
class TicketNotifier extends StateNotifier<AsyncValue<Ticket?>> {
  final ApiService _api;
  
  TicketNotifier(this._api) : super(const AsyncValue.data(null));

  /// Bli med i en kø
  Future<void> joinQueue(String queueCode) async {
    state = const AsyncValue.loading();
    try {
      final data = await _api.joinQueue(queueCode);
      final ticket = Ticket.fromJson(data);
      state = AsyncValue.data(ticket);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Forlat køen
  Future<void> leaveQueue(String ticketId) async {
    state = const AsyncValue.loading();
    try {
      await _api.leaveQueue(ticketId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Oppdater billett-data
  Future<void> refreshTicket(String ticketId) async {
    try {
      final data = await _api.getTicket(ticketId);
      final ticket = Ticket.fromJson(data);
      state = AsyncValue.data(ticket);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for TicketNotifier
final ticketNotifierProvider = StateNotifierProvider<TicketNotifier, AsyncValue<Ticket?>>((ref) {
  final api = ref.watch(apiServiceProvider);
  return TicketNotifier(api);
});
