import 'package:PixiDrugs/Cart/address_widget.dart';
import 'package:PixiDrugs/Dialog/success_dialog.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'CustomerDetailBottomSheet.dart';
import 'ProductCard.dart';

class CartPage extends StatefulWidget {
  final bool barcodeScan;

  const CartPage({Key? key, this.barcodeScan = false}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver, RouteAware {
  String? name, phone, address = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    print("Returned to CartPage");
  }

  Future<void> checkUserData() async {
    _onButtonSalePressed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiCubit, ApiState>(
      listener: (context, state) {
        if (state is OrderPlaceLoaded) {
          Navigator.pop(context); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          print("${state.saleModel}");
          if (state.message == "Bill submitted successfully.") {
            SuccessOrderPlaceCall(state.saleModel);
          }
        } else if (state is OrderPlaceError) {
          Navigator.pop(context); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to CheckOut: ${state.error}')),
          );
        }
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartInitial) {
            return _buildLoadingOrError(state);
          }
          if (state is CartLoaded) {
            name = widget.barcodeScan ? state.customerName : '';
            phone = widget.barcodeScan ? state.customerPhone : '';
            address = widget.barcodeScan ? state.customerAddress : '';
            return _buildCartLoadedUI(
              context,
              widget.barcodeScan ? state.barcodeCartItems : state.cartItems,
              state.totalPrice,
              state.subTotal,
              state.discountAmount,
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLoadingOrError(dynamic state) {
    if (state is CartError) {
      return Center(child: Text(state.errorMessage));
    }
    return const Center(child: CircularProgressIndicator(color: AppColors.kPrimary));
  }

  Widget _buildCartLoadedUI(
      BuildContext context,
      List<InvoiceItem> cartItems,
      double totalPrice,
      double subTotal,
      double discountAmount,
      ) {
    return Scaffold(
      backgroundColor: AppColors.kPrimary,
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50.0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.barcodeScan && name != null && name!.isNotEmpty?
              addressWidget(name:name!,phone: phone!,address: address!,tap:()=>checkUserData()):SizedBox(),
              const SizedBox(height: 5),
              CustomListView<InvoiceItem>(
                data: cartItems,
                physics: const NeverScrollableScrollPhysics(),
                onTap: _onCartItemTap,
                itemBuilder: (item) => ProductCard(
                    item: item,
                    mode: ProductCardMode.cart,
                  barcodeScan: widget.barcodeScan,
                    showRemoveIcon:true
                ),
              ),
              const SizedBox(height: 15),
              PaymentRow(title: "Order Summary", value: "", isBold: true),
              Divider(color: AppColors.kPrimary.withOpacity(0.1), thickness: 1),
              PaymentRow(title: "Sub-total", value: "${AppString.Rupees}$totalPrice"),
              PaymentRow(title: "Discount", value: "- ${AppString.Rupees}$discountAmount", color: Colors.green),
              Divider(color: AppColors.kPrimary.withOpacity(0.1), thickness: 1),
              PaymentRow(
                title: "Total",
                value: "${AppString.Rupees}${totalPrice.toStringAsFixed(2)}",
                isBold: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: widget.barcodeScan
          ? Container(
        height: 50,
        width: 150,
        child: MyElevatedButton(
          onPressed: () {
            if (address != null && address!.isNotEmpty) {
              _paymentPageCall();
            } else {
              _onButtonSalePressed();
            }
          },
          custom_design: true,
          buttonText: address != null && address!.isNotEmpty ? "CheckOut" : "Confirm",
        ),
      )
          : const SizedBox(),
    );
  }

  Future<void> _paymentPageCall() async {
    String? userId = await SessionManager.getUserId();
    final cartState = context.read<CartCubit>().state;

    if (cartState is CartLoaded) {
      if (cartState.barcodeCartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
        return;
      }

      final model = OrderPlaceModel(
        cartItems: cartState.barcodeCartItems,
        seller_id: userId!,
        name: name!,
        phone: phone!,
        email: '',
        address: address!,
      );
      print('API URL: ${model.toString()}');
      _showLoadingDialog(); // Show loading
      context.read<ApiCubit>().placeOrder(orderPlaceModel: model);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred')),
      );
    }
  }

  void _showLoadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.kPrimary),
      ),
    );
  }

  void SuccessOrderPlaceCall(SaleModel sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SuccessDialog(
        sale,
        SvgPicture.asset(AppImages.check, height: 60, width: 60),
        "Your Placed Order Successful",
        "Your order #${sale.invoiceNo} has been placed successfully.",
      ),
    );
  }

  void _onButtonSalePressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kWhiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      constraints: BoxConstraints.loose(Size(
        SizeConfig.screenWidth!,
        SizeConfig.screenHeight! * 0.60,
      )),
      isScrollControlled: false,
      builder: (_) => CustomerDetailBottomSheet(
        name: name,
        phone: phone,
        address: address,
        onSubmit: (name1, phone1, submittedAddress1) {
          setState(() {
            name = name1;
            phone = phone1;
            address = submittedAddress1;
          });
          context.read<CartCubit>().setBarcodeCustomerDetails(
            name: name1,
            phone: phone1,
            address: submittedAddress1,
          );
        },
      ),
    );
  }
  void _onCartItemTap(InvoiceItem item) {}
}

class PaymentRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final Color color;

  const PaymentRow({
    required this.title,
    required this.value,
    this.isBold = false,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = isBold
        ? MyTextfield.textStyle_w600(title, 18, AppColors.kPrimary)
        : MyTextfield.textStyle_w200(title, 15, Colors.grey[600]!);

    final valueStyle = isBold
        ? MyTextfield.textStyle_w600(value, 18, AppColors.kPrimary)
        : MyTextfield.textStyle_w300(value, 15, color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [titleStyle, valueStyle],
      ),
    );
  }
}
