import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:intl/intl.dart';
import '../Cart/ReceiptPrinterPage.dart';
import '../Cart/ReceiptPdfGenerator.dart';
import '../Home/HomePageScreen.dart';
import '../SaleList/sale_details.dart';
import '../SaleList/sale_model.dart';
import '../constant/all.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/CustomPopupMenuItemData.dart';
import '../customWidget/GradientInitialsBox.dart';
import '../ListPageScreen/FilterWidget.dart';

class Salereportscreen extends StatefulWidget {
  final bool? topDebitor;
  const Salereportscreen({Key? key,this.topDebitor=false}) : super(key: key);

  @override
  State<Salereportscreen> createState() => _SalereportscreenState();
}

class _SalereportscreenState extends State<Salereportscreen> with WidgetsBindingObserver, RouteAware {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  String? role;

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isRefresh = false;

  final saleList = <SaleModel>[];
  List<Map<String, dynamic>> summaryItems=[];

  DateTime? fromDate;
  DateTime? toDate;
  String selectedRange = '';
  String selectedPaymentType = '';
  String selectedPaymentReason = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  UserProfile? user;

  @override
  void initState() {
    super.initState();
    if(widget.topDebitor==true){
      selectedPaymentType='Due';
    }
    _GetProfileCall();
    _loadUserRole();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearch);
    _scrollController.addListener(_onScroll);
    _fetchRecord(refresh: true);
  }
  Future<void> _loadUserRole() async {
    role = await SessionManager.getRole();
    if (mounted) setState(() {});
  }
  void _GetProfileCall() async {
    String? userId = await SessionManager.getParentingId();
    if (userId != null) {
      context.read<ApiCubit>().GetUserData(userId: userId, useCache: false);
    }
    context.read<ApiCubit>().stream.listen((state) {
      if (state is UserProfileLoaded) {
        setState(() {
          user=state.userModel.user;
        });
      }
    });
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
    final apiCubit = context.read<ApiCubit>();

    String? from = fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : null;
    String? to = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : null;

    await apiCubit.fetchSaleList(user_id: userId,page: currentPage,from:from??'',to:to??'',payment_type:selectedPaymentType.toLowerCase(),filter: searchQuery);
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
      title: 'Delete Sale Record?',
      content: 'Are you sure you want to delete this Sale record?',
      onConfirmed: (_) => _deleteRecord(id),
    );
  }

  void _deleteRecord(int id) async {
    try {

      final apiCubit = context.read<ApiCubit>();
      await apiCubit.SaleDelete(billing_id: id.toString());
      saleList.removeWhere((sale) => sale.invoiceNo == id);
      AppUtils.showSnackBar(context, "Record deleted successfully");
      setState(() {});
    } catch (e) {
      AppUtils.showSnackBar(context, "Failed to delete record: $e");
    }
  }

  // ---- Build Method ----

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocBuilder<ApiCubit, ApiState>(
        builder: (context, state) {
          if (state is UserProfileLoaded) {
            user=state.userModel.user;
          }
          final isLoading = state is SaleListLoading;

          // Populate lists from state
           if (state is SaleListLoaded) {
             final total=state.totals['cash']+state.totals['upi']+state.totals['due'];
            summaryItems = [
              {"title": 'Cash', "value": state.totals['cash']},
              {"title": 'Online', "value": state.totals['upi']},
              {"title": 'Due', "value":state.totals['due']},
              {"title": 'Total', "value":total},
            ];
            _updatePaginatedList(saleList, state.saleList, state.last_page);
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
                      child:(isLoading || isRefresh) && saleList.isEmpty?
                      Center(child: CircularProgressIndicator(color: AppColors.kPrimary))
                      : (!isLoading && !isRefresh) && saleList.isEmpty
                          ? NoItemPage(
                        onTap: (){},
                        image: AppImages.no_sale,
                        tittle: 'No Sale Record Found',
                        description: "Please add important details about the sale such as customer name, products, quantity, total amount, and payment status.",
                        button_tittle: /*'Add Sale Record'*/'',
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
                'Sale List',
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
                  type:ListType.sale,
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
                    _fetchRecord(refresh: true);
                    Navigator.pop(context);
                  },
                  onReset:() async {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                      selectedRange = '';
                      selectedPaymentType = '';
                      selectedPaymentReason='';
                    });
                    _fetchRecord(refresh: true);
                    Navigator.pop(context);
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
                  hintText: 'Search by customer name/mobile no.',
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
    final itemCount = 1 + saleList.length + (hasMoreData ? 1 : 0);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Summary grid
            return Padding(
              padding: const EdgeInsets.all( 8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 3 : 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: screenWidth < 360 ? 3.2 : 2.2,
                ),
                itemCount: summaryItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, summaryIndex) {
                  final item = summaryItems[summaryIndex];
                  return _buildSummaryContainer(item['title'], item['value']);
                },
              ),
            );
          } else if (index == itemCount - 1 && hasMoreData) {
            return BottomLoader();
          } else {
            final sale = saleList[index - 1];
            return _buildSaleCard(sale, screenWidth, context);
          }
        },
      ),
    );
  }

  Widget _buildSummaryContainer(String title, dynamic value) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: title=='Cash'?Colors.green:title=='Online'?Colors.orange:title=='Due'?Colors.red:Colors.teal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyTextfield.textStyle_w600(
              '₹$value',
              screenWidth * 0.055,
              Colors.white),
          MyTextfield.textStyle_w400(
              title,
              screenWidth * 0.045,
              Colors.white),
        ],
      ),
    );
  }
  Widget _buildSaleCard(sale, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SaleDetailsPage(sale: sale, edit: false),),
        );
        if (result==true) {
          _fetchRecord(refresh: true);
        }
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
                name: sale.customer.name,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(sale.customer.name,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    sale.customer.phone.isNotEmpty && sale.customer.phone!='no number'?
                    MyTextfield.textStyle_w400('Mob: ${sale.customer.phone}',screenWidth * 0.035,Colors.green.shade700):
                    MyTextfield.textStyle_w400('Email: ${sale.customer.email}',screenWidth * 0.035,Colors.deepOrange.shade700),
                    MyTextfield.textStyle_w400('Bill No. #${sale.invoiceNo!}',screenWidth * 0.035,Colors.grey.shade700),
                    MyTextfield.textStyle_w400('Dt.${sale.date!}',screenWidth * 0.035,Colors.grey.shade700),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w600("₹${sale.totalAmount}",screenWidth * 0.049,Colors.green),
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
                        case 'print':
                          AppRoutes.navigateTo(context, ReceiptPrinterPage(sale: sale));
                          break;
                        case 'share':
                          ReceiptPdfGenerator.generateAndSharePdf(context, sale,user!);
                          break;
                        case 'edit':
                          AppRoutes.navigateTo(context, SaleDetailsPage(sale: sale, edit: true));
                          break;
                        case 'delete':
                          _showDeleteDialog(context, sale.invoiceNo!);
                          break;
                      /*case 'download':
                          ReceiptPdfGenerator.generateAndSharePdf(context, sale);
                          break;*/
                      }
                    },
                    items: [
                      CustomPopupMenuItemData(
                        value: 'print',
                        label: 'Print Bill',
                        iconAsset: AppImages.printer,
                      ),
                      if (sale.customer.phone.isNotEmpty && sale.customer.phone != 'no number')
                        CustomPopupMenuItemData(
                          value: 'share',
                          label: 'Share',
                          iconAsset: AppImages.share,
                        ),
                      /* CustomPopupMenuItemData(
                        value: 'download',
                        label: 'Download',
                        iconAsset: AppImages.download,
                      ),*/
                      CustomPopupMenuItemData(
                        value: 'edit',
                        label: 'Edit',
                        iconAsset: AppImages.edit,
                      ),
                      if (role == 'owner')
                        CustomPopupMenuItemData(
                          value: 'delete',
                          label: 'Delete',
                          iconAsset: AppImages.delete,
                          textColor: AppColors.kRedColor,
                        ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                    decoration: BoxDecoration(
                      color: sale.paymentType != "Due" ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    ),
                    child: MyTextfield.textStyle_w400( sale.paymentType,screenWidth * 0.03,sale.paymentType != "Due" ? Colors.green : Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
