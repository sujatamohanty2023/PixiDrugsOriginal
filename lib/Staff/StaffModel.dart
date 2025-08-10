import '../Api/ApiUtil/ApiParserUtils.dart';

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
      id: ApiParserUtils.parseInt(json['id']),
      name: ApiParserUtils.parseString(json['name']),
      email: ApiParserUtils.parseString(json['email']),
      phoneNumber: ApiParserUtils.parseString(json['phone_number']),
      gander: ApiParserUtils.parseString(json['gander']),
      dob: ApiParserUtils.parseString(json['dob']),
      parentId: ApiParserUtils.parseInt(json['parent_id']),
      status: ApiParserUtils.parseString(json['status']),
      address: ApiParserUtils.parseString(json['address']),
      gstin: ApiParserUtils.parseString(json['gstin']),
      license: ApiParserUtils.parseString(json['license']),
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
