import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_request_model.dart';
import '../repositories/payment_repository.dart';

class PaymentListNotifier extends AsyncNotifier<List<PaymentRequestModel>> {
  @override
  FutureOr<List<PaymentRequestModel>> build() async {
    return await _fetchPayments();
  }

  Future<List<PaymentRequestModel>> _fetchPayments() async {
    final repository = ref.read(paymentRepositoryProvider);
    return await repository.getPayments();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPayments());
  }
}

final paymentListProvider = AsyncNotifierProvider<PaymentListNotifier, List<PaymentRequestModel>>(() {
  return PaymentListNotifier();
});