import 'package:PixiDrugs/ReturnCart/ReturnCartCustomer.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/search/customerModel.dart';
import 'package:PixiDrugs/search/sellerModel.dart';
import '../BarcodeScan/barcode_screen_page.dart';
import '../BarcodeScan/batch_scanner_page.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import 'ReturnCartStockiest.dart';
import '../StockReturn/PurchaseReturnModel.dart';
import 'ReturnProductList.dart';

class ReturnCartTab extends StatefulWidget {
  CartTypeSelection? cartTypeSelection;
  dynamic returnModel;
  bool detail;

  ReturnCartTab({
    Key? key,
    required this.cartTypeSelection,
    this.returnModel,
    this.detail = false,
  }) : super(key: key);

  @override
  _ReturnCartTabState createState() => _ReturnCartTabState();
}

class _ReturnCartTabState extends State<ReturnCartTab> {
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();
  List<Seller> _detail_Seller = [];
  List<CustomerModel> _detail_Customer = [];
  Seller? selectedSeller;
  CustomerModel? selectedCustomer;
  List<InvoiceItem> searchResults = [];
  String userId = '';
  String extractedBatchNumber = '';
  bool edit = false;
  int clickFlag=0;

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().clearCart(type: CartType.barcode);
    _loadUserId();
    _searchController.addListener(_onSearch);
  }

  Future<void> _loadUserId() async {
    final id = await SessionManager.getParentingId();
    setState(() {
      userId = id ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<CartCubit>().clearCart(type: CartType.barcode);
        return true; // allow popping
      },
      child: Scaffold(
        backgroundColor: AppColors.kPrimary,
        body: BlocListener<ApiCubit, ApiState>(
          listener: (context, state) {
            if (state is BarcodeScanLoaded) {
              searchResults = state.list;
              if (searchResults.isNotEmpty) {
                final cartCubit = context.read<CartCubit>();
                if((clickFlag==2 || clickFlag==3) && (cartCubit.state.barcodeCartItems.isEmpty || cartCubit.state.barcodeCartItems.first.sellerId==searchResults.first.sellerId)) {
                  cartCubit.addToCart(
                    searchResults.first,
                    1,
                    type: CartType.barcode,
                  );
                  if (widget.cartTypeSelection ==
                      CartTypeSelection.StockiestReturn) {
                    setState(() {

                      selectedSeller = Seller(
                        id: searchResults.first.sellerId ?? 0,
                        sellerName: searchResults.first.sellerName ?? '',
                        phone: searchResults.first.sellerPhone ?? '',
                        address: '',
                        gstNo: '', // or from cart item if available
                      );
                    });
                  }
                }else if((clickFlag==2 || clickFlag==3) && cartCubit.state.barcodeCartItems.first.sellerId!=searchResults.first.sellerId){
                  AppUtils.showSnackBar(context, 'Different Seller Item');
                }
              } else {
                AppUtils.showSnackBar(context, 'No products found.');
              }
            } else if (state is BarcodeScanError) {
              AppUtils.showSnackBar(context, state.error);
            }
            if (state is CustomerBarcodeScanLoaded ) {
              searchResults = state.list;
              final cartCubit = context.read<CartCubit>();
            if(searchResults.isNotEmpty){
              if ((clickFlag==2 || clickFlag==3) && cartCubit.state.cartItems.isEmpty && selectedCustomer==null) {
                setState(() {
                  for(var item in searchResults){
                    var customer = CustomerModel(
                      id: item.customerId ?? 0,
                      name: item.customerName ?? '',
                      phone: item.customerPhone ?? '',
                      address: '',
                    );
                    _detail_Customer.add(customer);
                  }

                });
              } else if ((clickFlag==2 || clickFlag==3)){
                cartCubit.addToCart(
                  searchResults.first,
                  1,
                  type: CartType.barcode,
                );
              }
            } else {
                AppUtils.showSnackBar(context, 'No products found.');
            }
            } else if (state is CustomerBarcodeScanError) {
              AppUtils.showSnackBar(context, state.error);
            } else if (state is SearchSellerLoaded) {
              setState(() {
                _detail_Seller.clear();
                _detail_Seller.addAll(state.sellerList);
              });
            } else if (state is SearchSellerError) {
              // AppUtils.showSnackBar(context,state.error);
            } else if (state is SearchUserLoaded) {
              setState(() {
                _detail_Customer.clear();
                _detail_Customer.addAll(state.customerList);
              });
            } else if (state is SearchUserError) {
              // AppUtils.showSnackBar(context,state.error);
            }
          },
          child: Column(
            children: [
              cartAppBar(context),
              Expanded(
                child: Builder(
                  builder: (_) {
                    final hasSearchText = _searchController.text.isNotEmpty;

                    // 🔍 Show search results
                    if (hasSearchText || _detail_Customer.isNotEmpty) {
                      print("Showing search results...");
                      return _buildSearchResultList();
                    }

                    if ( selectedSeller != null ||
                        selectedCustomer != null ||
                        widget.returnModel != null) {
                      return _buildReturnContent(context);
                    } else {
                      return _buildReturnPage();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReturnContent(BuildContext context) {
    final isStockist =
        widget.cartTypeSelection == CartTypeSelection.StockiestReturn;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Container(
          color: AppColors.kPrimary,
          child:
              isStockist
                  ? ReturnCartStockiest(
                    key: ValueKey(edit),
                    cartTypeSelection: widget.cartTypeSelection,
                    purchaseReturnModel: widget.returnModel,
                    edit: edit,
                    detail: widget.detail,
                    returnDetail: widget.detail?null:selectedSeller,
                    onSellerUpdated: (Seller seller) {
                      setState(() {
                        selectedSeller = seller;
                      });
                    },
                  )
                  : ReturnCartCustomer(
                    key: ValueKey(edit),
                    customerReturnModel: widget.returnModel,
                    edit: edit,
                    detail: widget.detail,
                    returnDetail: widget.detail?null:selectedCustomer!,
                    onCustomerUpdated: (CustomerModel customer) {
                      setState(() {
                        selectedCustomer = customer;
                      });
                    },
                  ),
        );
      },
    );
  }

  Widget _buildReturnPage() {
    var name =
        widget.cartTypeSelection == CartTypeSelection.StockiestReturn
            ? 'stockist'
            : 'customer';
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.screenWidth! * 0.07),
          topRight: Radius.circular(SizeConfig.screenWidth! * 0.07),
        ),
      ),
      child: NoItemPage(
        onTap: _searchDetail,
        image: AppImages.empty_cart,
        tittle: "Enter Return Details",
        description:
            "Search by $name name to process the return. and\n also search through invoice or bill no. ",
        button_tittle: '',
      ),
    );
  }

  Future<void> _searchDetail() async {}

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search ${widget.cartTypeSelection == CartTypeSelection.StockiestReturn ? "stockist" : "customer"} name...',
                  hintStyle: MyTextfield.textStyle(
                    16,
                    Colors.grey,
                    FontWeight.w300,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            _searchController.text.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      selectedSeller = null;
                      selectedCustomer = null;
                      _detail_Seller = [];
                      _detail_Customer = [];
                    });
                  },
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  void _onSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchController.text.trim();

      if (query.length >= 3) {
        setState(() {
          selectedSeller = null;
          selectedCustomer = null;
        });

        if (widget.cartTypeSelection == CartTypeSelection.StockiestReturn) {
          context.read<ApiCubit>().SearchSellerDetail(
            query: query,
            storeId: userId,
          );
        } else if (widget.cartTypeSelection ==
            CartTypeSelection.CustomerReturn) {
          context.read<ApiCubit>().SearchCustomerDetail(
            query: query,
            storeId: userId,
          );
        }
      }
    });
  }

  // dispose
  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildSearchResultList() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.screenWidth! * 0.07),
          topRight: Radius.circular(SizeConfig.screenWidth! * 0.07),
        ),
      ),
      child: _searchResultWidget(),
    );
  }

  Widget _searchResultWidget() {
    final isStockist = widget.cartTypeSelection == CartTypeSelection.StockiestReturn;
    final list = isStockist ? _detail_Seller : _detail_Customer;

    print("Showing ${list.length} search results");

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:MyTextfield.textStyle_w600('No results found', SizeConfig.screenWidth! * 0.055,AppColors.kPrimary)
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        final displayName = isStockist
            ? _detail_Seller[index].sellerName
            : _detail_Customer[index].name;
        final phone = isStockist
            ? _detail_Seller[index].phone
            : _detail_Customer[index].phone;

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
      _searchController.clear();

      if (widget.cartTypeSelection == CartTypeSelection.StockiestReturn) {
        selectedSeller = _detail_Seller[index];
        _detail_Seller = [];
      } else {
        selectedCustomer = _detail_Customer[index];
        _detail_Customer = [];
        if(searchResults.isNotEmpty) {
          final cartCubit = context.read<CartCubit>();
          cartCubit.addToCart(
            searchResults[index],
            1,
            type: CartType.barcode,
          );
        }
      }
    });
  }

  /// Initiates barcode scan
  Future<void> _scanBarcode() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BarcodeScannerPage()),
      );
      if (result.isNotEmpty) {
        widget.cartTypeSelection == CartTypeSelection.StockiestReturn
            ? context.read<ApiCubit>().BarcodeScan(
              code: result,
              storeId: userId,
              seller_id:selectedSeller!=null?selectedSeller!.id.toString():''
            )
            : context.read<ApiCubit>().customerbarcode(
              code: result,
              storeId: userId,
              customer_id:selectedCustomer!=null?selectedCustomer!.id.toString():''
            );
      }
    } catch (e) {
      AppUtils.showSnackBar(context, 'Failed to scan barcode');
    }
  }

  Future<void> scanBatchNumber() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BatchScannerPage()),
      );
      if (result.isNotEmpty) {
        _showManualEntryBottomSheet(result);
      }
    } catch (e) {
      //AppUtils.showSnackBar(context,'Failed to scan');
    }
  }

  void _showManualEntryBottomSheet(String batchNumber) {
    showDialog(
      context: context,
      builder:
          (_) => EditValueDialog(
            title: 'Batch No.',
            initialValue: batchNumber,
            onSave: (value) {
              setState(() {
                extractedBatchNumber = value;
              });
              widget.cartTypeSelection == CartTypeSelection.StockiestReturn
                  ? context.read<ApiCubit>().BarcodeScan(
                  code: extractedBatchNumber,
                  storeId: userId,
                  seller_id:selectedSeller!=null?selectedSeller!.id.toString():''
              )
                  : context.read<ApiCubit>().customerbarcode(
                  code: extractedBatchNumber,
                  storeId: userId,
                  customer_id:selectedCustomer!=null?selectedCustomer!.id.toString():''
              );
            },
          ),
    );
  }

  Widget cartAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Container(
        width: double.infinity,
        color: AppColors.kPrimary,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<CartCubit>().clearCart(
                              type: CartType.barcode,
                            );
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            AppImages.back,
                            height: 24,
                            color: AppColors.kWhiteColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        MyTextfield.textStyle_w600(
                          'Return Cart',
                          SizeConfig.screenWidth! * 0.055,
                          Colors.white,
                        ),
                      ],
                    ),
                  ),
                  if (widget.returnModel != null)
                    IconButton(
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
                ],
              ),

              if (!widget.detail) _buildSearchBar(),
              if (edit || !widget.detail) const SizedBox(height: 5),

              if (edit || !widget.detail)
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        MyChipWithIconWidget(
                          color: AppColors.kPrimaryLight,
                          icon: Icons.browse_gallery,
                          text: 'Pick Image',
                          textColor: AppColors.kPrimary,
                          onPressed: () {
                            clickFlag=3;
                            scanBatchNumber();
                          },
                        ),
                        const SizedBox(width: 8),
                        MyChipWithIconWidget(
                          color: AppColors.kPrimaryLight,
                          icon: Icons.qr_code_scanner,
                          text: 'Scan Barcode',
                          textColor: AppColors.kPrimary,
                          onPressed: () {
                            clickFlag=2;
                            _scanBarcode();
                          },
                        ),
                        const SizedBox(width: 8),
                        MyChipWithIconWidget(
                          color: AppColors.kPrimaryLight,
                          icon: Icons.edit,
                          text: 'Add Manually',
                          textColor: AppColors.kPrimary,
                          onPressed: () {
                            clickFlag=1;
                            AddManualClick();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
  void AddManualClick() {
    if (widget.cartTypeSelection == CartTypeSelection.StockiestReturn && edit && widget.returnModel != null) {
      selectedSeller = Seller(
        id: (widget.returnModel as PurchaseReturnModel).sellerId ?? 0,
        sellerName: (widget.returnModel as PurchaseReturnModel).sellerName??'',
        phone: (widget.returnModel as PurchaseReturnModel).phone ?? '',
        address: '',
        gstNo: '', // or from cart item if available
      );
    } else if (widget.cartTypeSelection == CartTypeSelection.CustomerReturn && edit && widget.returnModel != null) {
      selectedCustomer = CustomerModel(
        id:(widget.returnModel as CustomerReturnsResponse).customer.id ?? 0,
        name: (widget.returnModel as CustomerReturnsResponse).customer.name ?? '',
        phone: (widget.returnModel as CustomerReturnsResponse).customer.phone ?? '',
        address: '',
      );
    }

    print('API${selectedSeller?.sellerName}/${selectedCustomer?.name}.');
    AppRoutes.navigateTo(
      context,
      ReturnProductListPage(
        cartTypeSelection: widget.cartTypeSelection,
        selectedSeller: selectedSeller,
        selectedCustomer: selectedCustomer,
        onSellerSelected: (updatedSeller) {
          setState(() {
            selectedSeller = updatedSeller;
          });
        },
        onCustomerSelected: (updatedCustomer) {
          setState(() {
            selectedCustomer = updatedCustomer;
          });
        },
      ),
    );
  }
}