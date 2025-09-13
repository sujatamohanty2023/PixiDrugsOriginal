import '../Api/ApiUtil/ApiParserUtils.dart';

class PurchaseReturnModel {
  final int? id;
  final int? storeId;
  final int? invoicePurchaseId;
  final int? sellerId;
  final String returnDate;
  final String reason;
  final String totalAmount;
  final String? sellerName;
  final String? phone;
  final String? address;
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
    required this.phone,
    required this.address,
  });

  factory PurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnModel(
      id:ApiParserUtils.parseInt(json['id']),
      storeId: ApiParserUtils.parseInt(json['store_id']),
      invoicePurchaseId: ApiParserUtils.parseInt(json['invoice_purchase_id']),
      sellerId: ApiParserUtils.parseInt(json['seller_id']),
      returnDate: ApiParserUtils.parseString(json['return_date']),
      reason: ApiParserUtils.parseString(json['reason']),
      totalAmount: ApiParserUtils.parseString(json['total_amount']),
      sellerName: ApiParserUtils.parseString(json['seller_name'], defaultValue: 'Unknown'),
      phone: ApiParserUtils.parseString(json['phone'], defaultValue: 'Unknown'),
      address: ApiParserUtils.parseString(json['address'], defaultValue: 'Unknown'),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ReturnItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'store_id': storeId,
      'invoice_purchase_id': invoicePurchaseId,
      'seller_id': sellerId,
      'return_date': returnDate,
      'reason': reason,
      'total_amount': totalAmount,
      'items': items.map((e) => e.toJson()).toList(),
    };
    if (id != null && id!=0) data['id'] = id;
    return data;
  }
  @override
  String toString() {
    return ''
        'id: $id, '
        'storeId: $storeId, '
        'invoicePurchaseId: $invoicePurchaseId, '
        'sellerId: $sellerId, '
        'returnDate: $returnDate, '
        'reason: $reason, '
        'totalAmount: $totalAmount, '
        'sellerName: $sellerName, '
        'items: $items'
        ')';
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
  final String invoiceNo;

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
    required this.invoiceNo,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      id: ApiParserUtils.parseInt(json['id']),
      productId: ApiParserUtils.parseInt(json['product_id']),
      productName: ApiParserUtils.parseString(json['product_name']),
      batchNo: ApiParserUtils.parseString(json['batch_no']),
      expiry: ApiParserUtils.parseString(json['expiry']),
      quantity: ApiParserUtils.parseInt(json['quantity']),
      rate: ApiParserUtils.parseString(json['rate']),
      gstPercent: ApiParserUtils.parseString(json['gst_percent']),
      discountPercent: ApiParserUtils.parseString(json['discount_percent']),
      totalAmount: ApiParserUtils.parseString(json['total_amount']),
      invoiceNo: ApiParserUtils.parseString(json['invoice_no']),
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
      'invoice_no': invoiceNo,
    };
    if (id != null && id !=0) data['id'] = id!;
    return data;
  }
  @override
  String toString() {
    return ''
        'id: $id, '
        'productId: $productId, '
        'productName: $productName, '
        'batchNo: $batchNo, '
        'expiry: $expiry, '
        'quantity: $quantity, '
        'rate: $rate, '
        'gstPercent: $gstPercent, '
        'discountPercent: $discountPercent, '
        'totalAmount: $totalAmount'
        'invoice_no: $invoiceNo'
        ')';
  }

}
