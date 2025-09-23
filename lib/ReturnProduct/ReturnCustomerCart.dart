
import 'package:PixiDrugs/constant/all.dart';
import '../BarcodeScan/ScanPage.dart';
import '../Cart/address_widget.dart';
import 'ReturnItemTile.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../SaleReturn/SaleReturnRequest.dart';
import '../search/customerModel.dart';

class ReturnCustomerCart extends StatefulWidget {
  CustomerReturnsResponse? customerReturnModel;
  bool detail;
  CustomerModel? selectedCustomer;
  final List<CustomerModel>?CustomerList;
  bool isEdit = false;
  ReturnCustomerCart({Key? key,
    this.customerReturnModel,this.selectedCustomer,this.CustomerList,
    this.detail = false,this.isEdit = false,}) : super(key: key);

  @override
  State<ReturnCustomerCart> createState() => _ReturnCustomerCartState();
}

class _ReturnCustomerCartState extends State<ReturnCustomerCart> {
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
  CustomerModel? selectedCustomer;
  List<InvoiceItem> searchResults = [];
  List<CustomerModel> _detail_Customer = [];

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
    edit=widget.isEdit;
    if(widget.CustomerList !=null){
      _detail_Customer=widget.CustomerList!;
    }else {
      if (widget.customerReturnModel != null) {
        selectedCustomer = CustomerModel(
          id: widget.customerReturnModel!.customer.id ?? 0,
          name: widget.customerReturnModel!.customer.name ?? '',
          phone: widget.customerReturnModel!.customer.phone ?? '',
          address: '',
        );
        final items = widget.customerReturnModel?.items;
        final invoiceItems = items?.map((item) =>
            InvoiceItem(
              id: item.productId,
              product: item.product.productName ?? '',
              qty: item.quantity,
              rate: (item.price ?? 0).toString(),
              batch: item.batchNo,
              expiry: item.expiry,
              gst: (item.gst ?? 0).toString(),
              discount: (item.discount ?? 0).toString(),
            )).toList();

        // Load into CartCubit
        context.read<CartCubit>().loadItemsToCart(
            invoiceItems!, type: CartType.main);
        // Set selected reason from model
        selectedReason = widget.customerReturnModel?.reason;
      }
      if (widget.selectedCustomer != null) {
        selectedCustomer = widget.selectedCustomer;
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is SaleReturnAddLoaded) {
            if(state.success) {
              AppUtils.showSnackBar(context,'Successfully retrun to stock');
              context.read<CartCubit>().clearCart(type: CartType.main);
              Navigator.pop(context,true);
            }else{
              AppUtils.showSnackBar(context,'Failed to add StockReturn stock');
            }
          } else if (state is SaleReturnAddError) {
            AppUtils.showSnackBar(context,'Failed to load data: ${state.error}');
          }else if (state is SaleReturnEditLoaded) {
            if(state.success) {
              AppUtils.showSnackBar(context,'Successfully Updated');
              context.read<CartCubit>().clearCart(type: CartType.main);
              Navigator.pop(context,true);
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
            if (_detail_Customer.isNotEmpty) {
              print("Showing search results...");
              return _CustomerResultWidget();
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
              selectedCustomer != null?
              addressWidget(name:selectedCustomer!.name,phone: selectedCustomer!.phone,address: selectedCustomer!.address??'',tap:() async =>{},isSaleCart:false):SizedBox(),
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
                    print("API=${item.qty}");
                  },
                ),

              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:widget.customerReturnModel!=null && !edit ?SizedBox():Container(
        height: 50,
        width: 150,
        child: MyElevatedButton(
          onPressed: () {
            CustomerReturnApiCall();
          },
          custom_design: true,
          buttonText: edit?'Update Return':"Make Return",
        ),
      ),
    );
  }
  PreferredSizeWidget customAppBar() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
                            'Return to Customer',
                            SizeConfig.screenWidth! * 0.055,
                            Colors.white,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (widget.customerReturnModel != null)
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
                              onPressed: () async {
                               // _QuickscanBarcode
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => QuikScanPage(cartTypeSelection:CartTypeSelection.CustomerReturn,
                                      selectedCustomer: selectedCustomer)),
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
  Future<void> CustomerReturnApiCall() async {
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
    print('API returnModel=${cartState.cartItems.toString()}');
    final selectedItems = cartState.cartItems.
    map((item) => ReturnedItem(
      productId: item.id??0,
      quantity: item.qty,
      price: double.tryParse(item.rate) ?? 0,
      discount: double.tryParse(item.discount) ?? 0,
      gst: double.tryParse(item.gst) ?? 0,
      totalAmount: (item.qty * (double.tryParse(item.rate) ?? 0.0)),
    ))
        .toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
          (sum, item) => sum + (item.quantity * item.price),
    );
    print("API=${selectedItems.first.quantity}");
    var returnModel = SaleReturnRequest(
      id: edit && widget.customerReturnModel !=null?widget.customerReturnModel?.id:0,
      storeId:int.parse(userId),
      billingId:0,
      customerId:selectedCustomer?.id,
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount,
      reason: selectedReason ?? '',
      items:selectedItems,
    );
    print('API returnModel=${returnModel.toString()}');
    if(edit && widget.customerReturnModel !=null){
      context.read<ApiCubit>().SaleReturnEdit(returnModel: returnModel);
    }else {
      context.read<ApiCubit>().SaleReturnAdd(returnModel: returnModel);
    }
  }
  Widget _CustomerResultWidget() {
    return Scaffold(
    appBar: customAppBar(),
    backgroundColor: AppColors.kPrimary,
    body: Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.screenWidth! * 0.07),
          topRight: Radius.circular(SizeConfig.screenWidth! * 0.07),
        ),
      ),
      child: _searchResultWidget(),
    )
    );
  }
  Widget _searchResultWidget() {

    return ListView.builder(
      itemCount: _detail_Customer.length,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        final displayName = _detail_Customer[index].name;
        final phone = _detail_Customer[index].phone;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: MyTextfield.textStyle_w600( displayName ?? '', SizeConfig.screenWidth! * 0.035,AppColors.kPrimary),
            subtitle: MyTextfield.textStyle_w400( phone ?? '', SizeConfig.screenWidth! * 0.025,Colors.green),
            onTap: () => _onDetailItemSelected(index),
          ),
        );
      },
    );
  }
  void _onDetailItemSelected(int index) {
    setState(() {
      selectedCustomer = _detail_Customer[index];
      _detail_Customer = [];
      if(searchResults.isNotEmpty) {
        final cartCubit = context.read<CartCubit>();
        cartCubit.addToCart(
          searchResults[index],
          1,
          type: CartType.main,
        );
      }
    });
  }
}
