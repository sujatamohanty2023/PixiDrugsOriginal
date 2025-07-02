class LoginModel {
  final String message;
  final UserModel? user;
  final String accessToken;

  LoginModel({
    required this.message,
    required this.user,
    required this.accessToken,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user?.toJson(),
      'access_token': accessToken,
    };
  }
}

class UserModel {
  final String name;
  final String role;
  final int id;

  UserModel({
    required this.name,
    required this.role,
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      role: json['role'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'id': id,
    };
  }
}
