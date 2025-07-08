class SaleModel {
  final int invoiceNo;
  final String date;
  final double totalAmount;
  final double profit;
  final Customer customer;
  final List<SaleItem> items;

  SaleModel({
    required this.invoiceNo,
    required this.date,
    required this.totalAmount,
    required this.profit,
    required this.customer,
    required this.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      invoiceNo: json['invoice_no'],
      date: json['date'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      customer: Customer.fromJson(json['customer']),
      items: (json['items'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class SaleItem {
  final String productName;
  final double price;
  final int quantity;
  final double mrp;
  final double discount;
  final double itemProfit;

  SaleItem({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.mrp,
    required this.discount,
    required this.itemProfit,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      mrp: (json['mrp'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      itemProfit: (json['item_profit'] as num).toDouble(),
    );
  }
}
