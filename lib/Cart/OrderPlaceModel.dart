
import '../../constant/all.dart';

class OrderPlaceModel {
  List<InvoiceItem> cartItems;
  String seller_id;
  String name;
  String phone;
  String email;
  String address;
  String payment_type;
  String amount;
  String title;
  String note;

  OrderPlaceModel({
    this.cartItems = const [],
    this.seller_id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.payment_type = '',
    this.amount = '',
    this.title = '',
    this.note = '',
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

  factory OrderPlaceModel.fromJson(Map<String, dynamic> json) {
    final cartItemsList = json['cartItems'] as List<dynamic>? ?? [];
    return OrderPlaceModel(
      cartItems: cartItemsList
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>? ?? {}))
          .toList(),
      seller_id: json['seller_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      payment_type: json['payment_type']?.toString() ?? '',
    );
  }

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