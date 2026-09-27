import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_provider.dart';
import '../../repositories/payment_repository.dart';

class PaymentRequestScreen extends ConsumerStatefulWidget {
  const PaymentRequestScreen({super.key});

  @override
  ConsumerState<PaymentRequestScreen> createState() => _PaymentRequestScreenState();
}

class _PaymentRequestScreenState extends ConsumerState<PaymentRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // İleride backend'den sadece onaylı projeler çekilerek doldurulacak. 
  // Şimdilik demo amacıyla ID'si 1 olan bir proje simüle ediyoruz.
  int? _selectedProjectId;
  
  final List<Map<String, dynamic>> _approvedProjects = [
    {'id': 1, 'title': 'TR-2026-002: Çankaya Bölgesi OG/AG Şebeke'}
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || _selectedProjectId == null) return;

    setState(() => _isLoading = true);
    
    try {
      final amount = double.parse(_amountController.text.trim());
      final description = _descriptionController.text.trim();

      // Repository üzerinden POST isteği at
      await ref.read(paymentRepositoryProvider).createRequest(
        _selectedProjectId!, 
        amount, 
        description
      );

      // Başarılı olursa listeyi yenile
      ref.read(paymentListProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hakediş talebi başarıyla oluşturuldu.'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF002244);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        title: const Text('Hakediş Talebi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sadece "Onaylandı" statüsündeki projeleriniz için hakediş talep edebilirsiniz.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Proje Seçiniz',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.folder_special),
                ),
                items: _approvedProjects.map((proj) {
                  return DropdownMenuItem<int>(
                    value: proj['id'] as int, 
                    child: Text(proj['title'] as String)
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedProjectId = val),
                validator: (val) => val == null ? 'Lütfen proje seçin' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Talep Edilen Tutar (TL)',
                  hintText: 'Örn: 50000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_lira),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Tutar girilmesi zorunludur';
                  if (double.tryParse(val) == null) return 'Geçerli bir sayı giriniz';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Açıklama / Fatura Detayı',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitRequest,
                  icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Gönderiliyor...' : 'Talep Gönder', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}