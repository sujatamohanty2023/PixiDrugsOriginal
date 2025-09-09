import 'package:PixiDrugs/Cart/customerDetailWidget.dart';
import 'package:PixiDrugs/Dialog/success_dialog.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'CustomerDetailBottomSheet.dart';
import 'ReceiptPrinterPage.dart';

class CartPage extends StatefulWidget {

  const CartPage({
    Key? key,
  }) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver, RouteAware {
  String name= '', phone= '', address= '', paymentType= '', referenceNumber= '',  referralName= '',  referralPhone= '', referralAmount = '';
  bool isReferralAmountGiven=false;
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
          AppUtils.showSnackBar(context,state.message);
          print("${state.saleModel}");
          if (state.message == "Bill submitted successfully.") {
            SuccessOrderPlaceCall(state.saleModel);
          }
        } else if (state is OrderPlaceError) {
          Navigator.pop(context); // Dismiss loading
          AppUtils.showSnackBar(context,'Failed to CheckOut: ${state.error}');
        }
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartInitial) {
            return _buildLoadingOrError(state);
          }
          if (state is CartLoaded) {
            name = state.customerName;
            phone = state.customerPhone;
            address = state.customerAddress;
            return _buildCartLoadedUI(
              context,
              state.cartItems,
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeConfig.screenWidth! * 0.07),
            topRight: Radius.circular(SizeConfig.screenWidth! * 0.07),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50.0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              name.isNotEmpty?
              customerDetailWidget(name:name,phone: phone,address: address,
                  paymentType: paymentType,referenceNumber: referenceNumber,referralName: referralName,referralPhone: referralPhone,
                  referralAmount: referralAmount,
                  tap:() =>checkUserData(),isSaleCart:true):SizedBox(),
              const SizedBox(height: 5),
              CustomListView<InvoiceItem>(
                data: cartItems,
                physics: const NeverScrollableScrollPhysics(),
                onTap: _onCartItemTap,
                itemBuilder: (item) => ProductCard(
                    key: ValueKey(item.id),
                    item: item,
                    mode: ProductCardMode.cart,
                    saleCart:true,
                    editable: true
                ),
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  PaymentRow(title: "Order Summary", value: "", isBold: true),
                  Divider(color: AppColors.kPrimary.withOpacity(0.1), thickness: 1),
                  PaymentRow(title: "Sub-total", value: "${AppString.Rupees}$subTotal"),
                  PaymentRow(title: "Discount", value: "- ${AppString.Rupees}$discountAmount", color: Colors.green),
                  Divider(color: AppColors.kPrimary.withOpacity(0.1), thickness: 1),
                  PaymentRow(
                    title: "Total",
                    value: "${AppString.Rupees}${totalPrice.toStringAsFixed(2)}",
                    isBold: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        height: 50,
        width: 150,
        child: MyElevatedButton(
          onPressed: () {
            if (name.isNotEmpty && paymentType.isNotEmpty) {
              _paymentPageCall();
            } else {
              _onButtonSalePressed();
            }
          },
          custom_design: true,
          buttonText: name.isNotEmpty ? "CheckOut" : "Confirm",
        ),
      ),
    );
  }
  Future<void> _paymentPageCall() async {
    String? userId = await SessionManager.getParentingId();
    final cartState = context.read<CartCubit>().state;

    if (cartState is CartLoaded) {
      if (cartState.cartItems.isEmpty) {
        AppUtils.showSnackBar(context,'Your cart is empty');
        return;
      }
      String referralNote = '';
      if (referralName.isNotEmpty || referralPhone.isNotEmpty) {
        referralNote = 'Customer Name: $name\n';
        referralNote += 'Customer Contact No.: $phone\n';
        referralNote += 'Referral Person: $referralName\n';
        referralNote += 'Referral Contact No.: $referralPhone\n';
        if (isReferralAmountGiven && referralAmount.isNotEmpty) {
          referralNote += 'Referral Amount: ₹$referralAmount Given';
        } else {
          referralNote += 'Referral Amount: Not Given';
        }
      }
      final model = OrderPlaceModel(
        cartItems: cartState.cartItems,
        seller_id: userId!,
        name: name,
        phone: phone,
        email: '',
        address: address,
        payment_type:paymentType,
        amount:referralAmount,
        title:'Referral Bonus',
        note:referralNote,
      );
      print('API URL: ${model.toString()}');
      _showLoadingDialog(); // Show loading
      context.read<ApiCubit>().placeOrder(orderPlaceModel: model);
    } else {
      AppUtils.showSnackBar(context,'Unexpected error occurred');
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
    final parentContext = context;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => SuccessDialog(
        sale,
        SvgPicture.asset(AppImages.check, height: 60, width: 60),
        "Your Placed Order Successful",
        "Your order #${sale.invoiceNo} has been placed successfully.",
        onDonePressed: () {
          Future.delayed(Duration(milliseconds: 300), () {
            //_showReceiptBottomSheet(parentContext, sale);
            AppRoutes.navigateTo(context, ReceiptPrinterPage(
              sale: sale,
            ));
          });
        },
      ),
    );
  }
  void _showReceiptBottomSheet(BuildContext context, SaleModel sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: AppColors.kWhiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.70,
        minChildSize: 0.60,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ReceiptPrinterPage(
            sale: sale,
            scrollController: scrollController,
          );
        },
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
        SizeConfig.screenHeight! * 0.90,
      )),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        minChildSize: 0.95,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return CustomerDetailBottomSheet(
            name: name,
            phone: phone,
            address: address,
            scrollController: scrollController,
            onSubmit: (name1, phone1, submittedAddress1,paymentType1, referenceNumber1,
                referralName1, referralPhone1,referralAmount1,isReferralAmountGiven1) async {

              setState(() {
                name = name1;
                phone = phone1;
                address = submittedAddress1;
                paymentType= paymentType1;
                referenceNumber= referenceNumber1;
                referralName= referralName1;
                referralPhone= referralPhone1;
                referralAmount= referralAmount1;
                isReferralAmountGiven= isReferralAmountGiven1;
              });

              context.read<CartCubit>().setBarcodeCustomerDetails(
                name: name1,
                phone: phone1,
                address: submittedAddress1,
              );
              Navigator.pop(context); // Close bottom sheet
            },
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
