import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Api/app_initialization_service.dart';
import 'package:intl/intl.dart';
import '../Home/HomePageScreen.dart';
import '../ReturnProduct/ReturnPdfGenerator.dart';
import '../ReturnProduct/ReturnStockiestCart.dart';
import '../ReturnStock/PurchaseReturnModel.dart';
import '../../constant/all.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/CustomPopupMenuItemData.dart';
import '../customWidget/GradientInitialsBox.dart';
import 'FilterWidget.dart';

class StockistReturnScreen extends StatefulWidget {

  const StockistReturnScreen({Key? key}) : super(key: key);

  @override
  State<StockistReturnScreen> createState() => _StockistReturnScreenState();
}

class _StockistReturnScreenState extends State<StockistReturnScreen> with WidgetsBindingObserver, RouteAware {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  String? role;
  UserProfile? user;

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isRefresh = false;

  final stockistReturnList = <PurchaseReturnModel>[];

  DateTime? fromDate;
  DateTime? toDate;
  String selectedRange = '';
  String selectedPaymentType = '';
  String selectedPaymentReason = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearch);
    _scrollController.addListener(_onScroll);
    _fetchRecord(refresh: true);
  }
  Future<void> _loadUserRole() async {
    role = await AppInitializationService.getRole();
   user=AppInitializationService.getCachedProfile(context);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      _fetchRecord();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("API=resume");
      //_fetchRecord(refresh: true);
    }
  }

  /* @override
  void didPopNext() => _fetchRecord();*/

  Future<void> _fetchRecord({bool refresh = false}) async {
    final userId = await SessionManager.getParentingId();
    if (userId == null) return;

    if (refresh) {
      currentPage = 1;
      hasMoreData = true;
      isRefresh=true;
    }

    if (isLoadingMore || !hasMoreData) return;

    setState(() => isLoadingMore = true);

    String? from = fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : null;
    String? to = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : null;

    await context.read<ApiCubit>().fetchStockReturnList(store_id: userId, page: currentPage,from:from??'',to:to??'',reason:selectedPaymentReason,filter: searchQuery);
    setState(() => isLoadingMore = false);
  }

  void _updatePaginatedList<T extends Object>(
      List<T> targetList,
      List<T> newItems,
      int lastPage,
      ) {
    if (isRefresh) {
      targetList.clear();
      isRefresh = false;
    }

    for (var newItem in newItems) {
      final index = targetList.indexWhere((oldItem) {
        if (oldItem is Invoice && newItem is Invoice) {
          return oldItem.id == newItem.id; // ✅ compare by unique ID
        }
        return oldItem == newItem; // fallback for other types
      });

      if (index >= 0) {
        // Item already exists → check if changed
        if (targetList[index] != newItem) {
          targetList[index] = newItem; // ✅ replace with updated one
        }
      } else {
        // Item not found → add it
        targetList.add(newItem);
      }
    }

    hasMoreData = lastPage > currentPage;
    if (hasMoreData) currentPage++;
  }


  void _showDeleteDialog(BuildContext context, int id) {
    CommonConfirmationDialog.show<String>(
      context: context,
      id: id.toString(),
      title: 'Delete this Record?',
      content: 'Are you sure you want to delete this record?',
      onConfirmed: (_) => _deleteRecord(id),
    );
  }

  void _deleteRecord(int id) async {
    /* try {

      final apiCubit = context.read<ApiCubit>();
      await apiCubit.InvoiceDelete(invoice_id: id.toString());
      saleReturnList.removeWhere((inv) => inv.id == id);
      AppUtils.showSnackBar(context, "Record deleted successfully");
      setState(() {});
    } catch (e) {
      AppUtils.showSnackBar(context, "Failed to delete record: $e");
    }*/
  }
  // ---- Build Method ----

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocBuilder<ApiCubit, ApiState>(
        builder: (context, state) {
          final isLoading = state is StockReturnListLoading;

          // Populate lists from state
          if (state is StockReturnListLoaded) {
            _updatePaginatedList(stockistReturnList, state.returnList, state.last_page);
          }else if (state is UserProfileLoaded) {
            user = state.userModel.user;
          }

          return Container(
            color: AppColors.kPrimary,
            padding: EdgeInsets.only(top: screenWidth * 0.06),
            child: Column(
              children: [
                _buildTopBar(screenWidth),
                SizedBox(height: screenWidth * 0.01,),
                _buildSearchBar(screenWidth),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchRecord(refresh: true),
                    color: AppColors.kPrimary,
                    backgroundColor: AppColors.kPrimaryLight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.myGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.07),
                          topRight: Radius.circular(screenWidth * 0.07),
                        ),
                      ),
                      child:(isLoading || isRefresh) && stockistReturnList.isEmpty?
                      Center(
                        child: SpinKitThreeBounce(
                          color:AppColors.kPrimary,
                          size: 30.0,
                        ),
                      )
                          : (!isLoading && !isRefresh) && stockistReturnList.isEmpty
                          ? NoItemPage(
                        onTap: (){},
                        image: AppImages.no_sale,
                        tittle: 'No Stock Return Found',
                        description: 'No stock StockReturn entries available. Upload invoices or create a StockReturn entry to get started.',
                        button_tittle: '',
                      )
                          : _buildListBody(isLoading),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildTopBar(double screenWidth) {
    return Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.02,right: screenWidth * 0.02),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
                    (route) => false,
              ),
            ),
            Expanded(
              child: MyTextfield.textStyle_w400(
                'Stock Return List',
                screenWidth * 0.052,
                Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: _showFilterTopSheet,
            )
          ],
        ));
  }
  void _showFilterTopSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
            color: AppColors.kWhiteColor,
            child: Container(
              width: double.infinity,
              child: FilterWidget(
                  type:ListType.stockReturn,
                  initialFrom: fromDate,
                  initialTo: toDate,
                  initialRange: selectedRange,
                  initialPaymentType:selectedPaymentType,
                  initialPaymentReason: selectedPaymentReason,
                  onApply: (from, to, range, paymentType,paymentReason) async {
                    setState(() {
                      fromDate = from;
                      toDate = to;
                      selectedRange = range;
                      selectedPaymentType = paymentType??'';
                      selectedPaymentReason = paymentReason??'';
                    });
                    await _fetchRecord(refresh: true);
                    if (mounted) Navigator.pop(context);
                  },
                  onReset:() async {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                      selectedRange = '';
                      selectedPaymentType = '';
                      selectedPaymentReason='';
                    });
                    await _fetchRecord(refresh: true);
                    if (mounted) Navigator.pop(context);
                  }
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1),  // start above the screen
            end: Offset(0, 0),     // slide to original position
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }
  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.03,right: screenWidth * 0.03,bottom:screenWidth * 0.03 ),
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
                  hintText: 'Search by supplier name',
                  hintStyle: MyTextfield.textStyle(
                      16, Colors.grey, FontWeight.w300),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                onPressed: _onclearTap,
                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
  void _onSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    setState(() {}); // show clear button

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchController.text.trim();

      if (query.length >= 3 || query.isEmpty) {
        if (query != searchQuery) {
          setState(() {
            searchQuery = query;
          });
        }
        _fetchRecord(refresh: true);
      }
    });
  }

  Future<void> _onclearTap() async {
    setState(() {
      _searchController.clear();
      searchQuery='';
    });
    _fetchRecord(refresh: true);
  }
  Widget _buildListBody(bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = stockistReturnList.length + (hasMoreData ? 1 : 0);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == itemCount-1 && hasMoreData) {
            return BottomLoader();
          }
          return _buildStockReturnCard(stockistReturnList[index], screenWidth,context);
        },
      ),
    );
  }

  Widget _buildStockReturnCard(PurchaseReturnModel item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        GoNextPageFun(items:item);
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            children: [
              GradientInitialsBox(
                size: screenWidth * 0.15,
                name: item.sellerName!,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.sellerName!,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('Dt: ${item.returnDate}',screenWidth * 0.035,Colors.grey.shade700,maxLines: true),
                    MyTextfield.textStyle_w600("Return item: ${item.items.length}", screenWidth * 0.035, Colors.green),
                    MyTextfield.textStyle_w600("Reason: ${item.reason}", screenWidth * 0.035, Colors.redAccent),
                    SizedBox(height: screenWidth * 0.01)
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomPopupMenu(
                    iconSize: screenWidth * 0.05,
                    backgroundColor: AppColors.kWhiteColor,
                    onSelected: (value) {
                      switch (value) {
                        case 'share':
                          ReturnPdfGenerator.generateStockReturnPdf(user!, stockReturn: item,share: true);
                          break;
                        case 'edit':
                          GoNextPageFun(items:item,edit: true);
                          break;
                        case 'download':
                          ReturnPdfGenerator.generateStockReturnPdf(user!, stockReturn: item,share: false);
                          break;
                      }
                    },
                    items: [
                      CustomPopupMenuItemData(
                        value: 'share',
                        label: 'Share',
                        iconAsset: AppImages.share,
                      ),
                      CustomPopupMenuItemData(
                        value: 'download',
                        label: 'Download',
                        iconAsset: AppImages.download,
                      ),
                      CustomPopupMenuItemData(
                        value: 'edit',
                        label: 'Edit',
                        iconAsset: AppImages.edit,
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Builder(
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        child: MyTextfield.textStyle_w600(
                          "₹${item.totalAmount}",
                          screenWidth * 0.04,
                          Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> GoNextPageFun({bool edit=false, required PurchaseReturnModel items}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReturnStockiestCart(purchaseReturnModel:items,detail: true,)),
    );
    if (result==true) {
      _fetchRecord(refresh: true);
    }
  }
}
