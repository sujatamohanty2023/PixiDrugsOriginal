
import 'package:pixidrugs/constant/all.dart';

class OrderPlaceModel {
  List<InvoiceItem> cartItems;
  double totalPrice;
  double subTotal;
  double discountAmount;

  OrderPlaceModel({
    this.cartItems = const [],
    this.totalPrice = 0.0,
    this.subTotal = 0.0,
    this.discountAmount = 0.0,
  });

  List<Map<String, dynamic>> toApiFormatProductOrder() {
    return cartItems.map((item) {
      return {
        'product_id': item.id,
        'product_name': item.product,
        'price': item.mrp,
        'quantity': item.qty
      };
    }).toList();
  }

  factory OrderPlaceModel.fromJson(Map<String, dynamic> json) =>
      OrderPlaceModel(
        cartItems: (json['cartItems'] as List<dynamic>)
            .map((item) => InvoiceItem.fromJson(item))
            .toList(),
        totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
        subTotal: (json['subTotal'] ?? 0.0).toDouble(),
        discountAmount: (json['discountAmount'] ?? 0.0).toDouble()
      );
}
