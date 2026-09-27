import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/config.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._apiClient);

  Future<bool> login(String email, String password) async {
    try {
      // FastAPI OAuth2 standardına göre veriyi FormData olarak gönderiyoruz
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Gelen JWT token'ı güvenli depolamaya (Secure Storage) kaydediyoruz
        final token = response.data['access_token'];
        await _storage.write(key: Config.tokenKey, value: token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 401) {
        throw Exception('E-posta veya şifre hatalı.');
      }
      throw Exception('Sunucuya bağlanılamadı: ${e.message}');
    } catch (e) {
      throw Exception('Giriş sırasında bir hata oluştu.');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: Config.tokenKey);
  }
}

// AuthRepository'i Riverpod üzerinden sunan global sağlayıcı
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});