import 'package:pixidrugs/PdfGenerate.dart';
import 'package:pixidrugs/constant/all.dart';
import 'CustomerDetailBottomSheet.dart';

class CartPage extends StatefulWidget {
  final bool barcodeScan;

  const CartPage({Key? key, this.barcodeScan = false}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver, RouteAware {
  String? address = '';

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
    print("initState dispose: Dashboard disposed");
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("initState App is back in foreground");
    }
  }
  @override
  void didPopNext() {
    print("initState Returned to DoctorDashboard from another screen");
  }

  Future<void> checkUserData() async {
    _onButtonSalePressed();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is CartInitial) {
          return _buildLoadingOrError(state);
        }
        if (state is CartLoaded) {
          return _buildCartLoadedUI(
            context,
            widget.barcodeScan?state.barcodeCartItems:state.cartItems,
            state.totalPrice,
            state.subTotal,
            state.discountAmount,
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingOrError(dynamic state) {
    if (state is CartError) {
      return Center(child: Text(state.errorMessage));
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildCartLoadedUI(
      BuildContext context,
      List<InvoiceItem> cartItems,
      double totalPrice,
      double subTotal,
      double discountAmount,
      ) {

    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.myGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 50.0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (widget.barcodeScan)
                address != null && address!.isNotEmpty
                    ?_buildAddressSection()
                    :SizedBox(),

              const SizedBox(height: 10),

              CustomListView<InvoiceItem>(
                data: cartItems,
                physics: const NeverScrollableScrollPhysics(),
                onTap: _onCartItemTap,
                itemBuilder: (item) => CartItemCard(item: item, barcodeScan: widget.barcodeScan),
              ),

              const SizedBox(height: 15),

              const SizedBox(height: 10),

              PaymentRow(title: "Order Summary", value: "", isBold: true),
              Divider(color: AppColors.kPrimary.withOpacity(0.1), thickness: 1),
              PaymentRow(title: "Sub-total", value: "${AppString.Rupees}$totalPrice"),
              PaymentRow(title: "Discount", value: "- ${AppString.Rupees}$discountAmount", color: Colors.green),
              PaymentRow(title: "Shipping", value: "FREE", color: Colors.red),

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
      floatingActionButton: widget.barcodeScan?Container(
          height: 50,
          width: 150,
          child: MyElevatedButton(
            onPressed: (){
                if(address != null && address!.isNotEmpty){
                  AppRoutes.navigateTo(context, ReceiptPrinterPage(products:cartItems));
                }else {
                  _onButtonSalePressed();
                }
              },
            custom_design: true,
            buttonText:  address != null && address!.isNotEmpty?"CheckOut":"Confirm",
          )):SizedBox(),
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
        onSubmit: (name, phone, submittedAddress) {
          setState(() {
            address = '$name \n $phone \n $submittedAddress';
          });
        },
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(AppImages.home_address, height: 35, width: 35),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                MyTextfield.textStyle_w600(address ?? '', 14, Colors.grey[700]!),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => checkUserData(),
            child: MyTextfield.textStyle_w600("Change", 14, Colors.deepOrange),
          ),
        ],
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
        ? MyTextfield.textStyle_w600(title, 16, Colors.grey[600]!)
        : MyTextfield.textStyle_w200(title, 14, Colors.grey[600]!);

    final valueStyle = isBold
        ? MyTextfield.textStyle_w600(value, 16, color)
        : MyTextfield.textStyle_w300(value, 14, color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [titleStyle, valueStyle],
      ),
    );
  }
}
