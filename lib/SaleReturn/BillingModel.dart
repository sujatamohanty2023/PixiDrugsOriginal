import '../Api/ApiUtil/ApiParserUtils.dart';

class Billing {
  final int billingId;
  final String billingDate;
  final String totalAmount;
  final int customerId;
  final String customerName;
  final String customerMobile;
  final int sellerId;
  final List<Item> items;

  Billing({
    required this.billingId,
    required this.billingDate,
    required this.totalAmount,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.sellerId,
    required this.items,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    return Billing(
      billingId: ApiParserUtils.parseInt(json['billing_id']),
      billingDate: json['billing_date'] ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      customerId: ApiParserUtils.parseInt(json['customer_id']),
      customerName: json['customer_name'] ?? '',
      customerMobile: json['customer_mobile'] ?? '',
      sellerId: ApiParserUtils.parseInt(json['seller_id']),
      items: itemsJson.map((e) => Item.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billing_id': billingId,
      'billing_date': billingDate,
      'total_amount': totalAmount,
      'customer_id': customerId,
      'seller_id': sellerId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class Item {
  final int productId;
  final String productName;
  final int quantity;
  final String price;
  final String subtotal;
  final String discount;
  final String gst;
  final String total;

  bool isSelected;
  int returnQty;

  Item({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.discount,
    required this.gst,
    required this.total,
    this.isSelected = false,
    this.returnQty = 0,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      productId: ApiParserUtils.parseInt(json['product_id']),
      productName: json['product_name'] ?? '',
      quantity: ApiParserUtils.parseInt(json['quantity']),
      price: json['price']?.toString() ?? '0.00',
      subtotal: json['subtotal']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      gst: json['gst']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'discount': discount,
      'gst': gst,
      'total': total,
    };
  }
}
