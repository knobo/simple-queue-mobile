import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';

class TicketScreen extends ConsumerStatefulWidget {
  final String? ticketId;
  const TicketScreen({super.key, this.ticketId});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.ticketId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Billett')),
        body: const Center(
          child: Text('Ingen billett valgt. Gå til Hjem eller Scan.'),
        ),
      );
    }

    final ticketAsync = ref.watch(ticketProvider(widget.ticketId!));
    
    // Lytt på endringer i ticketNotifier (f.eks. ved forlat kø)
    ref.listen(ticketNotifierProvider, (previous, next) {
      next.when(
        data: (ticket) {
          if (ticket == null && previous?.value != null) {
            // Suksessfullt forlatt kø
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Du har forlatt køen')),
            );
          }
        },
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Feil: $err'),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Din billett'),
      ),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Kunne ikke laste billett: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(ticketProvider(widget.ticketId!)),
                child: const Text('Prøv igjen'),
              ),
            ],
          ),
        ),
        data: (ticket) {
          final theme = Theme.of(context);
          final joinedAtFormatted = DateFormat('HH:mm').format(ticket.createdAt);

          return RefreshIndicator(
            onRefresh: () => ref.refresh(ticketProvider(widget.ticketId!).future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hovedbillett-kort
                  Card(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primaryContainer,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            ticket.queueName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'DITT NUMMER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ticket.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Plass ${ticket.position} i køen', // API returnerer ikke totalInQueue på Ticket, bare posisjon
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info-kort
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.access_time,
                            label: 'Estimert ventetid',
                            value: ticket.formattedEstimatedWait,
                            color: Colors.orange,
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.login,
                            label: 'Ble med i køen',
                            value: joinedAtFormatted,
                            color: Colors.green,
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.notifications_active,
                            label: 'Status',
                            value: ticket.status.displayName,
                            color: ticket.status.color,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // QR-kode for billett
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Vis denne QR-koden',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.qr_code_2,
                                size: 150,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Billett-ID: ${ticket.id}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Forlat kø-knapp
                  if (ticket.isActive)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLeaveQueueDialog(context),
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: const Text(
                          'Forlat køen',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLeaveQueueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Forlate køen?'),
        content: const Text(
          'Hvis du forlater køen mister du din plass. Er du sikker?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Avbryt'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final notifierState = ref.watch(ticketNotifierProvider);
              final isLoading = notifierState.isLoading;

              return FilledButton(
                onPressed: isLoading ? null : () async {
                  Navigator.pop(dialogContext); // Lukk dialog først
                  await ref.read(ticketNotifierProvider.notifier).leaveQueue(widget.ticketId!);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Forlat'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
