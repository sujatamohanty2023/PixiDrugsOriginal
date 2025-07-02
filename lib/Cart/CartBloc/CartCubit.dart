
import 'package:pixidrugs/constant/all.dart';

enum CartType { main,  barcode }

class CartCubit extends Cubit<CartState> {
  Timer? _cartDebounce;
  Timer? _barcodeDebounce;

  CartCubit() : super(CartInitial()) {
    _loadDataFromPreferences();
  }

  Map<String, double> _recalculateCartTotals(List<InvoiceItem> updatedCart) {
    final double subTotal = updatedCart.fold(0, (sum, item) => sum + (double.parse(item.mrp) * item.qty));
    final double discountAmount = 0; // You can calculate discount logic here
    final double totalPrice = subTotal - discountAmount;

    return {
      'totalPrice': totalPrice,
      'subTotal': subTotal,
      'discountAmount': discountAmount,
    };
  }

  List<InvoiceItem> _getCartList(CartType type) {
    switch (type) {
      case CartType.main:
        return state.cartItems;
      case CartType.barcode:
        return state.barcodeCartItems;
    }
  }

  void _emitUpdatedCartState(CartType type, List<InvoiceItem> updatedList) {
    switch (type) {
      case CartType.main:
        final totals = _recalculateCartTotals(updatedList);
        emit(CartLoaded(
          cartItems: updatedList,
          barcodeCartItems: state.barcodeCartItems,
          totalPrice: totals['totalPrice']!,
          subTotal: totals['subTotal']!,
          discountAmount: totals['discountAmount']!,
        ));
        _saveCartToPreferences();
        break;

      case CartType.barcode:
        final totals = _recalculateCartTotals(updatedList);
        emit(CartLoaded(
          cartItems: state.cartItems,
          barcodeCartItems: updatedList,
          totalPrice: totals['totalPrice']!,
          subTotal: totals['subTotal']!,
          discountAmount: totals['discountAmount']!,
        ));
        _saveBarcodeCartToPreferences();
        break;
    }
  }

  void addToCart(InvoiceItem product, int quantity,
      {CartType type = CartType.main, bool detailPage = false}) {
    final cartList = _getCartList(type);
    final index = cartList.indexWhere((item) => item.id == product.id);
    final updatedCart = List<InvoiceItem>.from(cartList);

    if (index == -1) {
      updatedCart.add(product.copyWith(qty: quantity));
    } else {
      var updateQuantity = detailPage ? 0 : updatedCart[index].qty;
      updatedCart[index] = updatedCart[index].copyWith(qty: updateQuantity + quantity);
    }

    _emitUpdatedCartState(type, updatedCart);
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

  void removeFromCart(int productId, {CartType type = CartType.main}) {
    final updatedCart = _getCartList(type).where((item) => item.id != productId).toList();
    _emitUpdatedCartState(type, updatedCart);
  }

  void clearCart({CartType type = CartType.main}) {
    _emitUpdatedCartState(type, []);
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
        final products = state.cartItems.map((e) => e?.toJson()).toList();
        await prefs.setString('cartState', jsonEncode(products));
      } catch (e) {
        print('Error saving cart: $e');
      }
    });
  }

  Future<void> _saveBarcodeCartToPreferences() async {
    _barcodeDebounce?.cancel();
    _barcodeDebounce = Timer(const Duration(seconds: 1), () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final products = state.barcodeCartItems.map((e) => e?.toJson()).toList();
        await prefs.setString('barcodeCartState', jsonEncode(products));
      } catch (e) {
        print('Error saving barcode cart: $e');
      }
    });
  }


  Future<void> _loadDataFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cartState');
      final wishlistData = prefs.getString('wishlistState');
      final barcodeData = prefs.getString('barcodeCartState');

      List<InvoiceItem> cartList = [];
      List<InvoiceItem> wishlistList = [];
      List<InvoiceItem> barcodeList = [];

      if (cartData != null) {
        final List decoded = jsonDecode(cartData);
        cartList = decoded.map((e) => InvoiceItem.fromJson(e)).toList();
      }

      if (wishlistData != null) {
        final List decoded = jsonDecode(wishlistData);
        wishlistList = decoded.map((e) => InvoiceItem.fromJson(e)).toList();
      }

      if (barcodeData != null) {
        final List decoded = jsonDecode(barcodeData);
        barcodeList = decoded.map((e) => InvoiceItem.fromJson(e)).toList();
      }

      final totals = _recalculateCartTotals(cartList);

      emit(CartLoaded(
        cartItems: cartList,
        barcodeCartItems: barcodeList,
        totalPrice: totals['totalPrice']!,
        subTotal: totals['subTotal']!,
        discountAmount: totals['discountAmount']!,
      ));
    } catch (e) {
      emit(CartError(
        cartItems: [],
        barcodeCartItems: [],
        errorMessage: 'Failed to load cart: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _cartDebounce?.cancel();
    _barcodeDebounce?.cancel();
    return super.close();
  }
}
