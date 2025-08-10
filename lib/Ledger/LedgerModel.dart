import '../Api/ApiUtil/ApiParserUtils.dart';

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
      partyId: ApiParserUtils.parseInt(json['party_id']),
      sellerName: ApiParserUtils.parseString(json['seller_name']),
      gstNo: ApiParserUtils.parseString(json['gst_no']),
      phone: ApiParserUtils.parseString(json['phone']),
      totalCredit: ApiParserUtils.parseString(json['total_credit'], defaultValue: '0.00'),
      totalDebit: ApiParserUtils.parseString(json['total_debit'], defaultValue: '0.00'),
      dueAmount: ApiParserUtils.parseString(json['due_amount'], defaultValue: '0.00'),
      history: ApiParserUtils.parseList(json['history'], (e) => History.fromJson(e)),
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
      id: ApiParserUtils.parseInt(json['id']),
      partyId: ApiParserUtils.parseInt(json['party_id']),
      invoiceNo: ApiParserUtils.parseString(json['invoice_no']),
      paymentType: ApiParserUtils.parseString(json['payment_type']),
      paymentReference: ApiParserUtils.parseString(json['payment_reference'], defaultValue: '-'),
      paymentReason: ApiParserUtils.parseString(json['payment_reason']),
      amount: ApiParserUtils.parseString(json['amount'], defaultValue: '0.00'),
      paymentDate: ApiParserUtils.parseString(json['payment_date']),
      createdAt: ApiParserUtils.parseString(json['created_at']),
    );
  }
}
