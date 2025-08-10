import '../Api/ApiUtil/ApiParserUtils.dart';

class BannerModel {
  final int? id;
  final String? title;
  final String? slug;
  final String? photo;
  final String? description;
  final int? type;
  final String? status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.photo,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a BannerModel from a JSON map
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: ApiParserUtils.parseInt(json['id']),
      title: ApiParserUtils.parseString(json['title']),
      slug: ApiParserUtils.parseString(json['slug']),
      photo: ApiParserUtils.parseString(json['photo']),
      description: ApiParserUtils.parseString(json['description']),
      type: ApiParserUtils.parseInt(json['type']),
      status: ApiParserUtils.parseString(json['status']),
      createdAt: ApiParserUtils.parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: ApiParserUtils.parseDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  // Method to convert BannerModel instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'photo': photo,
      'description': description,
      'type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
