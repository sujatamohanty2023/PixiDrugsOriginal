
class Seller {
  final int id;
  final String sellerName;
  final String gstNo;
  final String phone;
  final String address;

  Seller({
    required this.id,
    required this.sellerName,
    required this.gstNo,
    required this.phone,
    required this.address,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      sellerName: json['seller_name'],
      gstNo: json['gst_no'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_name': sellerName,
      'gst_no': gstNo,
      'phone': phone,
      'address': address,
    };
  }
}
