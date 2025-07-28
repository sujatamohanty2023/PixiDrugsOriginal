class SaleReturnRequest {
  final int? id;
  final int storeId;
  final int billingId;
  final int customerId;
  final String returnDate;
  final double totalAmount;
  final String reason;
  final List<ReturnedItem> items;

  SaleReturnRequest({
    this.id,
    required this.storeId,
    required this.billingId,
    required this.customerId,
    required this.returnDate,
    required this.totalAmount,
    required this.reason,
    required this.items,
  });

  factory SaleReturnRequest.fromJson(Map<String, dynamic> json) {
    return SaleReturnRequest(
      id: json['id'],
      storeId: json['store_id'],
      billingId: json['billing_id'],
      customerId: json['customer_id'],
      returnDate: json['return_date'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      reason: json['reason'],
      items: List<ReturnedItem>.from(
        json['items'].map((item) => ReturnedItem.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'store_id': storeId,
      'billing_id': billingId,
      'customer_id': customerId,
      'return_date': returnDate,
      'total_amount': totalAmount,
      'reason': reason,
      'items': items.map((item) => item.toJson()).toList(),
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}

class ReturnedItem {
  final int productId;
  final int quantity;
  final double price;
  final double discount;
  final double gst;
  final double totalAmount;

  ReturnedItem({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.gst,
    required this.totalAmount,
  });

  factory ReturnedItem.fromJson(Map<String, dynamic> json) {
    return ReturnedItem(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'gst': gst,
      'total_amount': totalAmount,
    };
  }
}
