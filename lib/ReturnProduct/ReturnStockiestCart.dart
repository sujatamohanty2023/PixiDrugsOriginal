import '../../constant/all.dart';
import '../search/customerModel.dart';
import '../Cart/address_widget.dart';
import '../ReturnStock/PurchaseReturnModel.dart';
import 'ReturnItemTile.dart';

class ReturnStockiestCart extends StatefulWidget {
  PurchaseReturnModel? purchaseReturnModel;
  bool detail;
  CustomerModel? selectedCustomer;
  ReturnStockiestCart({Key? key,
    this.purchaseReturnModel,this.selectedCustomer,
    this.detail = false,}) : super(key: key);

  @override
  State<ReturnStockiestCart> createState() => _ReturnStockiestCartState();
}

class _ReturnStockiestCartState extends State<ReturnStockiestCart> {
  bool edit = false;
  List<String> returnReasons = [
    'Select return reason',
    'Expired Product',
    'Damaged Product',
    'Wrong Item Delivered',
    'Excess Quantity',
    'Other',
  ];

  String? selectedReason='Select return reason';
  String userId = '';
  CustomerModel? selectedSeller;
  List<InvoiceItem> searchResults = [];

  Future<void> _loadUserId() async {
    final id = await SessionManager.getParentingId();
    setState(() {
      userId = id ?? '';
    });
  }
  @override
  void initState() {
    super.initState();
    _loadUserId();
    if(widget.purchaseReturnModel!=null && widget.detail) {
      selectedSeller = CustomerModel(
        id: widget.purchaseReturnModel!.sellerId ?? 0,
        name: widget.purchaseReturnModel!.sellerName ?? '',
        phone: widget.purchaseReturnModel!.phone ?? '',
        address: widget.purchaseReturnModel!.address??'',
      );
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
              invoiceNo: item.invoiceNo,
              sellerId: selectedSeller?.id.toInt()
          )).toList();

      // Load into CartCubit
      context.read<CartCubit>().loadItemsToCart(
          invoiceItems!, type: CartType.main);
      // Set selected reason from model
      selectedReason = widget.purchaseReturnModel?.reason;
    }
    if(widget.selectedCustomer!=null) {
      selectedSeller=widget.selectedCustomer;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is StockReturnAddLoaded) {
            if(state.success) {
              AppUtils.showSnackBar(context,'Successfully retrun to stock');
              context.read<CartCubit>().clearCart(type: CartType.main);
              Navigator.pop(context,true);
            }else{
              AppUtils.showSnackBar(context,'Failed to add StockReturn stock');
            }
          } else if (state is StockReturnAddError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.handleApiError(state.error, () => StockestReturnApiCall());
            });
          }else if (state is StockReturnEditLoaded) {
            if(state.success) {
              AppUtils.showSnackBar(context,'Successfully Updated');
              context.read<CartCubit>().clearCart(type: CartType.main);
              Navigator.pop(context,true);
            }else{
              AppUtils.showSnackBar(context,'Failed to Update');
            }
          } else if (state is StockReturnEditError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.handleApiError(state.error, () => StockestReturnApiCall());
            });
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
                state.cartItems,
                state.totalPrice,
                state.subTotal,
                state.discountAmount,
              );
            }
            return const SizedBox();
          },
        ),
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
      appBar: customAppBar(),
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
              selectedSeller != null?
              addressWidget(name:selectedSeller!.name,phone: selectedSeller!.phone,address: selectedSeller!.address??'',tap:() async =>{},isSaleCart:false):SizedBox(),
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
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: (edit || !widget.detail)
                              ? AppColors.kPrimaryDark
                              : Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: Colors.white,
                        elevation: 8,
                        enabled: (edit || !widget.detail),
                        onSelected: (value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                        itemBuilder: (context) => returnReasons.map((reason) {
                          return PopupMenuItem<String>(
                            value: reason,
                            child: MyTextfield.textStyle_w400(reason, 16, AppColors.kPrimary),
                          );
                        }).toList(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: MyTextfield.textStyle_w400(
                                selectedReason ?? 'Select a return reason',
                                16,
                                selectedReason != null ? Colors.black : Colors.grey,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ]
              ),

              CustomListView<InvoiceItem>(
                data: cartItems,
                physics: const NeverScrollableScrollPhysics(),
                onTap: _onCartItemTap,
                itemBuilder: (item) =>ReturnItemTile(
                  product: item,
                  editable: edit || !widget.detail,
                  onQtyChanged: (qtyStr) {
                    setState(() {
                      item.qty = int.tryParse(qtyStr) ?? 0;
                    });
                  },
                  onDelete: (edit || !widget.detail) ? () {
                    context.read<CartCubit>().removeItemFromCart(item, type: CartType.main);
                  } : null,
                ),

              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:widget.purchaseReturnModel!=null && !edit ?SizedBox():Container(
        height: 50,
        width: 150,
        child: MyElevatedButton(
          onPressed: () {
            StockestReturnApiCall();
          },
          custom_design: true,
          buttonText: edit?'Update Return':"Make Return",
        ),
      ),
    );
  }
  PreferredSizeWidget customAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child:Container(
      color: AppColors.kPrimary,
      width: double.infinity,
      padding: EdgeInsets.only(top: SizeConfig.screenWidth! * 0.01),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 25),
                      ),
                      SizedBox(width: 10),
                      MyTextfield.textStyle_w600(
                        'Return to Stockiest',
                        SizeConfig.screenWidth! * 0.055,
                        Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (widget.purchaseReturnModel != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.kWhiteColor,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                edit = true;
                              });
                            },
                            tooltip: 'Edit',
                          ),
                        ),
                      if (edit || !widget.detail)
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.kWhiteColor,
                            size: 30,
                          ),
                          onPressed:() async {
                            //_QuickscanBarcode
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QuikScanPage(cartTypeSelection:CartTypeSelection.StockiestReturn,
                                  selectedCustomer: selectedSeller)),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
  void _onCartItemTap(InvoiceItem item) {}
  Future<void> StockestReturnApiCall() async {
    final userId = await SessionManager.getParentingId() ?? '';
    final cartState = context.read<CartCubit>().state;
    if (selectedReason == null || selectedReason == 'Select return reason') {
      AppUtils.showSnackBar(context, 'Please select a valid return reason');
      return;
    }
    if(cartState.cartItems.isEmpty){
      AppUtils.showSnackBar(context, 'Please Add return Item' );
      return;
    }

    final selectedItems = cartState.cartItems.
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
      id: edit && widget.purchaseReturnModel !=null?widget.purchaseReturnModel?.id:0,
      storeId:int.parse(userId),
      invoicePurchaseId:0,
      sellerId:selectedSeller?.id,
      address: selectedSeller?.address,
      phone: selectedSeller?.phone,
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount.toString(),
      reason: selectedReason ?? '',
      items:selectedItems,
    );
    print('API returnModel=${returnModel.toString()}');
    if(edit && widget.purchaseReturnModel !=null){
      context.read<ApiCubit>().StockReturnEdit(returnModel: returnModel);
    }else {
      context.read<ApiCubit>().StockReturnAdd(returnModel: returnModel);
    }
  }
}
