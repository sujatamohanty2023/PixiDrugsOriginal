class Report {
  final String stock;
  final String stockCount;
  final String purchases;
  final String purchasesCount;
  final String sales;
  final String salesCount;
  final String ledger;
  final String ledgerCount;
  final String expense;
  final String expenseCount;
  final String profit;
  final String customerDue;
  final String customerPurchasesCount;
  final String customerPaymentsCount;
  final String sellerDue;
  final String sellerSalesCount;
  final String sellerPaymentsCount;
  final String fromDate;
  final String toDate;

  Report({
    required this.stock,
    required this.stockCount,
    required this.purchases,
    required this.purchasesCount,
    required this.sales,
    required this.salesCount,
    required this.ledger,
    required this.ledgerCount,
    required this.expense,
    required this.expenseCount,
    required this.profit,
    required this.customerDue,
    required this.customerPurchasesCount,
    required this.customerPaymentsCount,
    required this.sellerDue,
    required this.sellerSalesCount,
    required this.sellerPaymentsCount,
    required this.fromDate,
    required this.toDate,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      stock: json['stock'],
      stockCount: json['stockCount'],
      purchases: json['purchases'],
      purchasesCount: json['purchasesCount'],
      sales: json['sales'],
      salesCount: json['salesCount'],
      ledger: json['ledger'],
      ledgerCount: json['ledgerCount'],
      expense: json['expense'],
      expenseCount: json['expenseCount'],
      profit: json['profit'],
      customerDue: json['customerDue'],
      customerPurchasesCount: json['customerPurchasesCount'],
      customerPaymentsCount: json['customerPaymentsCount'],
      sellerDue: json['sellerDue'],
      sellerSalesCount: json['sellerSalesCount'],
      sellerPaymentsCount: json['sellerPaymentsCount'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock': stock,
      'stockCount': stockCount,
      'purchases': purchases,
      'purchasesCount': purchasesCount,
      'sales': sales,
      'salesCount': salesCount,
      'ledger': ledger,
      'ledgerCount': ledgerCount,
      'expense': expense,
      'expenseCount': expenseCount,
      'profit': profit,
      'customerDue': customerDue,
      'customerPurchasesCount': customerPurchasesCount,
      'customerPaymentsCount': customerPaymentsCount,
      'sellerDue': sellerDue,
      'sellerSalesCount': sellerSalesCount,
      'sellerPaymentsCount': sellerPaymentsCount,
      'fromDate': fromDate,
      'toDate': toDate,
    };
  }
}
