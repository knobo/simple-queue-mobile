import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Demo-data - erstattes med faktiske data fra API/database
  final List<Map<String, dynamic>> _historyItems = const [
    {
      'queueName': 'Demo Kø 1',
      'ticketNumber': 'A42',
      'status': 'completed',
      'joinedAt': '2024-01-15T10:30:00',
      'completedAt': '2024-01-15T10:45:00',
      'waitTime': '15 min',
    },
    {
      'queueName': 'Apoteket',
      'ticketNumber': 'B12',
      'status': 'completed',
      'joinedAt': '2024-01-14T14:20:00',
      'completedAt': '2024-01-14T14:35:00',
      'waitTime': '15 min',
    },
    {
      'queueName': 'Legesenteret',
      'ticketNumber': 'C05',
      'status': 'cancelled',
      'joinedAt': '2024-01-10T09:00:00',
      'completedAt': null,
      'waitTime': null,
    },
    {
      'queueName': 'Kundeservice',
      'ticketNumber': 'D88',
      'status': 'completed',
      'joinedAt': '2024-01-08T16:45:00',
      'completedAt': '2024-01-08T17:30:00',
      'waitTime': '45 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historikk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementer filtrering
            },
          ),
        ],
      ),
      body: _historyItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _historyItems.length,
              itemBuilder: (context, index) {
                final item = _historyItems[index];
                return _HistoryCard(
                  queueName: item['queueName'],
                  ticketNumber: item['ticketNumber'],
                  status: item['status'],
                  joinedAt: DateTime.parse(item['joinedAt']),
                  completedAt: item['completedAt'] != null
                      ? DateTime.parse(item['completedAt'])
                      : null,
                  waitTime: item['waitTime'],
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
  final String queueName;
  final String ticketNumber;
  final String status;
  final DateTime joinedAt;
  final DateTime? completedAt;
  final String? waitTime;

  const _HistoryCard({
    required this.queueName,
    required this.ticketNumber,
    required this.status,
    required this.joinedAt,
    this.completedAt,
    this.waitTime,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Fullført';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Avbrutt';
        break;
      case 'no_show':
        statusColor = Colors.orange;
        statusIcon = Icons.person_off;
        statusText = 'Møtte ikke opp';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Ukjent';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Vis detaljer
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
                        ticketNumber,
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
                          queueName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(joinedAt),
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
              if (waitTime != null && status == 'completed') ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Venteid: $waitTime',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      '${timeFormat.format(joinedAt)} - ${timeFormat.format(completedAt!)}',
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
