import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';

class ProjectListNotifier extends AsyncNotifier<List<ProjectModel>> {
  @override
  FutureOr<List<ProjectModel>> build() async {
    // Sağlayıcı ilk okunduğunda veriyi otomatik çeker
    return await _fetchProjects();
  }

  Future<List<ProjectModel>> _fetchProjects() async {
    final repository = ref.read(projectRepositoryProvider);
    return await repository.getProjects();
  }

  // Yeni proje eklendiğinde listeyi yenilemek için kullanılacak
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProjects());
  }
}

final projectListProvider = AsyncNotifierProvider<ProjectListNotifier, List<ProjectModel>>(() {
  return ProjectListNotifier();
});


// Proje detayını ID'ye göre çeken family provider
final projectDetailProvider = FutureProvider.family<ProjectModel, int>((ref, projectId) async {
  final repository = ref.watch(projectRepositoryProvider);
  return await repository.getProjectById(projectId);
});