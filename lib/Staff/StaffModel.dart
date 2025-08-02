class StaffModel {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? gander;
  final String? dob;
  final int parentId;
  final String status;
  final String address;
  final String gstin;
  final String license;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.gander,
    this.dob,
    required this.parentId,
    required this.status,
    required this.address,
    required this.gstin,
    required this.license,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id']??'',
      name: json['name']??'',
      email: json['email']??'',
      phoneNumber: json['phone_number']??'',
      gander: json['gander']??'',
      dob: json['dob']??'',
      parentId: json['parent_id']??'',
      status: json['status']??'',
      address: json['address']??'',
      gstin: json['gstin']??'',
      license: json['license']??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'gander': gander,
      'dob': dob,
      'parent_id': parentId,
      'status': status,
      'address': address,
      'gstin': gstin,
      'license': license,
    };
  }
}
