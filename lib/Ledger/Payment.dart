import '../Api/ApiUtil/ApiParserUtils.dart';

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
      id:ApiParserUtils.parseInt(json['id']), // Optional field
      userId: ApiParserUtils.parseInt(json['user_id']),
      sellerId: ApiParserUtils.parseInt(json['seller_id']),
      invoiceNo: ApiParserUtils.parseString(json['invoice_no']),
      amount: ApiParserUtils.parseDouble(json['amount']),
      paymentDate:  ApiParserUtils.parseString(json['payment_date']),
      paymentType:  ApiParserUtils.parseString(json['payment_type']),
      paymentReference:  ApiParserUtils.parseString(json['payment_reference']),
      paymentReason:  ApiParserUtils.parseString(json['payment_reason']),
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
  @override
  String toString() {
    return 'Payment('
        'id: $id, '
        'userId: $userId, '
        'sellerId: $sellerId, '
        'invoiceNo: $invoiceNo, '
        'amount: $amount, '
        'paymentDate: $paymentDate, '
        'paymentType: $paymentType, '
        'paymentReference: $paymentReference, '
        'paymentReason: $paymentReason'
        ')';
  }
}
