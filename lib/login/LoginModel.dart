class LoginResponse {
  final bool success;
  final String message;
  final bool? isNewUser;
  final UserModel? user;
  final String? accessToken;

  LoginResponse({
    required this.success,
    required this.message,
    this.isNewUser,
    this.user,
    this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isNewUser: json['is_new_user'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      accessToken: json['access_token'],
    );
  }
}
class UserModel {
  final int id;
  final String name;
  final String email;
  final String emailVerifiedAt;
  final String photo;
  final String profilePicture;
  final String role;
  final String provider;
  final String providerId;
  final String status;
  final String rememberToken;
  final String fcmToken;
  final String dob;
  final String gander;
  final int parentId;
  final String createdAt;
  final String updatedAt;
  final String phoneNumber;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.photo,
    required this.profilePicture,
    required this.role,
    required this.provider,
    required this.providerId,
    required this.status,
    required this.rememberToken,
    required this.fcmToken,
    required this.dob,
    required this.gander,
    required this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
      role: json['role'] ?? '',
      provider: json['provider']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      rememberToken: json['remember_token']?.toString() ?? '',
      fcmToken: json['fcm_token']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      // ✅ Default if null
      gander: json['gander']?.toString() ?? '',
      // ✅ Default if null
      parentId: json['parent_id'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
    );
  }
}
