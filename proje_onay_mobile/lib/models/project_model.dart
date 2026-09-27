class ProjectModel {
  final int id;
  final String title;
  final String? projectType;
  final String? location;
  final double? powerCapacity;
  final String? description;
  final String date;
  final String status;

  ProjectModel({
    required this.id,
    required this.title,
    this.projectType,
    this.location,
    this.powerCapacity,
    this.description,
    required this.date,
    required this.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? 'İsimsiz Proje',
      projectType: json['project_type'] ?? 'Belirtilmemiş',
      location: json['location'] ?? 'Belirtilmemiş',
      powerCapacity: (json['power_capacity'] as num?)?.toDouble(),
      description: json['description'],
      // API'den gelen ISO tarihini basitçe bölüp alıyoruz
      date: json['created_at'] != null ? json['created_at'].toString().split('T').first : 'Tarih Yok',
      status: json['status'] ?? 'taslak',
    );
  }
}