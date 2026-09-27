import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApprovalReviewScreen extends ConsumerStatefulWidget {
  const ApprovalReviewScreen({super.key});

  @override
  ConsumerState<ApprovalReviewScreen> createState() => _ApprovalReviewScreenState();
}

class _ApprovalReviewScreenState extends ConsumerState<ApprovalReviewScreen> {
  final _reasonController = TextEditingController();
  bool _showReasonField = false;
  String _selectedAction = '';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _handleDecision(String action) {
    if (action == 'onay') {
      // TODO: API'ye onay isteği at
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proje onaylandı.'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      setState(() {
        _selectedAction = action;
        _showReasonField = true;
      });
    }
  }

  void _submitReason() {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir gerekçe girin.'), backgroundColor: Colors.red));
      return;
    }
    // TODO: API'ye red/ek_belge isteği at (reason ile birlikte)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İşlem tamamlandı: $_selectedAction'), backgroundColor: Colors.blue));
    Navigator.pop(context);
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
        title: const Text('Başvuru İnceleme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TR-2026-001', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Ankara Merkez Trafo Yenileme', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 16),
            
            // Otomatik Ön Kontrol Sonucu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ön Kontrol Başarılı', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                        const Text('Evraklar tam ve e-imza geçerli.', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Yüklenen Belgeler
            const Text('Yüklenen Belgeler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Baglanti_Anlasmasi_Taslagi.pdf'),
                subtitle: const Text('PADES İmzalı'),
                trailing: IconButton(icon: const Icon(Icons.remove_red_eye, color: Colors.blue), onPressed: () {}),
              ),
            ),
            const SizedBox(height: 32),

            // Karar Butonları
            if (!_showReasonField) ...[
              const Text('İnceleme Kararı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleDecision('onay'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: const Icon(Icons.check),
                      label: const Text('Onayla'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDecision('ek_belge'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade700, side: BorderSide(color: Colors.orange.shade700), padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Ek Belge İste'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDecision('red'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: const Icon(Icons.close),
                      label: const Text('Reddet'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Gerekçe Formu (Red / Ek Belge için)
              Text('${_selectedAction == "red" ? "Red" : "Ek Belge"} Gerekçesi', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Lütfen kararınızın gerekçesini detaylıca yazın...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() { _showReasonField = false; _reasonController.clear(); }),
                      child: const Text('İptal'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReason,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                      child: const Text('Gönder'),
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