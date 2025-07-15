
class LedgerModel {
  final int partyId;
  final String sellerName;
  final String gstNo;
  final String phone;
  final String totalCredit;
  final String totalDebit;
  final String dueAmount;
  final List<PaymentHistory> history;

  LedgerModel({
  required this.partyId,
  required this.sellerName,
  required this.gstNo,
  required this.phone,
  required this.totalCredit,
  required this.totalDebit,
  required this.dueAmount,
  required this.history,
  });

  factory LedgerModel.fromJson(Map<String, dynamic> json) {
  return LedgerModel(
  partyId: json['party_id'],
  sellerName: json['seller_name'],
  gstNo: json['gst_no'],
  phone: json['phone'],
  totalCredit: json['total_credit'],
  totalDebit: json['total_debit'],
  dueAmount: json['due_amount'],
  history: List<PaymentHistory>.from(
  json['history'].map((x) => PaymentHistory.fromJson(x)),
  ),
  );
  }
  }

  class PaymentHistory {
  final int id;
  final int partyId;
  final String invoiceNo;
  final String paymentType;
  final String paymentReference;
  final String paymentReason;
  final String amount;
  final String paymentDate;
  final String createdAt;

  PaymentHistory({
  required this.id,
  required this.partyId,
  required this.invoiceNo,
  required this.paymentType,
  required this.paymentReference,
  required this.paymentReason,
  required this.amount,
  required this.paymentDate,
  required this.createdAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
  return PaymentHistory(
  id: json['id'],
  partyId: json['party_id'],
  invoiceNo: json['invoice_no'],
  paymentType: json['payment_type'],
  paymentReference: json['payment_reference'],
  paymentReason: json['payment_reason'],
  amount: json['amount'],
  paymentDate: json['payment_date'],
  createdAt: json['created_at'],
  );
  }
  }
