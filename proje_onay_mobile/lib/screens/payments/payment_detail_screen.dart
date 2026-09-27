import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_request_model.dart';
import '../../providers/payment_provider.dart';
import '../../repositories/payment_repository.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final PaymentRequestModel payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  ConsumerState<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  final _reasonController = TextEditingController();
  bool _showReasonField = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleDecision(String decision) async {
    if (decision == 'red') {
      setState(() => _showReasonField = true);
      return;
    }
    await _submitDecision(decision, null);
  }

  Future<void> _submitDecision(String decision, String? reason) async {
    if (decision == 'red' && (reason == null || reason.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen ret gerekçesi girin.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(paymentRepositoryProvider).submitDecision(widget.payment.id, decision, reason);
      
      // Başarılı işlem sonrası kuyruğu yenile
      ref.read(paymentListProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decision == 'onay' ? 'Hakediş onaylandı.' : 'Hakediş reddedildi.'), 
            backgroundColor: decision == 'onay' ? Colors.green : Colors.red
          )
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF002244);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        title: const Text('Hakediş İnceleme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Talep ID: ${widget.payment.id}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${widget.payment.amount} TL', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text('İlgili Proje ID', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Proje No: ${widget.payment.projectId}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Talep Açıklaması', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(widget.payment.description.isEmpty ? 'Açıklama girilmemiş.' : widget.payment.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 32),

            if (!_showReasonField) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _handleDecision('red'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Reddet', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _handleDecision('onay'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Onayla', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ] else ...[
              const Text('Ret Gerekçesi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                maxLines: 4,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Reddetme sebebini detaylıca yazın...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => setState(() { _showReasonField = false; _reasonController.clear(); }),
                      child: const Text('İptal'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _submitDecision('red', _reasonController.text),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Gönder'),
                    ),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}