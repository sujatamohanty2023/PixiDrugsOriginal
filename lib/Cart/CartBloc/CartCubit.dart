
import 'package:PixiDrugs/constant/all.dart';

enum CartType { main }
enum CartTypeSelection { StockiestReturn,CustomerReturn }

class CartCubit extends Cubit<CartState> {
  Timer? _cartDebounce;

  CartCubit() : super(CartInitial()) {
    _loadDataFromPreferences();
  }

  Map<String, double> _recalculateCartTotals(List<InvoiceItem> updatedCart) {
    double subTotal = 0.0;
    double discountAmount = 0.0;

    for (var item in updatedCart) {
      final bool isTablet = item.unitType == UnitType.Tablet;
      final double mrpPerStrip = double.tryParse(item.mrp) ?? 0.0;
      final double unitMrp = double.tryParse(item.unitMrp ?? '0') ?? 0.0;
      final int packQty = _extractPackingQuantity(item.packing);

      double appliedMrp = isTablet && packQty > 0
          ? (unitMrp > 0 ? unitMrp : mrpPerStrip / packQty)
          : mrpPerStrip;

      print('--- ITEM DEBUG (ID ${item.id}) ---');
      print(' unitType: ${{item.unitType}}');
      print(' mrpPerStrip: $mrpPerStrip');
      print(' unitMrp: $unitMrp');
      print(' packQty: $packQty');
      print(' appliedMrp: $appliedMrp');
      print(' quantity: ${item.qty}');

      final double itemTotal = appliedMrp * item.qty;
      print(' itemTotal: $itemTotal');

      final double discountRate = double.tryParse(item.discountSale ?? '0') ?? 0.0;
      final double itemDiscount = item.discountType == DiscountType.flat
          ? (discountRate * item.qty)
          : (appliedMrp * discountRate / 100) * item.qty;

      print(' discountRate: $discountRate | itemDiscount: $itemDiscount');
      print('------------------------------');

      subTotal += itemTotal;
      discountAmount += itemDiscount;
    }

    final double totalPrice = subTotal - discountAmount;

    print('========= CART TOTALS =========');
    print(' subTotal: $subTotal');
    print(' discountAmount: $discountAmount');
    print(' totalPrice: $totalPrice');
    print('===============================');

    return {
      'totalPrice': totalPrice,
      'subTotal': subTotal,
      'discountAmount': discountAmount,
    };
  }

  int _extractPackingQuantity(String? packing) {
    if (packing == null) return 0;
    final regExp = RegExp(r'\d+'); // match first number
    final match = regExp.firstMatch(packing);
    return match != null ? int.tryParse(match.group(0)!) ?? 0 : 0;
  }



  List<InvoiceItem> _getCartList(CartType type) {
    switch (type) {
      case CartType.main:
        return state.cartItems;
    }
  }

  void _emitUpdatedCartState(CartType type, List<InvoiceItem> updatedList, {
    String? customerName,
    String? customerPhone,
    String? customerAddress,
  }) {
    switch (type) {
      case CartType.main:
        final totals = _recalculateCartTotals(updatedList);
        emit(CartLoaded(
          cartItems: updatedList,
          totalPrice: totals['totalPrice']!,
          subTotal: totals['subTotal']!,
          discountAmount: totals['discountAmount']!,
          customerName: '', // not applicable to main cart
          customerPhone: '',
          customerAddress: '',
        ));
        _saveCartToPreferences();
        break;
    }
  }
  void updateItemDiscount(int productId, double discountSale, {required DiscountType discountType,CartType type = CartType.main}) {
    final cartList = _getCartList(type);
    final updatedCart = cartList.map((item) {
      if (item.id == productId) {
        return item.copyWith(discountSale: discountSale.toString(), discountType: discountType,);
      }
      return item;
    }).toList();

    _emitUpdatedCartState(type, updatedCart);
  }
  void updateItemUnitRate(int productId, double unitRate, {required UnitType unitType,CartType type = CartType.main}) {
    final cartList = _getCartList(type);
    final updatedCart = cartList.map((item) {
      if (item.id == productId) {
        return item.copyWith(unitMrp: unitRate.toString(), unitType: unitType,);
      }
      return item;
    }).toList();

    _emitUpdatedCartState(type, updatedCart);
  }

