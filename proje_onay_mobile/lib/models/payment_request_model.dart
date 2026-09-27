class PaymentRequestModel {
  final int id;
  final int projectId;
  final double amount;
  final String description;
  final String status;
  final String createdAt;

  PaymentRequestModel({
    required this.id,
    required this.projectId,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      projectId: json['project_id'] is int ? json['project_id'] : int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      // Hakediş tutarı (Numeric) API'den int, double veya string olarak gelebilir
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      status: json['status'] ?? 'talep_edildi',
      // API'den gelen ISO tarihini (örn: 2026-08-24T12:00:00) sadece gün bazında alıyoruz
      createdAt: json['created_at'] != null ? json['created_at'].toString().split('T').first : 'Tarih Yok',
    );
  }
}