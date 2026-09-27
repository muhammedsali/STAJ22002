import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'signature_screen.dart';
import '../../repositories/document_repository.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final String projectId;
  
  // Proje oluşturulduğunda dönen ID'yi bu ekrana parametre olarak alıyoruz
  const DocumentUploadScreen({super.key, this.projectId = '1'}); 

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final List<Map<String, dynamic>> _uploadedFiles = [];
  bool _isUploading = false;
  String? _uploadedDocumentId; 

  Future<void> _pickAndUploadFile() async {
    final PlatformFile? result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.path == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final filePath = result.path!;
      final fileName = result.name;

      final repo = ref.read(documentRepositoryProvider);

      final uploadedDoc = await repo.uploadDocument(
        widget.projectId,
        filePath,
        fileName,
        'proje_taslagi',
      );

      if (!mounted) return;

      setState(() {
        _uploadedDocumentId = uploadedDoc.id; 
        _uploadedFiles.add({
          'name': fileName,
          'status': 'completed',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belge başarıyla yüklendi.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
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
        title: const Text('Belge Yükleme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  _buildStepLine(Colors.grey.shade300),
                  _buildStepIndicator('İmza', false, primaryColor),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Bağlantı Başvurusu Evrakları',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Lütfen başvurunuz için gerekli belgeleri sisteme yükleyiniz. Maksimum dosya boyutu 10 MB\'dır.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Yükleme Alanı
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue.shade700),
                    const SizedBox(height: 16),
                    const Text(
                      'PDF veya JPEG/PNG yükleyebilirsiniz',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _pickAndUploadFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        elevation: 0,
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                      child: _isUploading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Dosya Seç'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Yüklenen Belgeler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              Expanded(
                child: _uploadedFiles.isEmpty
                    ? const Center(child: Text('Henüz belge yüklenmedi.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _uploadedFiles.length,
                        itemBuilder: (context, index) {
                          final file = _uploadedFiles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                              title: Text(file['name']),
                              subtitle: const Text('Durum: Yüklendi', style: TextStyle(color: Colors.green)),
                            ),
                          );
                        },
                      ),
              ),

              ElevatedButton(
                onPressed: (_uploadedFiles.isEmpty || _uploadedDocumentId == null) ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignatureScreen(documentId: _uploadedDocumentId!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Devam Et (E-İmza)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          child: Icon(isActive ? Icons.check : Icons.circle, size: 16, color: Colors.white),
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