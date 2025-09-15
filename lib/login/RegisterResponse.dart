

class RegisterResponse {
  final bool status;
  final String message;

  RegisterResponse({
    required this.status,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? ''
    );
  }
}
class RegisterModel {
  final String name;
  final String email;
  final String phoneNumber;
  final String gander;
  final String dob;
  final String password;
  final String address;
  final String country;
  final String state;
  final String city;
  final String pincode;
  final String ownerName;
  final String gstin;
  final String license;

  RegisterModel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.gander,
    required this.dob,
    required this.password,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.pincode,
    required this.ownerName,
    required this.gstin,
    required this.license,
  });

  // Convert to Map (for API POST body)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'gander': gander,
      'dob': dob,
      'password': password,
      'address': address,
      'country': country,
      'state': state,
      'city': city,
      'pincode': pincode,
      'owner_name': ownerName,
      'gstin': gstin,
      'license': license,
    };
  }

  // Create model from Map (optional, for parsing response)
  factory RegisterModel.fromMap(Map<String, dynamic> map) {
    return RegisterModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      gander: map['gander'] ?? '',
      dob: map['dob'] ?? '',
      password: map['password'] ?? '',
      address: map['address'] ?? '',
      country: map['country'] ?? '',
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '',
      ownerName: map['owner_name'] ?? '',
      gstin: map['gstin'] ?? '',
      license: map['license'] ?? '',
    );
  }
}
