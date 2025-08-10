import '../Api/ApiUtil/ApiParserUtils.dart';

class UserProfileResponse {
  final String message;
  final UserProfile user;

  UserProfileResponse({
    required this.message,
    required this.user,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      message: json['message'] ?? '',
      user: UserProfile.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'user': user.toJson(),
  };
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String photo;
  final String phoneNumber;
  final String profilePicture;
  final String provider;
  final String providerId;
  final String status;
  final String rememberToken;
  final String gender;
  final String dob;
  final String ownerName;
  final String address;
  final String gstin;
  final String license;
  final String createdAt;
  final String updatedAt;

  // Default constructor with default values
  UserProfile({
    this.id = '', // Default to empty string
    this.name = '', // Default to empty string
    this.email = '', // Default to empty string
    this.photo = '',
    this.phoneNumber = '',
    this.profilePicture = '',
    this.provider = '',
    this.providerId = '',
    this.status = 'active', // Default to 'active'
    this.rememberToken = '',
    this.gender = '',
    this.dob = '',
    this.ownerName = '',
    this.address = '',
    this.gstin = '',
    this.license = '',
    this.createdAt = '', // Default to empty string
    this.updatedAt = '', // Default to empty string
  });

  // Factory method to create a UserProfileModel from a JSON map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: ApiParserUtils.parseString(json['id']),
      name: ApiParserUtils.parseString(json['name']),
      email: ApiParserUtils.parseString(json['email']),
      photo: ApiParserUtils.parseString(json['photo']),
      phoneNumber: ApiParserUtils.parseString(json['phone_number']),
      profilePicture: ApiParserUtils.parseString(json['profile_picture']),
      provider: ApiParserUtils.parseString(json['provider']),
      providerId: ApiParserUtils.parseString(json['provider_id']),
      status: ApiParserUtils.parseString(json['status']),
      rememberToken: ApiParserUtils.parseString(json['remember_token']),
      gender: ApiParserUtils.parseString(json['gander']), // ✅ fixed
      dob: ApiParserUtils.parseString(json['dob']),
      ownerName: ApiParserUtils.parseString(json['owner_name']),
      address: ApiParserUtils.parseString(json['address']),
      gstin: ApiParserUtils.parseString(json['gstin']),
      license: ApiParserUtils.parseString(json['license']),
      createdAt: ApiParserUtils.parseString(json['created_at']),
      updatedAt: ApiParserUtils.parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo': photo,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'provider': provider,
      'provider_id': providerId,
      'status': status,
      'remember_token': rememberToken,
      'gander': gender,
      'dob': dob,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
