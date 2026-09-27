class DocumentModel {
  final String id;
  final String filePath;
  final String documentType;
  final bool isSigned;

  DocumentModel({
    required this.id,
    required this.filePath,
    required this.documentType,
    required this.isSigned,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      filePath: json['file_path'] ?? '',
      documentType: json['document_type'] ?? '',
      isSigned: json['is_signed'] ?? false,
    );
  }
}