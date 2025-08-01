class UserProfileResponse {
  final String message;
  final UserProfile user;
  final Staff staff;

  UserProfileResponse({
    required this.message,
    required this.user,
    required this.staff,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      message: json['message'] ?? '',
      user: UserProfile.fromJson(json['user']),
      staff: Staff.fromJson(json['staff']),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'user': user.toJson(),
    'staff': staff.toJson(),
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
    this.createdAt = '', // Default to empty string
    this.updatedAt = '', // Default to empty string
  });

  // Factory method to create a UserProfileModel from a JSON map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      provider: json['provider'] ?? '',
      providerId: json['provider_id'] ?? '',
      status: json['status'] ?? '',
      rememberToken: json['remember_token'] ?? '',
      gender: json['gander'] ?? '',
      dob: json['dob'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
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
class Staff {
  final int? id;
  final String? name;
  final String? email;
  final String? photo;
  final String? phoneNumber;
  final String? profilePicture;
  final String? provider;
  final String? providerId;
  final String? status;
  final String? rememberToken;
  final String? fcmToken;
  final String? gander;
  final String? dob;

  Staff({
    this.id,
    this.name,
    this.email,
    this.photo,
    this.phoneNumber,
    this.profilePicture,
    this.provider,
    this.providerId,
    this.status,
    this.rememberToken,
    this.fcmToken,
    this.gander,
    this.dob,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json['id']??0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    photo: json['photo'] ?? '',
    phoneNumber: json['phone_number'] ?? '',
    profilePicture: json['profile_picture'] ?? '',
    provider: json['provider']?? '',
    providerId: json['provider_id']?? '',
    status: json['status'] ?? '',
    rememberToken: json['remember_token']?? '',
    fcmToken: json['fcm_token']?? '',
    gander: json['gander']?? '',
    dob: json['dob']?? '',
  );

  Map<String, dynamic> toJson() => {
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
    'fcm_token': fcmToken,
    'gander': gander,
    'dob': dob,
  };
}
