
import '../Api/ApiUtil/ApiParserUtils.dart';

class CustomerReturnsResponse {
  int id;
  int billingId;
  int customerId;
  int storeId;
  String returnDate;
  String totalAmount;
  String reason;
  String createdAt;
  String updatedAt;
  Customer customer;
  List<Item> items;

  CustomerReturnsResponse({
    required this.id,
    required this.billingId,
    required this.customerId,
    required this.storeId,
    required this.returnDate,
    required this.totalAmount,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.items,
  });

  factory CustomerReturnsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerReturnsResponse(
      id: ApiParserUtils.parseInt(json['id']),
      billingId: ApiParserUtils.parseInt(json['billing_id']),
      customerId: ApiParserUtils.parseInt(json['customer_id']),
      storeId: ApiParserUtils.parseInt(json['store_id']),
      returnDate: ApiParserUtils.parseString(json['return_date']),
      totalAmount: ApiParserUtils.parseString(json['total_amount']),
      reason: ApiParserUtils.parseString(json['reason']),
      createdAt: ApiParserUtils.parseString(json['created_at']),
      updatedAt: ApiParserUtils.parseString(json['updated_at']),
      customer: Customer.fromJson(json['customer'] ?? {}),
      items: (json['items'] as List? ?? [])
          .map((e) => Item.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billing_id': billingId,
      'customer_id': customerId,
      'store_id': storeId,
      'return_date': returnDate,
      'total_amount': totalAmount,
      'reason': reason,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'customer': customer.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class Customer {
  int id;
  String name;

  Customer({
    required this.id,
    required this.name,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: ApiParserUtils.parseInt(json['id']),
      name: ApiParserUtils.parseString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Item {
  int id;
  int customerReturnId;
  int productId;
  int quantity;
  String price;
  String gst;
  String discount;
  String batchNo;
  String expiry;
  String totalAmount;
  String createdAt;
  String updatedAt;
  Product product;

  Item({
    required this.id,
    required this.customerReturnId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.gst,
    required this.batchNo,
    required this.expiry,
    required this.discount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: ApiParserUtils.parseInt(json['id']),
      customerReturnId: ApiParserUtils.parseInt(json['customer_return_id']),
      productId: ApiParserUtils.parseInt(json['product_id']),
      quantity: ApiParserUtils.parseInt(json['quantity']),
      price: ApiParserUtils.parseString(json['price']),
      gst: ApiParserUtils.parseString(json['gst']),
      discount: ApiParserUtils.parseString(json['discount']),
      totalAmount: ApiParserUtils.parseString(json['total_amount']),
      batchNo: ApiParserUtils.parseString(json['batch_no']),
      expiry: ApiParserUtils.parseString(json['expiry']),
      createdAt: ApiParserUtils.parseString(json['created_at']),
      updatedAt: ApiParserUtils.parseString(json['updated_at']),
      product: Product.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_return_id': customerReturnId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'gst': gst,
      'discount': discount,
      'total_amount': totalAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product.toJson(),
    };
  }
}

class Product {
  int id;
  String productName;

  Product({
    required this.id,
    required this.productName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: ApiParserUtils.parseInt(json['id']),
      productName: ApiParserUtils.parseString(json['product_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
    };
  }
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: ApiParserUtils.parseString(json['url']),
      label: ApiParserUtils.parseString(json['label']),
      active: json['active'] == true || json['active'] == 1 || json['active'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}
