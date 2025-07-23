
import 'package:PixiDrugs/constant/all.dart';

class OrderPlaceModel {
  List<InvoiceItem> cartItems;
  String seller_id;
  String name;
  String phone;
  String email;
  String address;

  OrderPlaceModel({
    this.cartItems = const [],
    this.seller_id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  List<Map<String, dynamic>> toApiFormatProductOrder() {
    return cartItems.map((item) {
      return {
        'product_id': item.id,
        'product_name': item.product,
        'price': item.mrp,
        'quantity': item.qty,
        'discount': item.discount,
        'gst': item.gst
      };
    }).toList();
  }

  factory OrderPlaceModel.fromJson(Map<String, dynamic> json) =>
      OrderPlaceModel(
        cartItems: (json['cartItems'] as List<dynamic>)
            .map((item) => InvoiceItem.fromJson(item))
            .toList(),
          seller_id: json['seller_id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'] ?? '',
      );

  @override
  String toString() {
    return '''
OrderPlaceModel:
  Seller ID: $seller_id
  Name: $name
  Phone: $phone
  Email: $email
  Address: $address
  Cart Items:
${cartItems.map((item) => '''
     'product_id': ${item.id},
        'product_name': ${item.product},
        'price': ${item.mrp},
        'quantity': ${item.qty},
        'discount': ${item.discount},
        'gst': ${item.gst}
''').join()}
''';
  }
}
