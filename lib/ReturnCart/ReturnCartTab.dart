
import 'package:PixiDrugs/ReturnCart/ReturnCartCustomer.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/search/customerModel.dart';
import 'package:PixiDrugs/search/sellerModel.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../BarcodeScan/barcode_screen_page.dart';
import '../BarcodeScan/batch_scanner_page.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../Stock/ProductList.dart';
import '../ReturnCart/ReturnCartStockiest.dart';
import '../StockReturn/PurchaseReturnModel.dart';

class ReturnCartTab extends StatefulWidget {
  CartTypeSelection? cartTypeSelection;
  dynamic returnModel;
  bool detail;
  ReturnCartTab({
    Key? key, required this.cartTypeSelection, this.returnModel,this.detail=false
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
  String userId='';
  final ImagePicker _picker = ImagePicker();
  String extractedBatchNumber = '';
  bool edit =false;
  PurchaseReturnModel? stockiest_item;
  CustomerReturnsResponse? customer_item;
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
      child:Scaffold(
        backgroundColor: AppColors.kPrimary,
        body: BlocListener<ApiCubit, ApiState>(
          listener: (context, state) {
            if (state is BarcodeScanLoaded && state.source=='scan') {
              searchResults = state.list;
              if (searchResults.isNotEmpty) {
                final cartCubit = context.read<CartCubit>();
                cartCubit.addToCart(searchResults.first, 1, type: CartType.barcode);
              } else {
                AppUtils.showSnackBar(context,'No products found.');
              }
            } else if (state is BarcodeScanError) {
              AppUtils.showSnackBar(context,state.error);
            }else if (state is SearchSellerLoaded) {
              setState(() {
                _detail_Seller.clear();
                _detail_Seller.addAll(state.sellerList);
              });
            }else if (state is SearchSellerError) {
              // AppUtils.showSnackBar(context,state.error);
            }else if (state is SearchUserLoaded) {
              setState(() {
                _detail_Customer.clear();
                _detail_Customer.addAll(state.customerList);
              });
            }else if (state is SearchUserError) {
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
                    final hasSelection = selectedSeller != null || selectedCustomer != null || widget.returnModel!=null;

                    // 🔍 Show search results
                    if (hasSearchText && !hasSelection) {
                      print("Showing search results...");
                      return _buildSearchResultList();
                    }

                    if (hasSelection) {
                      return _buildReturnContent(context);
                    }else {
                      return _buildReturnPage();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget buildActionButton(IconData icon, String label,int flag) {

    return GestureDetector(
      onTap: (){
        if(flag==1) {
          AppRoutes.navigateTo(context,ProductListPage(flag: 4,selectedSeller:selectedSeller,selectedCustomer:selectedCustomer));
        }else if(flag==2) {
          _scanBarcode();
        }else if(flag==3){
          scanBatchNumber();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.kPrimary,size: 14,),
            const SizedBox(width: 1),
            MyTextfield.textStyle_w600(label, 16, AppColors.kPrimary),
          ],
        ),
      ),
    );
  }
  Widget _buildReturnContent(BuildContext context) {
    final isStockist = widget.cartTypeSelection == CartTypeSelection.StockiestReturn;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Container(
            color: AppColors.kPrimary,
            child: isStockist?ReturnCartStockiest(
                key: ValueKey(edit),
                cartTypeSelection:widget.cartTypeSelection,
                purchaseReturnModel: widget.returnModel,
                edit:edit,
                detail:widget.detail,
                returnDetail:widget.detail?null:selectedSeller!):
            ReturnCartCustomer(
                key: ValueKey(edit),
                cartTypeSelection:widget.cartTypeSelection,
                customerReturnModel: widget.returnModel,
                edit:edit,
                detail:widget.detail,
                returnDetail:widget.detail?null:selectedCustomer!));
      },
    );
  }
  Widget _buildReturnPage() {
    var name=widget.cartTypeSelection==CartTypeSelection.StockiestReturn?'stockist':'customer';
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
        description: "Search by $name name to process the return. and\n also search through invoice or bill no. ",
        button_tittle: '',
      ),
    );
  }
  Future<void> _searchDetail() async {

  }
  Widget _buildSearchBar() {
    return  Padding(
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
                  hintText: 'Search ${widget.cartTypeSelection == CartTypeSelection.StockiestReturn ? "stockist" : "customer"} name...',
                  hintStyle: MyTextfield.textStyle(16 ,Colors.grey,FontWeight.w300),
                  border: InputBorder.none,
                ),
              ),
            ),
            _searchController.text.isNotEmpty?IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  selectedSeller = null;
                  selectedCustomer = null;
                  _detail_Seller = [];
                  _detail_Customer = [];
                });
              },
              icon: const Icon(Icons.clear_rounded,
                  color: Colors.grey),
            ):SizedBox(),
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

        if(widget.cartTypeSelection == CartTypeSelection.StockiestReturn) {
          context.read<ApiCubit>().SearchSellerDetail(query: query,storeId: userId);
        } else if(widget.cartTypeSelection == CartTypeSelection.CustomerReturn) {
          context.read<ApiCubit>().SearchCustomerDetail(query: query,storeId: userId);
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
      child:  _searchResultWidget(),
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
          child: Text(
            'No results found',
            style: TextStyle(color: AppColors.kPrimary, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final displayName = isStockist
            ? _detail_Seller[index].sellerName
            : _detail_Customer[index].name;
        final phone = isStockist
            ? _detail_Seller[index].phone
            : _detail_Customer[index].phone;

        return ListTile(
          title: Text(displayName ?? '', style: TextStyle(color:AppColors.kPrimary)),
          subtitle: Text(phone ?? '', style: TextStyle(color: AppColors.kPrimary)),
          onTap: () => _onDetailItemSelected(index),
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
        context.read<ApiCubit>().BarcodeScan(code: result,storeId: userId,
            seller_id:selectedSeller?.id.toString()??'',
            customer_id:selectedCustomer?.id.toString()??'');
      }
    } catch (e) {
      AppUtils.showSnackBar(context,'Failed to scan barcode');
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
  Future<void> scanBatchNumberOld() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    final List<String> allLines = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final lineText = line.text.trim();
        allLines.add(lineText);
        print('Recognized line: $lineText');
      }
    }

    String? batchNumber;

    final labelPattern = RegExp(
      r'\b(?:b[\.\s]*no[\.\s]*|batch(?:\s+no[\.\s]*)?)[:\s]*([A-Za-z0-9\-\/]{4,})?',
      caseSensitive: false,
    );
    final valuePattern = RegExp(r'^[A-Za-z0-9\-\/]{4,}$');

    for (int i = 0; i < allLines.length; i++) {
      final line = allLines[i];

      final labelMatch = labelPattern.firstMatch(line);
      if (labelMatch != null) {
        // Case 1: Value is on the same line
        final sameLineValue = labelMatch.group(1);
        if (sameLineValue != null && sameLineValue.trim().isNotEmpty) {
          batchNumber = sameLineValue.trim();
          print("Batch number found on same line: $batchNumber");
          break;
        }

        // Case 2: Look ahead in the next 1–3 lines
        for (int j = 1; j <= 10 && (i + j) < allLines.length; j++) {
          final nextLine = allLines[i + j].trim();
          if (valuePattern.hasMatch(nextLine)) {
            batchNumber = nextLine;
            print("Batch number found in next lines: $batchNumber");
            break;
          }
        }
      }

      if (batchNumber != null) break;
    }

    await textRecognizer.close();

    if (batchNumber != null && batchNumber.isNotEmpty) {
      _showManualEntryBottomSheet(batchNumber);
    } else {
      AppUtils.showSnackBar(context,'Batch number not found');
      _showManualEntryBottomSheet('');
    }
  }

  void _showManualEntryBottomSheet(String batchNumber) {
    showDialog(
      context: context,
      builder: (_) => EditValueDialog(
        title: 'Batch No.',
        initialValue:batchNumber,
        onSave: (value) {
          setState(() {
            extractedBatchNumber = value;
          });
          context.read<ApiCubit>().BarcodeScan(
              code: extractedBatchNumber,
              storeId: userId,
              source: 'scan',seller_id:selectedSeller?.id.toString()??'',customer_id:selectedCustomer?.id.toString()??''
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
                            context.read<CartCubit>().clearCart(type: CartType.barcode);
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
                      icon: const Icon(Icons.edit, color: AppColors.kWhiteColor, size: 30),
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
              if(selectedSeller != null || selectedCustomer != null || edit)
              const SizedBox(height: 5),
              if(selectedSeller != null || selectedCustomer != null || edit)
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        buildActionButton(Icons.edit, 'Add Manually', 1),
                        const SizedBox(width: 8),
                        buildActionButton(Icons.qr_code_scanner, 'Scan Barcode',2),
                        const SizedBox(width: 8),
                        buildActionButton(Icons.browse_gallery, 'Pick Image', 3),
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
}
