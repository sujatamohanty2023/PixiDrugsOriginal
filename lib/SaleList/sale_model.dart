import '../Api/ApiUtil/ApiParserUtils.dart';

class SaleModel {
  final int invoiceNo;
  final SoldBy soldBy;
  final String paymentType;
  final String date;
  final double totalAmount;
  final double profit;
  final Customer customer;
  final List<Expanses> expanses;
  final List<SaleItem> items;

  SaleModel({
    required this.soldBy,
    required this.invoiceNo,
    required this.paymentType,
    required this.date,
    required this.totalAmount,
    required this.profit,
    required this.customer,
    required this.expanses,
    required this.items,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SaleModel &&
              runtimeType == other.runtimeType &&
              invoiceNo == other.invoiceNo;

  @override
  int get hashCode => invoiceNo.hashCode;

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      soldBy: SoldBy.fromJson(json['sold_by']),
      invoiceNo: ApiParserUtils.parseInt(json['invoice_no']),
      paymentType: ApiParserUtils.parseString(json['payment_type']),
      date: ApiParserUtils.parseString(json['date']),
      totalAmount: ApiParserUtils.parseDouble(json['total_amount']),
      profit: ApiParserUtils.parseDouble(json['profit']),
      customer: Customer.fromJson(json['customer']),
      expanses: ApiParserUtils.parseList(json['expanses'], (e) => Expanses.fromJson(e)),
      items: ApiParserUtils.parseList(json['items'], (e) => SaleItem.fromJson(e)),
    );
  }

  // ✅ Use this when your API returns "billing_id", etc.
  static SaleModel fromBillingResponse(Map<String, dynamic> json) {
    return SaleModel(
    invoiceNo: ApiParserUtils.parseInt(json['billing_id']),
   soldBy: SoldBy.fromJson(json['sold_by']),
    paymentType: ApiParserUtils.parseString(json['payment_type']),
    date: DateTime.now().toString(),
    totalAmount: ApiParserUtils.parseDouble(json['total_amount']),
    profit: 0.0,
    customer: Customer.fromJson(json['customer']),
    expanses: [],
    items: ApiParserUtils.parseList(json['items'], (item) {
    return SaleItem(
    productId: ApiParserUtils.parseInt(item['product_id']),
    productName: ApiParserUtils.parseString(item['product_name']),
    price: ApiParserUtils.parseDouble(item['price']),
    quantity: ApiParserUtils.parseInt(item['quantity']),
    mrp: ApiParserUtils.parseDouble(item['mrp']),
    discount: ApiParserUtils.parseDouble(item['discount']),
      unitType: ApiParserUtils.parseString(item['unitType']),
    itemProfit: 0.0,
    );
      }).toList(),
    );
  }
}
class SoldBy {
  final int id;
  final String name;
  final String phone;

  SoldBy({required this.id, required this.name,required this.phone});

  factory SoldBy.fromJson(Map<String, dynamic> json) {
    return SoldBy(
      id: ApiParserUtils.parseInt(json['id']),
      name: ApiParserUtils.parseString(json['name']),
      phone: ApiParserUtils.parseString(json['phone']),
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
      id: ApiParserUtils.parseInt(json['id']),
      name: ApiParserUtils.parseString(json['name']),
      email: ApiParserUtils.parseString(json['email']),
      phone: ApiParserUtils.parseString(json['phone']),
      address: ApiParserUtils.parseString(json['address']),
    );
  }
}

class Expanses {
  final int id;
  final String title;
  final String note;
  final double amount;
  final String date;

  Expanses({required this.id, required this.title, required this.note,required this.amount,required this.date});

  factory Expanses.fromJson(Map<String, dynamic> json) {
    return Expanses(
      id: ApiParserUtils.parseInt(json['id']),
      title: ApiParserUtils.parseString(json['title']),
      note: ApiParserUtils.parseString(json['note']),
      amount: ApiParserUtils.parseDouble(json['amount']),
      date: ApiParserUtils.parseString(json['date']),
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
  final String unitType;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.mrp,
    required this.discount,
    required this.unitType,
    this.itemProfit=0.0,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: ApiParserUtils.parseInt(json['product_id']),
      productName: ApiParserUtils.parseString(json['product_name']),
      price: ApiParserUtils.parseDouble(json['price']),
      quantity: ApiParserUtils.parseInt(json['quantity']),
      mrp: ApiParserUtils.parseDouble(json['mrp']),
      discount: ApiParserUtils.parseDouble(json['discount']),
      itemProfit: ApiParserUtils.parseDouble(json['item_profit']),
      unitType: ApiParserUtils.parseString(json['unit_type']),
    );
  }
  @override
  String toString() {
    return 'SaleItem(productId: $productId, productName: $productName, price: $price, '
        'quantity: $quantity, mrp: $mrp, discount: $discount, itemProfit: $itemProfit,unit_type: $unitType)';
  }
}
