
import '../Api/ApiUtil/ApiParserUtils.dart';

class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: ApiParserUtils.parseInt(json['id']),
      name: ApiParserUtils.parseString(json['name']),
      phone: ApiParserUtils.parseString(json['phone']),
      email: ApiParserUtils.parseString(json['email']),
      address: ApiParserUtils.parseString(json['address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}
