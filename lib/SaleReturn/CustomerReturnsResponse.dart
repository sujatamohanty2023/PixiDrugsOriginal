
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
      id: json['id'],
      billingId: json['billing_id'],
      customerId: json['customer_id'],
      storeId: json['store_id'],
      returnDate: json['return_date'],
      totalAmount: json['total_amount'],
      reason: json['reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      customer: Customer.fromJson(json['customer']),
      items: (json['items'] as List).map((e) => Item.fromJson(e)).toList(),
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
      id: json['id'],
      name: json['name'],
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
    required this.discount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      customerReturnId: json['customer_return_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price'],
      gst: json['gst'],
      discount: json['discount'],
      totalAmount: json['total_amount'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      product: Product.fromJson(json['product']),
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
      id: json['id'],
      productName: json['product_name'],
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
      url: json['url'],
      label: json['label'],
      active: json['active'],
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
