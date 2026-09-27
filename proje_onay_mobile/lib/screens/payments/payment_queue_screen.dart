import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/status_badge.dart';
import '../../providers/payment_provider.dart';
import 'payment_detail_screen.dart';
import 'payment_request_screen.dart';

class PaymentQueueScreen extends ConsumerWidget {
  const PaymentQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF002244);
    
    // Tüm ödeme verisini provider'dan asenkron olarak dinliyoruz
    final paymentQueueAsync = ref.watch(paymentListProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Hakediş Onayları', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(paymentListProvider.notifier).refresh(),
          )
        ],
      ),
      body: paymentQueueAsync.when(
        data: (payments) {
          // Sadece onaylanmayı bekleyen talepleri filtrele
          final pendingPayments = payments.where((p) => 
            p.status == 'talep_edildi' || 
            p.status == 'kademe1_onay' || 
            p.status == 'kademe2_onay'
          ).toList();

          if (pendingPayments.isEmpty) {
            return const Center(child: Text('Onay bekleyen hakediş talebi bulunmuyor.', style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingPayments.length,
            itemBuilder: (context, index) {
              final payment = pendingPayments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.payments, color: Colors.green)),
                  title: Text('${payment.amount} TL', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Proje ID: ${payment.projectId}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      const SizedBox(height: 8),
                      StatusBadge(status: payment.status),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Seçilen ödeme talebini detay ekranına yolluyoruz
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => PaymentDetailScreen(payment: payment))
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.red))),
      ),
      // Başvuru sahibinin de taleplerini aynı ekrandan simüle edebilmesi için hızlı eylem butonu
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentRequestScreen())),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni Talep', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}