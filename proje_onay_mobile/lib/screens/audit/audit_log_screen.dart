import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audit_provider.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF002244);
    
    // Provider'dan asenkron olarak gerçek log verilerini dinliyoruz
    final auditLogsAsync = ref.watch(auditLogProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Denetim Kayıtları (Audit Log)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(auditLogProvider.notifier).refresh(),
          )
        ],
      ),
      body: auditLogsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('Henüz sisteme kaydedilmiş bir denetim kaydı yok.'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              
              // Backend'den gelen aksiyona göre dinamik renk ve ikon alıyoruz
              final iconData = _getActionIcon(log.action);
              final color = _getActionColor(log.action);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(iconData, color: color),
                  ),
                  title: Text(
                    log.action.toUpperCase(), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Nesne: ${log.entityType} (ID: ${log.entityId}) | Kullanıcı: ${log.userId ?? "Sistem"}', 
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800)
                      ),
                      const SizedBox(height: 4),
                      Text(log.timestamp, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  // İşlem türüne göre renk belirleyen yardımcı metod
  Color _getActionColor(String action) {
    final act = action.toLowerCase();
    if (act.contains('onay') || act.contains('approved')) return Colors.green;
    if (act.contains('red') || act.contains('rejected')) return Colors.red;
    if (act.contains('sign')) return Colors.purple;
    if (act.contains('check')) return Colors.blue;
    if (act.contains('create') || act.contains('submit')) return Colors.orange;
    return Colors.grey.shade700;
  }

  // İşlem türüne göre ikon belirleyen yardımcı metod
  IconData _getActionIcon(String action) {
    final act = action.toLowerCase();
    if (act.contains('payment')) return Icons.payments;
    if (act.contains('onay') || act.contains('approved')) return Icons.fact_check;
    if (act.contains('check')) return Icons.memory;
    if (act.contains('sign')) return Icons.fingerprint;
    if (act.contains('red') || act.contains('rejected')) return Icons.cancel_outlined;
    return Icons.history;
  }
}