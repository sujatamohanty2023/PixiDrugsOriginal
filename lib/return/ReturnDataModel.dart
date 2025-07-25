class ReturnDataModel {
  final List<ReturnData> data;
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int total;

  ReturnDataModel({
    required this.data,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });

  factory ReturnDataModel.fromJson(Map<String, dynamic> json) {
    return ReturnDataModel(
      data: (json['data'] as List).map((e) => ReturnData.fromJson(e)).toList(),
      currentPage: json['current_page'],
      perPage: json['per_page'],
      lastPage: json['last_page'],
      total: json['total'],
    );
  }
}

class ReturnData {
  final int id;
  final String returnDate;
  final String reason;
  final String totalAmount;
  final List<ReturnItem> items;

  ReturnData({
    required this.id,
    required this.returnDate,
    required this.reason,
    required this.totalAmount,
    required this.items,
  });

  factory ReturnData.fromJson(Map<String, dynamic> json) {
    return ReturnData(
      id: json['id'],
      returnDate: json['return_date'],
      reason: json['reason'],
      totalAmount: json['total_amount'],
      items: (json['items'] as List).map((e) => ReturnItem.fromJson(e)).toList(),
    );
  }
}

class ReturnItem {
  final int id;
  final int productId;
  final String? productName;
  final String batchNo;
  final String expiry;
  final int quantity;
  final String rate;
  final String gstPercent;
  final String discountPercent;
  final String totalAmount;

  ReturnItem({
    required this.id,
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

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      batchNo: json['batch_no'],
      expiry: json['expiry'],
      quantity: json['quantity'],
      rate: json['rate'],
      gstPercent: json['gst_percent'],
      discountPercent: json['discount_percent'],
      totalAmount: json['total_amount'],
    );
  }
}
