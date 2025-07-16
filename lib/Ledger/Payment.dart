class Payment {
  final int? id;
  final int userId;
  final int sellerId;
  final String invoiceNo;
  final double amount;
  final String paymentDate;
  final String paymentType;
  final String paymentReference;
  final String paymentReason;

  Payment({
    this.id,
    required this.userId,
    required this.sellerId,
    required this.invoiceNo,
    required this.amount,
    required this.paymentDate,
    required this.paymentType,
    required this.paymentReference,
    required this.paymentReason,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'], // Optional field
      userId: json['user_id'],
      sellerId: json['seller_id'],
      invoiceNo: json['invoice_no'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: (json['payment_date']),
      paymentType: json['payment_type'],
      paymentReference: json['payment_reference'],
      paymentReason: json['payment_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'user_id': userId,
      'seller_id': sellerId,
      'invoice_no': invoiceNo,
      'amount': amount,
      'payment_date': paymentDate,
      'payment_type': paymentType,
      'payment_reference': paymentReference,
      'payment_reason': paymentReason,
    };

    if (id != null) {
      data['id'] = id!; // Include id only if it's not null
    }

    return data;
  }
}
