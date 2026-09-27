import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audit_log_model.dart';
import '../core/api_client.dart';

// --- REPOSITORY ---
class AuditRepository {
  final ApiClient _apiClient;
  AuditRepository(this._apiClient);

  Future<List<AuditLogModel>> getAuditLogs() async {
    try {
      final response = await _apiClient.dio.get('/audit-logs');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => AuditLogModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Denetim kayıtları alınamadı: $e');
    }
  }
}

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository(ref.watch(apiClientProvider));
});

// --- NOTIFIER ---
class AuditLogNotifier extends AsyncNotifier<List<AuditLogModel>> {
  @override
  FutureOr<List<AuditLogModel>> build() async {
    return await _fetchLogs();
  }

  Future<List<AuditLogModel>> _fetchLogs() async {
    final repository = ref.read(auditRepositoryProvider);
    return await repository.getAuditLogs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchLogs());
  }
}

final auditLogProvider = AsyncNotifierProvider<AuditLogNotifier, List<AuditLogModel>>(() {
  return AuditLogNotifier();
});