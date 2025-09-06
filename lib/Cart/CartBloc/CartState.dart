import 'package:PixiDrugs/constant/all.dart';

class CartState {
  final List<InvoiceItem> cartItems;

  CartState({
    required this.cartItems,
  });

  CartState copyWith({
    List<InvoiceItem>? cartItems,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
    );
  }
}

class CartInitial extends CartState {
  CartInitial()
      : super(cartItems: []);
}

class CartLoaded extends CartState {
  final double totalPrice;
  final double subTotal;
  final double discountAmount;
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  CartLoaded({
    required List<InvoiceItem> cartItems,
    required this.totalPrice,
    required this.subTotal,
    required this.discountAmount,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
  }) : super(
    cartItems: cartItems
  );

  CartLoaded copyWith({
    List<InvoiceItem>? cartItems,
    List<InvoiceItem>? barcodeCartItems,
    double? totalPrice,
    double? subTotal,
    double? discountAmount,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
  }) {
    return CartLoaded(
      cartItems: cartItems ?? this.cartItems,
      totalPrice: totalPrice ?? this.totalPrice,
      subTotal: subTotal ?? this.subTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
    );
  }

  factory CartLoaded.fromJson(Map<String, dynamic> json) {
    return CartLoaded(
      cartItems: (json['cartItems'] as List)
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'subTotal': subTotal,
      'discountAmount': discountAmount,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
    };
  }
}

class CartError extends CartState {
  final String errorMessage;

  CartError({
    required List<InvoiceItem> cartItems,
    required this.errorMessage,
  }) : super(
    cartItems: cartItems,
  );
}

