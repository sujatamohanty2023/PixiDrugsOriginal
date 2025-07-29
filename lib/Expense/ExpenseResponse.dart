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
      id: json['id'],
      storeId: json['store_id'],
      title: json['title'],
      amount: json['amount'],
      type: json['type'],
      expanseDate: json['expanse_date'],
      note: json['note'],
      createdAt: json['created_at'],
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
