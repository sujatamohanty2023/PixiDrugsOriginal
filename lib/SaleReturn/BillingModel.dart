class Billing {
  final int billingId;
  final String billingDate;
  final String totalAmount;
  final int customerId;
  final int sellerId;
  final List<Item> items;

  Billing({
    required this.billingId,
    required this.billingDate,
    required this.totalAmount,
    required this.customerId,
    required this.sellerId,
    required this.items,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      billingId: json['billing_id'],
      billingDate: json['billing_date'],
      totalAmount: json['total_amount'],
      customerId: json['customer_id'],
      sellerId: json['seller_id'],
      items: List<Item>.from(json['items'].map((item) => Item.fromJson(item))),
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
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      price: json['price'],
      subtotal: json['subtotal'],
      discount: json['discount'],
      gst: json['gst'],
      total: json['total'],
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
