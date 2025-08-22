import 'package:PixiDrugs/Cart/address_widget.dart';
import 'package:PixiDrugs/constant/all.dart';
import '../Home/HomePageScreen.dart';
import '../StockReturn/PurchaseReturnModel.dart';
import '../search/sellerModel.dart';

class ReturnCartStockiest extends StatefulWidget {
  CartTypeSelection? cartTypeSelection;
  PurchaseReturnModel? purchaseReturnModel;
  Seller? returnDetail;
  bool edit;
  bool detail;
  ReturnCartStockiest({
    Key? key, this.cartTypeSelection,this.purchaseReturnModel,this.edit =false,this.detail=false, this.returnDetail
  }) : super(key: key);

  @override
  _ReturnCartStockiestState createState() => _ReturnCartStockiestState();
}

class _ReturnCartStockiestState extends State<ReturnCartStockiest> with WidgetsBindingObserver, RouteAware {
  List<String> returnReasons = [
    'Select return reason',
    'Expired Product',
    'Damaged Product',
    'Wrong Item Delivered',
    'Excess Quantity',
    'Other',
  ];

  String? selectedReason;
  String? name, phone, address = '';
  int personId=0;

  @override
  void initState() {
    super.initState();
    print('🛠️ ReturnCart initState called. Edit mode: ${widget.edit}');


    if(widget.purchaseReturnModel!=null) {
      name=widget.purchaseReturnModel?.sellerName;
      phone=widget.purchaseReturnModel?.phone;
      address=widget.purchaseReturnModel?.address;
      personId=widget.purchaseReturnModel!.sellerId!;
      final items =widget.purchaseReturnModel?.items;
      final invoiceItems = items?.map((item) =>
          InvoiceItem(
            id: item.productId,
            product: item.productName ?? '',
            qty: item.quantity,
            rate: item.rate,
            batch: item.batchNo,
            expiry: item.expiry,
            gst: item.gstPercent,
            discount: item.discountPercent,
            invoiceNo: item.invoiceNo
          )).toList();

      // Load into CartCubit
      context.read<CartCubit>().loadItemsToCart(
          invoiceItems!, type: CartType.barcode);
      // Set selected reason from model
      selectedReason = widget.purchaseReturnModel?.reason;
    }

    if(widget.detail==false){
      name=widget.returnDetail?.sellerName;
      phone=widget.returnDetail?.phone;
      address=widget.returnDetail?.address;
      personId=widget.returnDetail!.id;
      print('$name$phone$address');
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiCubit, ApiState>(
      listener: (context, state) {
        if (state is StockReturnAddLoaded) {
          if(state.success) {
            AppUtils.showSnackBar(context,'Successfully retrun to stock');
            context.read<CartCubit>().clearCart(type: CartType.barcode);
            AppRoutes.navigateTo(context, HomePage());
          }else{
            AppUtils.showSnackBar(context,'Failed to add StockReturn stock');
          }
        } else if (state is StockReturnAddError) {
          AppUtils.showSnackBar(context,'Failed to load data: ${state.error}');
        }
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartInitial) {
            return _buildLoadingOrError(state);
          }
          if (state is CartLoaded) {
            return _buildCartLoadedUI(
              context,
              state.barcodeCartItems,
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
              name != null && name!.isNotEmpty?
              addressWidget(name:name!,phone: phone!,address: address!,tap:() async =>{},isSaleCart:false):SizedBox(),
              const SizedBox(height: 5),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      MyTextfield.textStyle_w600(
                        'Reason for Return',
                        SizeConfig.screenWidth! * 0.045,
                        Colors.black,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedReason,
                        items: returnReasons.map((reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: MyTextfield.textStyle_w400(reason,16,Colors.grey),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: AppColors.kPrimaryDark, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: AppColors.kPrimary, width: 1.5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                          ),
                        ),
                          onChanged: ( widget.edit || !widget.detail)
                              ? (value) {
                            setState(() {
                              selectedReason = value;
                            });
                          }: null,
                        hint: const Text("Select a return reason"),
                      ),
                      const SizedBox(height: 16),
                    ]
                ),

              CustomListView<InvoiceItem>(
                data: cartItems,
                physics: const NeverScrollableScrollPhysics(),
                onTap: _onCartItemTap,
                itemBuilder: (item) => ProductCard(
                    key: ValueKey(item.id),
                    item: item,
                    mode: ProductCardMode.cart,
                    saleCart:true,
                    editable: widget.edit|| !widget.detail,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:widget.purchaseReturnModel!=null && !widget.edit ?SizedBox():Container(
        height: 50,
        width: 150,
        child: MyElevatedButton(
          onPressed: () {
            StockestReturnApiCall();
          },
          custom_design: true,
          buttonText: widget.edit?'Update Return':"Make Return",
        ),
      ),
    );
  }
  void _onCartItemTap(InvoiceItem item) {}

  Future<void> StockestReturnApiCall() async {
    final userId = await SessionManager.getParentingId() ?? '';
    final cartState = context.read<CartCubit>().state;

    final selectedItems = cartState.barcodeCartItems.
    map((item) => ReturnItemModel(
      productId: item.id??0,
      quantity: item.qty,
      rate: item.rate,
      batchNo: item.batch,
      expiry:item.expiry,
      gstPercent:item.gst,
      discountPercent: item.discount,
      invoiceNo: item.invoiceNo,
      totalAmount: (item.qty * (double.tryParse(item.rate) ?? 0.0)).toString(),
    ))
        .toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
          (sum, item) => sum + (item.quantity * double.parse(item.rate)),
    );
    var returnModel = PurchaseReturnModel(
      id: widget.edit && widget.purchaseReturnModel !=null?widget.purchaseReturnModel?.id:0,
      storeId:int.parse(userId),
      invoicePurchaseId:0,
      sellerId:widget.edit && widget.purchaseReturnModel !=null?widget.purchaseReturnModel?.sellerId:personId,
      address: widget.purchaseReturnModel?.address,
      phone: widget.purchaseReturnModel?.phone,
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount.toString(),
      reason: selectedReason ?? '',
      items:selectedItems,
    );
    print('API returnModel=${returnModel.toString()}');
    if(widget.edit && widget.purchaseReturnModel !=null){
      context.read<ApiCubit>().StockReturnEdit(returnModel: returnModel);
    }else {
      context.read<ApiCubit>().StockReturnAdd(returnModel: returnModel);
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
}
