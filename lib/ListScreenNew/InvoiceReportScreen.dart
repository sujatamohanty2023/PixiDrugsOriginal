import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:intl/intl.dart';
import '../Dialog/AddPurchaseBottomSheet.dart';
import '../Home/HomePageScreen.dart';
import '../constant/all.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/CustomPopupMenuItemData.dart';
import '../customWidget/GradientInitialsBox.dart';
import '../ListPageScreen/FilterWidget.dart';

class Invoicereportscreen extends StatefulWidget {
  final bool? topCreditor;
  const Invoicereportscreen({Key? key,this.topCreditor=false}) : super(key: key);

  @override
  State<Invoicereportscreen> createState() => _InvoicereportscreenState();
}

class _InvoicereportscreenState extends State<Invoicereportscreen> with WidgetsBindingObserver, RouteAware {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  String? role;

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isRefresh = false;

  final invoiceList = <Invoice>[];

  DateTime? fromDate;
  DateTime? toDate;
  String selectedRange = '';
  String selectedPaymentType = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if(widget.topCreditor==true){
      selectedPaymentType='Due';
    }
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

    await apiCubit.fetchInvoiceList(user_id: userId,page: currentPage,from:from??'',to:to??'',payment_type:selectedPaymentType.toLowerCase(),query: searchQuery);
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
      title: 'Delete Invoice Record?',
      content: 'Are you sure you want to delete this Invoice record?',
      onConfirmed: (_) => _deleteRecord(id),
    );
  }

  void _deleteRecord(int id) async {
    try {

      final apiCubit = context.read<ApiCubit>();
      await apiCubit.InvoiceDelete(invoice_id: id.toString());
      invoiceList.removeWhere((inv) => inv.id == id);
      AppUtils.showSnackBar(context, "Record deleted successfully");
      setState(() {});
    } catch (e) {
      AppUtils.showSnackBar(context, "Failed to delete record: $e");
    }
  }
  Future<void> _onAddInvoicePressed() async {
    AddPurchaseBottomSheet(context, _setSelectedImage, pdf: true, pick_Size: 5, ManualAdd: true);
  }
  Future<void> _setSelectedImage(List<File> files) async {
    print("🔍 Raw scannedDocuments = ${files.first}");
    if (files.isNotEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(
            paths: files.map((e) => e.path).toList(),
          ),
        ),
      );
      if (result==true) {
        _fetchRecord(refresh: true);
      }
    }
  }
  // ---- Build Method ----

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocBuilder<ApiCubit, ApiState>(
        builder: (context, state) {
          final isLoading = state is InvoiceListLoading;

          // Populate lists from state
          if (state is InvoiceListLoaded) {
            _updatePaginatedList(invoiceList, state.invoiceList, state.last_page);
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
                      child:(isLoading || isRefresh) && invoiceList.isEmpty?
                      Center(child: CircularProgressIndicator(color: AppColors.kPrimary))
                          : (!isLoading && !isRefresh) && invoiceList.isEmpty
                          ? NoItemPage(
                        onTap: _onAddInvoicePressed,
                        image: AppImages.no_invoice,
                        tittle: 'Add an Invoice record.',
                        description: "Please add your invoice details for better tracking.",
                        button_tittle: 'Add Invoice',
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
                'Invoice List',
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
                  type:ListType.invoice,
                  initialFrom: fromDate,
                  initialTo: toDate,
                  initialRange: selectedRange,
                  initialPaymentType:selectedPaymentType,
                  onApply: (from, to, range, paymentType,paymentReason) async {
                    setState(() {
                      fromDate = from;
                      toDate = to;
                      selectedRange = range;
                      selectedPaymentType = paymentType??'';
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
                  hintText: 'Search by invoice no./supplier name',
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
    final itemCount = invoiceList.length + (hasMoreData ? 1 : 0);
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
          return _buildInvoiceCard(invoiceList[index], screenWidth,context);
        },
      ),
    );
  }
  Widget _buildInvoiceCard(invoice, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InvoiceSummaryPage(details: true, invoice: invoice)),
        );
        if (result==true) {
          _fetchRecord(refresh: true);
        }
      },
      child: Card(
        color: AppColors.kWhiteColor,
        margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(screenWidth * 0.03)),
                child: Container(
                  width: screenWidth * 0.015,
                  color: AppColors.kPrimary,
                ),
              ),
              GradientInitialsBox(
                size: screenWidth * 0.15,
                name: invoice.sellerName!,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(
                        invoice.sellerName!, screenWidth * 0.04, AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400(
                        'Invoice No. #${invoice.invoiceId!}',
                        screenWidth * 0.035,
                        Colors.grey.shade700),
                    MyTextfield.textStyle_w400(
                      'Dt. ${invoice.invoiceDate!} (${getTimeDifference(invoice.invoiceDate!)})',
                      screenWidth * 0.035,
                      Colors.red.shade700,
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w600(
                        "₹${invoice.netAmount!}", screenWidth * 0.049, Colors.green),
                  ],
                ),
              ),
              CustomPopupMenu(
                iconSize: screenWidth * 0.05,
                backgroundColor: AppColors.kWhiteColor,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      AppRoutes.navigateTo(context, AddPurchaseBill(invoice: invoice));
                      break;
                    case 'delete':
                      _showDeleteDialog(context, invoice.id!);
                      break;
                  }
                },
                items: [
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
            ],
          ),
        ),
      ),
    );
  }

  String getTimeDifference(String invoiceDateStr) {
    try {
      final invoiceDate = DateTime.parse(invoiceDateStr); // assuming format is "yyyy-MM-dd"
      final now = DateTime.now();
      Duration diff = now.difference(invoiceDate);

      int totalDays = diff.inDays;

      int years = totalDays ~/ 365;
      int months = (totalDays % 365) ~/ 30;
      int days = (totalDays % 365) % 30;

      List<String> parts = [];

      if (years > 0) parts.add("$years ${years == 1 ? 'year' : 'years'}");
      if (months > 0) parts.add("$months ${months == 1 ? 'month' : 'months'}");
      if (days > 0 || parts.isEmpty) parts.add("$days ${days == 1 ? 'day' : 'days'}");

      return parts.join(", ") + " ago";
    } catch (e) {
      return ""; // Fallback in case of parsing error
    }
  }
}
