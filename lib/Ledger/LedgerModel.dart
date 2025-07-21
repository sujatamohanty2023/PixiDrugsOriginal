class LedgerModel {
  final int partyId;
  final String sellerName;
  final String gstNo;
  final String phone;
  final String totalCredit;
  final String totalDebit;
  final String dueAmount;
  final List<History> history;

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
      partyId: json['party_id'] ?? 0,
      sellerName: json['seller_name'] ?? '',
      gstNo: json['gst_no'] ?? '',
      phone: json['phone'] ?? '',
      totalCredit: json['total_credit'] ?? '0.00',
      totalDebit: json['total_debit'] ?? '0.00',
      dueAmount: json['due_amount'] ?? '0.00',
      history: (json['history'] as List<dynamic>?)
          ?.map((item) => History.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class History {
  final int id;
  final int partyId;
  final String invoiceNo;
  final String paymentType;
  final String paymentReference;
  final String paymentReason;
  final String amount;
  final String paymentDate;
  final String createdAt;

  History({
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

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      partyId: json['party_id'],
      invoiceNo: json['invoice_no'] ?? '',
      paymentType: json['payment_type'] ?? '',
      paymentReference: json['payment_reference'] ?? '-',
      paymentReason: json['payment_reason'] ?? '',
      amount: json['amount'] ?? '0.00',
      paymentDate: json['payment_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
