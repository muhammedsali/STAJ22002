import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_model.dart';
import '../../providers/project_provider.dart';
import '../../widgets/step_indicator.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Proje verisini asenkron olarak çekiyoruz
    final projectAsyncValue = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proje Detayları'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: projectAsyncValue.when(
        data: (project) => _buildBody(context, project),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Bir hata oluştu: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectModel project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Proje Temel Bilgileri
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Null kontrolü (??) eklenerek hatalar giderildi
                  _infoRow(Icons.location_on, 'Konum', project.location ?? 'Belirtilmemiş'),
                  _infoRow(Icons.electrical_services, 'Tür', project.projectType ?? 'Belirtilmemiş'),
                  _infoRow(
                    Icons.bolt, 
                    'Güç Kapasitesi', 
                    project.powerCapacity != null ? '${project.powerCapacity} kW' : 'Belirtilmemiş'
                  ),
                  const Divider(height: 24),
                  const Text('Açıklama:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(project.description ?? 'Açıklama bulunmuyor.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Durum Zaman Çizelgesi
          const Text(
            'Onay Süreci',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StepIndicator(currentStatus: project.status),
            ),
          ),
          
          // Eğer ek belge istenmişse veya reddedilmişse uyarı gösterilebilir
          if (project.status == 'ek_belge_istendi' || project.status == 'reddedildi')
             Padding(
               padding: const EdgeInsets.only(top: 16.0),
               child: Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.red.shade50,
                   border: Border.all(color: Colors.red.shade200),
                   borderRadius: BorderRadius.circular(8)
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                     const SizedBox(width: 8),
                     Expanded(
                       child: Text(
                         project.status == 'reddedildi' 
                            ? 'Projeniz TEDAŞ onay birimi tarafından reddedilmiştir.' 
                            : 'Projenizde eksik/hatalı evrak tespit edildi. Lütfen düzenleyip tekrar gönderin.',
                         style: TextStyle(color: Colors.red.shade900),
                       ),
                     ),
                   ],
                 ),
               ),
             )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}