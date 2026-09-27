import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading(); // UI'ı yükleniyor durumuna geçir
    try {
      final repository = ref.read(authRepositoryProvider);
      final success = await repository.login(email, password);
      
      state = const AsyncData(null); 
      return success;
    } catch (e, stack) {
      state = AsyncError(e, stack); // Hata durumunu yakala ve arayüze (UI) ilet
      return false;
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncData(null);
  }
}

// Yeni nesil AsyncNotifierProvider kullanımı
final authProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});