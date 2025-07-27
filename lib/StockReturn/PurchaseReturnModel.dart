class PurchaseReturnModel {
  final int? id;
  final int? storeId;
  final int? invoicePurchaseId;
  final int? sellerId;
  final String returnDate;
  final String reason;
  final String totalAmount;
  final String? sellerName;
  final List<ReturnItemModel> items;

  PurchaseReturnModel({
    this.id,
    this.storeId,
    this.invoicePurchaseId,
    this.sellerId,
    required this.returnDate,
    required this.reason,
    required this.totalAmount,
    this.sellerName,
    required this.items,
  });

  factory PurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnModel(
      id: json['id'],
      storeId: json['store_id'],
      invoicePurchaseId: json['invoice_purchase_id'],
      sellerId: json['seller_id'],
      returnDate: json['return_date'],
      reason: json['reason'] ?? '',
      totalAmount: json['total_amount'].toString(),
      sellerName: json['seller_name'],
      items: (json['items'] as List).map((e) => ReturnItemModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      if (storeId != null) 'store_id': storeId,
      if (invoicePurchaseId != null) 'invoice_purchase_id': invoicePurchaseId,
      if (sellerId != null) 'seller_id': sellerId,
      'return_date': returnDate,
      'reason': reason,
      'total_amount': totalAmount,
      'items': items.map((e) => e.toJson()).toList(),
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
class ReturnItemModel {
  final int? id;
  final int productId;
  final String? productName;
  final String batchNo;
  final String expiry;
  final int quantity;
  final String rate;
  final String gstPercent;
  final String discountPercent;
  final String totalAmount;

  ReturnItemModel({
    this.id,
    required this.productId,
    this.productName,
    required this.batchNo,
    required this.expiry,
    required this.quantity,
    required this.rate,
    required this.gstPercent,
    required this.discountPercent,
    required this.totalAmount,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      batchNo: json['batch_no'],
      expiry: json['expiry'],
      quantity: json['quantity'],
      rate: json['rate'].toString(),
      gstPercent: json['gst_percent'].toString(),
      discountPercent: json['discount_percent'].toString(),
      totalAmount: json['total_amount'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'product_id': productId,
      'batch_no': batchNo,
      'expiry': expiry,
      'quantity': quantity,
      'rate': rate,
      'gst_percent': gstPercent,
      'discount_percent': discountPercent,
      'total_amount': totalAmount,
    };
    if (id != null) data['id'] = id!;
    if (productName != null) data['product_name'] = productName!;
    return data;
  }
}
