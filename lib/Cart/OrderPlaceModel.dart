
import 'package:PixiDrugs/constant/all.dart';

class OrderPlaceModel {
  List<InvoiceItem> cartItems;
  String seller_id;
  String name;
  String phone;
  String email;
  String address;
  String payment_type;

  OrderPlaceModel({
    this.cartItems = const [],
    this.seller_id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.payment_type = '',
  });

  List<Map<String, dynamic>> toApiFormatProductOrder() {
    return cartItems.map((item) {
      return {
        'product_id': item.id,
        'product_name': item.product,
        'price': item.unitType==UnitType.Tablet?item.unitMrp : item.mrp,
        'quantity': item.qty,
        'discount': item.discountSale,
        'gst': item.gst,
        'unit_type': item.unitType.name
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
        payment_type: json['payment_type'] ?? '',
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
  PaymentType: $payment_type
  Cart Items:
${cartItems.map((item) => '''
     'product_id': ${item.id},
        'product_name': ${item.product},
        'price': ${item.unitMrp},
        'quantity': ${item.qty},
        'discount': ${item.discount},
        'gst': ${item.gst}
        'unit_type': ${item.unitType.name},
''').join()}
''';
  }
}