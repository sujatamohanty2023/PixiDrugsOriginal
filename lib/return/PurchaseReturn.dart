class PurchaseReturn {
  final int? id;
  final int storeId;
  final int invoicePurchaseId;
  final int sellerId;
  final String returnDate;
  final double totalAmount;
  final String reason;
  final List<ReturnItem> items;

  PurchaseReturn({
    this.id,
    required this.storeId,
    required this.invoicePurchaseId,
    required this.sellerId,
    required this.returnDate,
    required this.totalAmount,
    required this.reason,
    required this.items,
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) {
    return PurchaseReturn(
      id: json['id'], // Optional field
      storeId: json['store_id'],
      invoicePurchaseId: json['invoice_purchase_id'],
      sellerId: json['seller_id'],
      returnDate: json['return_date'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      reason: json['reason'],
      items: (json['items'] as List<dynamic>)
          .map((item) => ReturnItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'store_id': storeId,
      'invoice_purchase_id': invoicePurchaseId,
      'seller_id': sellerId,
      'return_date': returnDate,
      'total_amount': totalAmount,
      'reason': reason,
      'items': items.map((item) => item.toJson()).toList(),
    };

    if (id != null) {
      data['id'] = id!;
    }

    return data;
  }

}

class ReturnItem {
  final int productId;
  final String batchNo;
  final String expiry;
  final int quantity;
  final double rate;
  final double gstPercent;
  final double discountPercent;
  final double totalAmount;

  ReturnItem({
    required this.productId,
    required this.batchNo,
    required this.expiry,
    required this.quantity,
    required this.rate,
    required this.gstPercent,
    required this.discountPercent,
    required this.totalAmount,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      productId: json['product_id'],
      batchNo: json['batch_no'],
      expiry: json['expiry'],
      quantity: json['quantity'],
      rate: (json['rate'] as num).toDouble(),
      gstPercent: (json['gst_percent'] as num).toDouble(),
      discountPercent: (json['discount_percent'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'batch_no': batchNo,
      'expiry': expiry,
      'quantity': quantity,
      'rate': rate,
      'gst_percent': gstPercent,
      'discount_percent': discountPercent,
      'total_amount': totalAmount,
    };
  }
}
