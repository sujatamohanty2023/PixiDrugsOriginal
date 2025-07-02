
import 'package:pixidrugs/constant/all.dart';

class CartTab extends StatefulWidget {
  final void Function() onPressedProduct;
  final bool barcodeScan;

  const CartTab({
    Key? key,
    required this.onPressedProduct,
    this.barcodeScan = false,
  }) : super(key: key);

  @override
  _CartTabState createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.BaseAppBar(
        context: context,
        title: widget.barcodeScan ? 'Sale Product' : 'My Cart',
        leading: false,
        actions: [
          if (widget.barcodeScan)
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.kWhiteColor, size: 30),
                onPressed: _scanBarcode,
                tooltip: 'Scan QR Code',
              ),
            )
        ],
      ),

      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is BarcodeScanLoaded) {
            final model = state.model;
            final cartCubit = context.read<CartCubit>();
            cartCubit.addToCart(model, 1,type: CartType.barcode);

          } else if (state is BarcodeScanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: _buildCartContent(context),
      ),
    );
  }

  /// Builds either cart or barcode cart content based on `widget.barcodeScan`
  Widget _buildCartContent(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return _buildCartOrEmpty(state.barcodeCartItems);
      },
    );
  }

  /// Shows empty page or the main CartPage
  Widget _buildCartOrEmpty(List<InvoiceItem> items) {
    return items.isEmpty ? _buildEmptyPage() : CartPage(barcodeScan: widget.barcodeScan);
  }

  /// Shows a customizable empty cart page
  Widget _buildEmptyPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.myGradient,
      ),
      child: NoItemPage(
        onTap: _scanBarcode,
        image: AppImages.empty_cart,
        tittle: "Your Cart is Empty",
        description: "Looks like you haven't added anything \nto your cart yet.",
        button_tittle: widget.barcodeScan ? 'Scan Now' : "Shop Now",
      ),
    );
  }

  /// Initiates barcode scan
  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        context.read<ApiCubit>().BarcodeScan(code: result.rawContent);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan barcode')),
      );
    }
  }

  /// Handles checkout button press
  Future<void> _paymentPageCall(BuildContext context) async {
    final cartState = context.read<CartCubit>().state;

    if (cartState is CartLoaded) {
      if (cartState.cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      final model = OrderPlaceModel(
        cartItems: cartState.cartItems,
        totalPrice: cartState.totalPrice,
        subTotal: cartState.subTotal,
        discountAmount: cartState.discountAmount,
      );
      Navigator.pushNamed(context, '/paymentAfterOrder',arguments: model);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred')),
      );
    }
  }
}
