import 'package:PixiDrugs/Cart/address_widget.dart';
import 'package:PixiDrugs/constant/all.dart';
import '../Home/HomePageScreen.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../SaleReturn/SaleReturnRequest.dart';
import '../search/customerModel.dart';
import 'ReturnItemTile.dart';

class ReturnCartCustomer extends StatefulWidget {
  CartTypeSelection? cartTypeSelection;
  CustomerReturnsResponse? customerReturnModel;
  CustomerModel? returnDetail;
  bool edit;
  bool detail;
  ReturnCartCustomer({
    Key? key, this.cartTypeSelection,required this.customerReturnModel,this.edit =false,this.detail=false, required this.returnDetail
  }) : super(key: key);

  @override
  _ReturnCartCustomerState createState() => _ReturnCartCustomerState();
}

class _ReturnCartCustomerState extends State<ReturnCartCustomer> with WidgetsBindingObserver, RouteAware {
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
  int? personId=0;
  bool isSubmitting = false;
  @override
  void initState() {
    super.initState();
    print('🛠️ ReturnCart initState called. Edit mode: ${widget.edit}');

    if(widget.customerReturnModel!=null) {
      name=widget.customerReturnModel?.customer.name;
      phone=widget.customerReturnModel?.customer.phone;
      address='Address: --------';
      personId=widget.customerReturnModel?.customerId;
      final items =widget.customerReturnModel?.items;
      final invoiceItems = items?.map((item) =>
          InvoiceItem(
            id: item.productId,
            product: item.product.productName ?? '',
            qty: item.quantity,
            rate: item.price,
            batch: item.batchNo,
            expiry: item.expiry,
            gst:item.gst,
            discount: item.discount,
          )).toList();
    print("API=${invoiceItems.toString()}");
      // Load into CartCubit
      context.read<CartCubit>().loadItemsToCart(
          invoiceItems!, type: CartType.barcode);

      // Set selected reason from model
      selectedReason = widget.customerReturnModel?.reason;
    }

    if(widget.detail==false){
      name=widget.returnDetail?.name;
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
        if (state is SaleReturnAddLoaded) {
          if(state.success) {
            AppUtils.showSnackBar(context,'Successfully retrun to stock');
            context.read<CartCubit>().clearCart(type: CartType.barcode);
            Navigator.pop(context);
          }else{
            AppUtils.showSnackBar(context,'Failed to add StockReturn stock');
          }
        } else if (state is SaleReturnAddError) {
          AppUtils.showSnackBar(context,'Failed to load data: ${state.error}');
        }else if (state is SaleReturnEditLoaded) {
          if(state.success) {
            AppUtils.showSnackBar(context,'Successfully Updated');
            context.read<CartCubit>().clearCart(type: CartType.barcode);
            Navigator.pop(context);
          }else{
            AppUtils.showSnackBar(context,'Failed to Update');
          }
        } else if (state is SaleReturnEditError) {
          AppUtils.showSnackBar(context,'Failed to update api : ${state.error}');
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
                itemBuilder: (item) => ReturnItemTile(
                  product: item,
                  editable: widget.edit || !widget.detail,
                  onQtyChanged: (qtyStr) {
                    item.qty = int.tryParse(qtyStr) ?? 0;
                  },
                ),
                /*itemBuilder: (item) => ProductCard(
                  key: ValueKey(item.id),
                  item: item,
                  mode: ProductCardMode.cart,
                  saleCart:true,
                  editable: widget.edit|| !widget.detail,
                ),*/
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:widget.customerReturnModel!=null && !widget.edit ?SizedBox():Container(
        height: 50,
        width: 150,
        child: MyElevatedButton(
          onPressed: () {
            if (!isSubmitting) {
              isSubmitting = true;
              CustomerReturnApiCall();
            }
          },
          custom_design: true,
          buttonText: widget.edit?'Update Return':"Make Return"
        ),
      ),
    );
  }
  void _onCartItemTap(InvoiceItem item) {}
  Future<void> CustomerReturnApiCall() async {
    final userId = await SessionManager.getParentingId() ?? '';
    final cartState = context.read<CartCubit>().state;
    final selectedItems = cartState.barcodeCartItems.
    map((item) => ReturnedItem(
      productId: item.id??0,
      quantity: item.qty,
      price:double.parse(item.rate),
      discount:double.parse(item.discount),
      gst:double.parse(item.gst),
      totalAmount: (item.qty * (double.tryParse(item.rate) ?? 0.0)),
    ))
        .toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
          (sum, item) => sum + (item.quantity * item.price),
    );
    var returnModel = SaleReturnRequest(
      id: widget.edit && widget.customerReturnModel !=null?widget.customerReturnModel?.id:0,
      storeId:int.parse(userId),
      billingId:0,
      customerId:widget.edit && widget.customerReturnModel !=null?widget.customerReturnModel?.customerId:personId,
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount,
      reason: selectedReason ?? '',
      items:selectedItems,
    );
    print('API returnModel=${returnModel.toString()}');
    if(widget.edit && widget.customerReturnModel !=null){
      context.read<ApiCubit>().SaleReturnEdit(returnModel: returnModel);
    }else {
      context.read<ApiCubit>().SaleReturnAdd(returnModel: returnModel);
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
