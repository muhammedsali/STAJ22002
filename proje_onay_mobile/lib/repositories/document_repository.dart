import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/document_model.dart';

class DocumentRepository {
  final ApiClient _apiClient;

  DocumentRepository(this._apiClient);

  Future<DocumentModel> uploadDocument(String projectId, String filePath, String fileName, String documentType) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'document_type': documentType,
      });

      final response = await _apiClient.dio.post(
        '/projects/$projectId/documents',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DocumentModel.fromJson(response.data);
      }
      throw Exception('Belge yüklenemedi.');
    } on DioException catch (e) {
      throw Exception('Sunucu hatası: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Beklenmeyen bir hata oluştu.');
    }
  }

  Future<void> signDocument(String documentId) async {
    try {
      final response = await _apiClient.dio.post('/documents/$documentId/sign');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Belge imzalanamadı.');
      }
    } on DioException catch (e) {
      throw Exception('Sunucu hatası: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('İmzalama sırasında bir hata oluştu.');
    }
  }
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DocumentRepository(apiClient);
});