  void setBarcodeCustomerDetails({
    required String name,
    required String phone,
    required String address,
  }) {
    final totals = _recalculateCartTotals(state.cartItems);

    emit(CartLoaded(
      cartItems: state.cartItems,
      totalPrice: totals['totalPrice']!,
      subTotal: totals['subTotal']!,
      discountAmount: totals['discountAmount']!,
      customerName: name,
      customerPhone: phone,
      customerAddress: address,
    ));
  }
  void addToCart(InvoiceItem product, int quantity,
      {CartType type = CartType.main, bool detailPage = false}) {
    final cartList = _getCartList(type);
    final index = cartList.indexWhere((item) => item.id == product.id);
    final updatedCart = List<InvoiceItem>.from(cartList);

    if (index == -1) {
      updatedCart.add(product.copyWith(qty: quantity,discountSale: '0'));
    } else {
      int currentQty = updatedCart[index].qty;
      int newQty = detailPage ? quantity : currentQty + quantity;
      updatedCart[index] = updatedCart[index].copyWith(qty: newQty);

      /*var updateQuantity = detailPage ? 0 : updatedCart[index].qty;
      updatedCart[index] = updatedCart[index].copyWith(qty: updateQuantity + quantity);*/
    }

    _emitUpdatedCartState(type, updatedCart);
  }
  void loadItemsToCart(List<InvoiceItem> items, {required CartType type}) {
    _emitUpdatedCartState(type, items);
  }


  void incrementQuantity(int productId, {CartType type = CartType.main}) {
    final cartList = _getCartList(type);
    final updatedCart = cartList.map((item) {
      if (item.id == productId) {
        return item.copyWith(qty: item.qty + 1);
      }
      return item;
    }).toList();

    _emitUpdatedCartState(type, updatedCart);
  }

  void decrementQuantity(int productId, {CartType type = CartType.main}) {
    final cartList = _getCartList(type);
    final updatedCart = cartList.map((item) {
      if (item.id == productId && item.qty > 1) {
        return item.copyWith(qty: item.qty - 1);
      }
      return item;
    }).toList();

    _emitUpdatedCartState(type, updatedCart);
  }
  void updateItemQty(InvoiceItem item, int qty, {CartType type = CartType.main}) {
    final cartList = _getCartList(type);
    final updatedCart = cartList.map((i) {
      if (i.id == item.id && i.batch == item.batch) {
        return i.copyWith(qty: qty);
      }
      return i;
    }).toList();

    _emitUpdatedCartState(type, updatedCart);
  }

  void removeFromCart(int productId, {CartType type = CartType.main}) {
    final updatedCart = _getCartList(type).where((item) => item.id != productId).toList();
    _emitUpdatedCartState(type, updatedCart);
  }
  void clearCart({CartType type = CartType.main, bool clearCustomer = true}) {
    _emitUpdatedCartState(type, [], customerName: '', customerPhone: '', customerAddress: '');
  }

  int getQuantity(int productId, {CartType type = CartType.main}) {
    final cartList = _getCartList(type);
    final product = cartList.firstWhere(
          (item) => item.id == productId,
      orElse: () => InvoiceItem(id: -1, qty: 0),
    );
    return product.id == -1 ? 0 : product.qty;
  }

  // SharedPreferences saving methods
  Future<void> _saveCartToPreferences() async {
    _cartDebounce?.cancel();
    _cartDebounce = Timer(const Duration(seconds: 1), () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final products = state.cartItems.map((e) => e.toJson()).toList();
        await prefs.setString('cartState', jsonEncode(products));
      } catch (e) {
        print('Error saving cart: $e');
      }
    });
  }


  Future<void> _loadDataFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cartState');

      List<InvoiceItem> cartList = [];
      String customerName = '';
      String customerPhone = '';
      String customerAddress = '';

      if (cartData != null) {
        final decodedBarcode = jsonDecode(cartData);
        final List items = decodedBarcode['items'] ?? [];

        cartList = items.map((e) => InvoiceItem.fromJson(e)).toList();
        customerName = decodedBarcode['customerName'] ?? '';
        customerPhone = decodedBarcode['customerPhone'] ?? '';
        customerAddress = decodedBarcode['customerAddress'] ?? '';
      }

      final cartTotals = _recalculateCartTotals(cartList);
      emit(CartLoaded(
        cartItems: cartList,
        totalPrice: cartTotals['totalPrice']!,
        subTotal:cartTotals['subTotal']!,
        discountAmount: cartTotals['discountAmount']!,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
      ));
    } catch (e) {
      emit(CartError(
        cartItems: [],
        errorMessage: 'Failed to load cart: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _cartDebounce?.cancel();
    return super.close();
  }
}