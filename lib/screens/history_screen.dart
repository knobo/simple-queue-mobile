import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/queue_models.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ticketHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historikk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementer filtrering
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtrering kommer snart')),
              );
            },
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Kunne ikke laste historikk: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(ticketHistoryProvider),
                child: const Text('Prøv igjen'),
              ),
            ],
          ),
        ),
        data: (tickets) {
          if (tickets.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(ticketHistoryProvider.future),
              child: Stack(
                children: [
                  ListView(), // For pull-to-refresh to work
                  _buildEmptyState(),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(ticketHistoryProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _HistoryCard(ticket: ticket);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ingen historikk ennå',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dine tidligere køer vil vises her',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Ticket ticket;

  const _HistoryCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');
    final theme = Theme.of(context);

    // Bruk ticket.status direkte
    final statusColor = ticket.status.color;
    final statusText = ticket.status.displayName;
    
    IconData statusIcon;
    switch (ticket.status) {
      case TicketStatus.completed:
        statusIcon = Icons.check_circle;
        break;
      case TicketStatus.cancelled:
        statusIcon = Icons.cancel;
        break;
      case TicketStatus.noShow:
        statusIcon = Icons.person_off;
        break;
      case TicketStatus.waiting:
        statusIcon = Icons.hourglass_empty;
        break;
      case TicketStatus.called:
        statusIcon = Icons.notifications_active;
        break;
    }

    String? waitTimeStr;
    if (ticket.actualWaitTime != null) {
      final wait = ticket.actualWaitTime!;
      if (wait.inMinutes < 60) {
        waitTimeStr = '${wait.inMinutes} min';
      } else {
        waitTimeStr = '${wait.inHours} t ${wait.inMinutes % 60} min';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Vis detaljer om gammel billett?
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        ticket.number,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.queueName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(ticket.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (waitTimeStr != null && ticket.status == TicketStatus.completed) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Ventetid: $waitTimeStr',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      '${timeFormat.format(ticket.createdAt)} - ${ticket.completedAt != null ? timeFormat.format(ticket.completedAt!) : "?"}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
