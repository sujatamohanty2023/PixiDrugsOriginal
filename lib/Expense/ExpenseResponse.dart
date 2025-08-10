import '../Api/ApiUtil/ApiParserUtils.dart';

class ExpenseResponse {
  final int id;
  final int storeId;
  final String title;
  final String amount;
  final String type;
  final String expanseDate;
  final String note;
  final String createdAt;

  ExpenseResponse({
    required this.id,
    required this.storeId,
    required this.title,
    required this.amount,
    required this.type,
    required this.expanseDate,
    required this.note,
    required this.createdAt,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      id: ApiParserUtils.parseInt(json['id']),
      storeId: ApiParserUtils.parseInt(json['store_id']),
      title: ApiParserUtils.parseString(json['title']),
      amount: ApiParserUtils.parseString(json['amount']),
      type: ApiParserUtils.parseString(json['type']),
      expanseDate: ApiParserUtils.parseString(json['expanse_date']),
      note: ApiParserUtils.parseString(json['note']),
      createdAt: ApiParserUtils.parseString(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'title': title,
      'amount': amount,
      'type': type,
      'expanse_date': expanseDate,
      'note': note,
      'created_at': createdAt,
    };
  }
}
