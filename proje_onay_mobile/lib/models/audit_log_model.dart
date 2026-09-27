class AuditLogModel {
  final int id;
  final String entityType;
  final int entityId;
  final String action;
  final int? userId;
  final String timestamp;

  AuditLogModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.userId,
    required this.timestamp,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      entityType: json['entity_type'] ?? 'Bilinmiyor',
      entityId: json['entity_id'] is int ? json['entity_id'] : int.tryParse(json['entity_id']?.toString() ?? '0') ?? 0,
      action: json['action'] ?? 'Bilinmeyen İşlem',
      userId: json['user_id'] != null ? (json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString())) : null,
      // Tarih formatını daha okunaklı hale getiriyoruz
      timestamp: json['timestamp'] != null 
          ? json['timestamp'].toString().replaceAll('T', ' ').substring(0, 16) 
          : 'Tarih Yok',
    );
  }
}