import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/payment_request_model.dart'; // Bu modelin olduğunu varsayıyoruz

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  // Tüm hakediş taleplerini getirir (Onaylayıcı veya Başvuru Sahibi için)
  Future<List<PaymentRequestModel>> getPayments() async {
    try {
      final response = await _apiClient.dio.get('/payments');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => PaymentRequestModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Hakediş listesi getirilirken hata oluştu: $e');
    }
  }

  // Yeni hakediş talebi oluşturur (Başvuru Sahibi)
  Future<void> createRequest(int projectId, double amount, String description) async {
    try {
      await _apiClient.dio.post(
        '/payments',
        data: {
          'project_id': projectId,
          'amount': amount,
          'description': description,
        },
      );
    } catch (e) {
      throw Exception('Hakediş talebi oluşturulamadı: $e');
    }
  }

  // Hakediş talebine karar verir (Onaylayıcı/Admin)
  Future<void> submitDecision(int paymentId, String decision, String? reason) async {
    try {
      await _apiClient.dio.post(
        '/payments/$paymentId/decision',
        data: {
          'decision': decision,
          'reason': reason ?? '',
        },
      );
    } catch (e) {
      throw Exception('Karar kaydedilirken hata oluştu: $e');
    }
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});