import '../Api/ApiUtil/ApiParserUtils.dart';

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
  final int? id;
  final String name;
  final String email;
  final String emailVerifiedAt;
  final String photo;
  final String profilePicture;
  final String? role;
  final String provider;
  final String providerId;
  final String status;
  final String rememberToken;
  final String fcmToken;
  final String dob;
  final String gander;
  final int? parentId;
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
      id: ApiParserUtils.parseInt(json['id']),
      name: ApiParserUtils.parseString(json['name']),
      email: ApiParserUtils.parseString(json['email']),
      emailVerifiedAt: ApiParserUtils.parseString(json['email_verified_at']),
      photo: ApiParserUtils.parseString(json['photo']),
      profilePicture: ApiParserUtils.parseString(json['profile_picture']),
      role: ApiParserUtils.parseString(json['role']),
      provider: ApiParserUtils.parseString(json['provider']),
      providerId: ApiParserUtils.parseString(json['provider_id']),
      status: ApiParserUtils.parseString(json['status']),
      rememberToken: ApiParserUtils.parseString(json['remember_token']),
      fcmToken: ApiParserUtils.parseString(json['fcm_token']),
      dob: ApiParserUtils.parseString(json['dob']),
      gander: ApiParserUtils.parseString(json['gander']), // or gender
      parentId: ApiParserUtils.parseInt(json['parent_id']),
      createdAt: ApiParserUtils.parseString(json['created_at']),
      updatedAt: ApiParserUtils.parseString(json['updated_at']),
      phoneNumber: ApiParserUtils.parseString(json['phone_number']),
    );
  }
}
