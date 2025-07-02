class BannerModel {
  final int id;
  final String title;
  final String slug;
  final String photo;
  final String description;
  final int type;
  final String status;
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
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      photo: json['photo'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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

class BannerResponse {
  final int currentPage;
  final List<BannerModel> banners;
  final int total;
  final int lastPage;

  BannerResponse({
    required this.currentPage,
    required this.banners,
    required this.total,
    required this.lastPage,
  });

  // Factory method to create a BannerResponse from a JSON map
  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      currentPage: json['current_page'],
      banners: List<BannerModel>.from(
        json['data'].map((item) => BannerModel.fromJson(item)),
      ),
      total: json['total'],
      lastPage: json['last_page'],
    );
  }

  // Method to convert BannerResponse instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': banners.map((banner) => banner.toJson()).toList(),
      'total': total,
      'last_page': lastPage,
    };
  }
}
