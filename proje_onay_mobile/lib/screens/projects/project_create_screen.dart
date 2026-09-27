import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'document_upload_screen.dart';
import '../../repositories/project_repository.dart';
import '../../providers/project_provider.dart';


class ProjectCreateScreen extends ConsumerStatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  ConsumerState<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends ConsumerState<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedProjectType;
  final List<String> _projectTypes = ['Trafo', 'OG/AG Şebeke', 'Aydınlatma', 'Diğer'];
  
  bool _isLoading = false; // API isteği atılırken butonu dondurmak için

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        title: const Text('Yeni Proje Başvurusu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStepIndicator('Proje', true, primaryColor),
                  _buildStepLine(primaryColor),
                  _buildStepIndicator('Belgeler', false, primaryColor),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Proje Detayları',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Proje Adı',
                  hintText: 'Örn: Merkez Trafo Yenileme',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Proje Tipi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                initialValue: _selectedProjectType,
                items: _projectTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectType = value;
                  });
                },
                validator: (value) => value == null ? 'Lütfen bir tip seçin' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Lokasyon (İl/İlçe/Mahalle)',
                  hintText: 'Örn: Ankara, Çankaya',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kurulu Güç (kVA)',
                  hintText: 'Örn: 400',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.bolt),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Proje hakkında kısa açıklama giriniz...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Devam Et Butonu (API Entegrasyonlu)
              // Devam Et Butonu (API Entegrasyonlu)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading 
                    ? null 
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);

                          try {
                            // Backend'in beklediği formatta veriyi hazırlıyoruz
                            final projectData = {
                              'title': _titleController.text.trim(),
                              'project_type': _selectedProjectType,
                              'location': _locationController.text.trim(),
                              // String gelen kVA değerini ondalıklı sayıya çevir
                              'power_capacity': double.tryParse(_capacityController.text.trim()) ?? 0.0,
                              'description': _descriptionController.text.trim(),
                            };

                            // Repository üzerinden POST isteği at
                            final repo = ref.read(projectRepositoryProvider);
                            // YENİ EKLENEN KISIM: Oluşturulan projenin objesini yakalıyoruz
                            final createdProject = await repo.createProject(projectData);

                            // Liste ekranına dönüldüğünde yeni projenin görünmesi için provider'ı tetikliyoruz
                            ref.read(projectListProvider.notifier).refresh();

                            if (context.mounted) {
                              // Başarılı olursa Belge Yükleme ekranına geç VE ID'yi parametre olarak gönder
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentUploadScreen(projectId: createdProject.id.toString())
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('İleri (Belge Yükleme)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        color: Colors.grey.shade300,
      ),
    );
  }
}