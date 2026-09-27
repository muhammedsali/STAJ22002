import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final ApiClient _apiClient;

  ProjectRepository(this._apiClient);

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _apiClient.dio.get('/projects');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Projeler getirilirken bir hata oluştu.');
    }
  }

  // YENİ EKLENEN METOT: Backend'e yeni proje kaydı atar
  Future<ProjectModel> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await _apiClient.dio.post('/projects', data: projectData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProjectModel.fromJson(response.data);
      }
      throw Exception('Proje oluşturulamadı.');
    } on DioException catch (e) {
      throw Exception('Sunucu hatası: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu.');
    }
  }

  // EKSİK OLAN METOT BURAYA EKLENDİ: Tekil proje detayını ID ile getirir
  Future<ProjectModel> getProjectById(int id) async {
    try {
      final response = await _apiClient.dio.get('/projects/$id');
      if (response.statusCode == 200) {
        return ProjectModel.fromJson(response.data);
      }
      throw Exception('Proje detayı alınamadı.');
    } on DioException catch (e) {
      throw Exception('Sunucu hatası: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Proje detayı çekilirken hata oluştu: $e');
    }
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProjectRepository(apiClient);
});