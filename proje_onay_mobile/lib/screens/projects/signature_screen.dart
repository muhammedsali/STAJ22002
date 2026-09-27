import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/document_repository.dart';

class SignatureScreen extends ConsumerStatefulWidget {
  final String documentId;

  const SignatureScreen({super.key, this.documentId = '1'});

  @override
  ConsumerState<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends ConsumerState<SignatureScreen> {
  bool _isSigning = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF002244);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        title: const Text('E-İmza Ekranı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildStepIndicator('Proje', true, primaryColor),
                  _buildStepLine(primaryColor),
                  _buildStepIndicator('Belgeler', true, primaryColor),
                  _buildStepLine(primaryColor),
                  _buildStepIndicator('İmza', true, primaryColor),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Bağlantı Anlaşması Taslağı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(height: 20, width: 150, color: Colors.grey.shade200),
                      const SizedBox(height: 32),
                      Container(height: 12, width: double.infinity, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Container(height: 12, width: double.infinity, color: Colors.grey.shade200),
                      const Spacer(),
                      
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Güvenli Elektronik İmza', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('TEDAŞ Demo Sertifikası', style: TextStyle(color: Colors.orange.shade600, fontSize: 10)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu belgeyi imzaladığınızda PADES formatında kriptografik olarak mühürlenecek ve otomatik ön kontrole gönderilecektir.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isSigning ? null : () async {
                  setState(() => _isSigning = true);
                  
                  try {
                    final repo = ref.read(documentRepositoryProvider);
                    // Backend'deki pyHanko imzalama servisini tetikliyoruz
                    await repo.signDocument(widget.documentId);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Evrak başarıyla PADES ile imzalandı ve ön kontrole gönderildi.'), backgroundColor: Colors.green),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSigning = false);
                  }
                },
                icon: _isSigning 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.fingerprint),
                label: Text(
                  _isSigning ? 'İmzalanıyor...' : 'PADES ile İmzala',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String title, bool isActive, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? color : Colors.grey.shade300,
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: isActive ? color : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepLine(Color color) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        color: color,
      ),
    );
  }
}