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
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num).toDouble(),
      customer: Customer.fromJson(json['customer']),
      items: (json['items'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    );
  }

  // ✅ Use this when your API returns "billing_id", etc.
  static SaleModel fromBillingResponse(Map<String, dynamic> json) {
    return SaleModel(
      invoiceNo: json['billing_id'] ?? 0,
      date: '${DateTime.now()}', // Default, as date is not present
      totalAmount: json['total_amount'],
      profit: 0.0, // Not in the response, default to 0.0
      customer: Customer.fromJson(json['customer']),
      items: (json['items'] as List).map((item) {
        return SaleItem(
          productId: int.tryParse(item['product_id'].toString()) ?? 0,
          productName: item['product_name'] ?? '',
          price: double.tryParse(item['price'].toString()) ?? 0.0,
          quantity: int.tryParse(item['quantity'].toString()) ?? 0,
          mrp: double.tryParse(item['mrp'].toString()) ?? 0.0,
          discount: double.tryParse(item['discount'].toString()) ?? 0.0,
          itemProfit: 0.0, // Optional: calculate as mrp - price
        );
      }).toList(),
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;

  Customer({required this.id, required this.name, required this.email,required this.phone,required this.address});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email']??'',
      phone: json['phone'],
      address: json['address'],
    );
  }
}

class SaleItem {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double mrp;
  final double discount;
  final double itemProfit;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.mrp,
    required this.discount,
    this.itemProfit=0.0,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      mrp: (json['mrp'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      itemProfit: (json['item_profit'] as num).toDouble(),
    );
  }
}
