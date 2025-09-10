// Same imports as before...

import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';

import '../Cart/ReceiptPrinterPage.dart';
import '../Cart/ReceiptPdfGenerator.dart';
import '../Dialog/AddPurchaseBottomSheet.dart';
import '../Expense/AddExpenseScreen.dart';
import '../Expense/ExpenseListWidget.dart';
import '../Expense/ExpenseResponse.dart';
import '../Home/HomePageScreen.dart';
import '../Ledger/LedgerListWidget.dart';
import '../Ledger/LedgerModel.dart';
import '../ReturnStock/PurchaseReturnModel.dart';
import '../ReturnStock/StockReturnListWidget.dart';
import '../SaleList/sale_details.dart';
import '../SaleList/sale_model.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../SaleReturn/SaleReturnListWidget.dart';
import '../Staff/AddStaffScreen.dart';
import '../Staff/StaffListWidget.dart';
import '../Staff/StaffModel.dart';
import '../constant/all.dart';
import 'FilterWidget.dart';
import 'InvoiceListWidget.dart';
import 'SaleListWidget.dart';

enum ListType { invoice, sale, ledger, stockReturn, saleReturn, expense, staff }

final Map<ListType, String> titleMap = {
  ListType.invoice: 'Invoice List',
  ListType.sale: 'Sale List',
  ListType.ledger: 'Ledger List',
  ListType.stockReturn: 'Stock Return List',
  ListType.saleReturn: 'Sale Return List',
  ListType.expense: 'Expense List',
  ListType.staff: 'Staff List',
};

class ListScreen extends StatefulWidget {
  final ListType type;

  const ListScreen({Key? key, this.type = ListType.invoice}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen>
    with WidgetsBindingObserver, RouteAware {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  // Lists for different types
  final invoiceList = <Invoice>[];
  final saleList = <SaleModel>[];
  final ledgerList = <LedgerModel>[];
  final stockReturnList = <PurchaseReturnModel>[];
  final saleReturnList = <CustomerReturnsResponse>[];
  final expenseList = <ExpenseResponse>[];
  final staffList = <StaffModel>[];

  DateTime? fromDate;
  DateTime? toDate;
  String selectedRange = '';
  String selectedPaymentType = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _fetchRecord(refresh: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_needsPagination()) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMoreData) {
        _fetchRecord();
      }
    }
  }

  bool _needsPagination() {
    return {
      ListType.invoice,
      ListType.sale,
      ListType.stockReturn,
      ListType.saleReturn,
      ListType.expense,
      ListType.staff,
    }.contains(widget.type) && searchQuery.isEmpty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _fetchRecord();
  }

  @override
  void didPopNext() => _fetchRecord();

  Future<void> _fetchRecord({bool refresh = false}) async {
    final userId = await SessionManager.getParentingId();
    if (userId == null) return;

    if (refresh) {
      currentPage = 1;
      hasMoreData = true;
      invoiceList.clear();
      saleList.clear();
      ledgerList.clear();
      stockReturnList.clear();
      saleReturnList.clear();
      expenseList.clear();
      staffList.clear();
    }

    if (isLoadingMore || !hasMoreData) return;

    setState(() => isLoadingMore = true);
    final apiCubit = context.read<ApiCubit>();

    String? from = fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : null;
    String? to = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : null;

    switch (widget.type) {
      case ListType.invoice:
        await apiCubit.fetchInvoiceList(user_id: userId, page: currentPage);
        break;
      case ListType.sale:
        await apiCubit.fetchSaleList(user_id: userId,page: currentPage,from:from??'',to:to??'');
        break;
      case ListType.ledger:
        await apiCubit.fetchLedgerList(user_id: userId);
        break;
      case ListType.stockReturn:
        await apiCubit.fetchStockReturnList(store_id: userId, page: currentPage);
        break;
      case ListType.saleReturn:
        await apiCubit.fetchSaleReturnList(store_id: userId, page: currentPage);
        break;
      case ListType.expense:
        await apiCubit.fetchExpenseList(store_id: userId, page: currentPage);
        break;
      case ListType.staff:
        await apiCubit.fetchStaffList(store_id: userId, page: currentPage);
        break;
    }

    setState(() => isLoadingMore = false);
  }

  void _updatePaginatedList<T>(List<T> targetList, List<T> newItems, int lastPage) {
    if (currentPage == 1) targetList.clear();
    targetList.addAll(newItems);
    hasMoreData = lastPage > currentPage;
    if (hasMoreData) currentPage++;
  }

  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _showDeleteDialog(BuildContext context, int id) {
    CommonConfirmationDialog.show<String>(
      context: context,
      id: id.toString(),
      title: 'Delete ${widget.type.name} Record?',
      content: 'Are you sure you want to delete this ${widget.type.name} record?',
      onConfirmed: (_) => _deleteRecord(id),
    );
  }

  void _deleteRecord(int id) async {
    try {
      final apiCubit = context.read<ApiCubit>();

      switch (widget.type) {
        case ListType.invoice:
          await apiCubit.InvoiceDelete(invoice_id: id.toString());
          invoiceList.removeWhere((inv) => inv.id == id);
          break;
        case ListType.sale:
          await apiCubit.SaleDelete(billing_id: id.toString());
          saleList.removeWhere((sale) => sale.invoiceNo == id);
          break;
        default:
          break;
      }

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
          final isLoading = state is InvoiceListLoading ||
              state is SaleListLoading ||
              state is LedgerListLoading ||
              state is StockReturnListLoading ||
              state is SaleReturnListLoading ||
              state is ExpenseListLoading ||
              state is StaffListLoading;

          // Populate lists from state
          if (state is InvoiceListLoaded) {
            _updatePaginatedList(invoiceList, state.invoiceList, state.last_page);
          } else if (state is SaleListLoaded) {
            _updatePaginatedList(saleList, state.saleList, state.last_page);
          } else if (state is LedgerListLoaded) {
            ledgerList
              ..clear()
              ..addAll(state.leadgerList);
          } else if (state is StockReturnListLoaded) {
            _updatePaginatedList(stockReturnList, state.returnList, state.last_page);
          } else if (state is SaleReturnListLoaded) {
            _updatePaginatedList(saleReturnList, state.billList, state.last_page);
          } else if (state is ExpenseListLoaded) {
            _updatePaginatedList(expenseList, state.list, state.last_page);
          } else if (state is StaffListLoaded) {
            _updatePaginatedList(staffList, state.staffList, state.last_page);
          }

          return Container(
            color: AppColors.kPrimary,
            padding: EdgeInsets.only(top: widget.type==ListType.ledger?0.05:screenWidth * 0.06),
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
                    child: _buildListBody(isLoading),
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
          widget.type==ListType.ledger?SizedBox(height: screenWidth * 0.02,):IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false,
            ),
          ),
          Expanded(
            child: MyTextfield.textStyle_w400(
              titleMap[widget.type] ?? '',
              screenWidth * 0.052,
              Colors.white,
            ),
          ),
          if (_isFilterSupported(widget.type))
          IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: _showFilterTopSheet,
          )
      ],
    ));
  }
  bool _isFilterSupported(ListType type) {
    return [
      ListType.invoice,
      ListType.sale,
      ListType.stockReturn,
      ListType.saleReturn,
      ListType.expense,
    ].contains(type);
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
              height: MediaQuery.of(context).size.height * 0.45,  // 30% height
              width: double.infinity,
              child: FilterWidget(
                initialFrom: fromDate,
                initialTo: toDate,
                initialRange: selectedRange,
                onApply: (from, to, range, paymentType) {
                  setState(() {
                    fromDate = from;
                    toDate = to;
                    selectedRange = range;
                    selectedPaymentType = paymentType??'';
                  });
                  _fetchRecord(refresh: true);
                  Navigator.pop(context);
                },
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
          borderRadius: BorderRadius.circular(screenWidth * 0.07),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search by name",
            hintStyle: MyTextfield.textStyle(16, Colors.grey, FontWeight.w300),
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: _updateSearchQuery,
        ),
      ),
    );
  }

  Widget _buildListBody(bool isLoading) {
    switch (widget.type) {
      case ListType.invoice:
        return InvoiceListWidget(
          invoices: invoiceList,
          isLoading: isLoading && currentPage == 1,
          hasMoreData: hasMoreData,
          scrollController: _scrollController,
          searchQuery: searchQuery,
          onSearchChanged: _updateSearchQuery,
          onAddPressed: _onAddInvoicePressed,
          onDeletePressed: (id) { _showDeleteDialog(context, id); },
          onEditPressed: (inv) => AppRoutes.navigateTo(context, AddPurchaseBill(invoice: inv)),
        );
      case ListType.sale:
        return SaleListWidget(
          sales: saleList,
          isLoading: isLoading && currentPage == 1,
          hasMoreData: hasMoreData,
          scrollController: _scrollController,
          searchQuery: searchQuery,
          onSearchChanged: _updateSearchQuery,
          onDeletePressed: (id) { _showDeleteDialog(context, id); },
          onEditPressed: (sale) => AppRoutes.navigateTo(context, SaleDetailsPage(sale: sale, edit: true)),
          onPrintPressed: (sale) => /*_onButtonPrintPressed(context, sale)*/AppRoutes.navigateTo(context,
            ReceiptPrinterPage(sale: sale)),
          onSharePressed: (sale) => ReceiptPdfGenerator.generateAndSharePdf(context, sale),
          onDownloadPressed: (sale) => ReceiptPdfGenerator.downloadPdf(context, sale),
          onAddPressed: () {},
        );
      case ListType.ledger:
        return LedgerListWidget(
          items: ledgerList,
          isLoading: isLoading,
          searchQuery: searchQuery,
          onSearchChanged: _updateSearchQuery,
        );
      case ListType.stockReturn:
        return StockReturnListWidget(
          items: stockReturnList,
          isLoading: isLoading && currentPage == 1,
          hasMoreData: hasMoreData,
          scrollController: _scrollController,
          searchQuery: searchQuery,
          onSearchChanged: _updateSearchQuery,
        );
      case ListType.saleReturn:
        return SaleReturnListWidget(
          items: saleReturnList,
          isLoading: isLoading && currentPage == 1,
          hasMoreData: hasMoreData,
          scrollController: _scrollController,
          searchQuery: searchQuery,
          onSearchChanged: _updateSearchQuery,
        );
      case ListType.expense:
        return ExpenseListWidget(
          items: expenseList,
          isLoading: isLoading && currentPage == 1,
          hasMoreData: hasMoreData,
          scrollController: _scrollController,
          searchQuery: searchQuery,
          onSearchChanged: _updateSearchQuery,
          onAddPressed: _onAddExpense,
        );
      case ListType.staff:
        return StaffListWidget(
          list: staffList,
          isLoading: isLoading && currentPage == 1,
          hasMoreData: hasMoreData,
          scrollController: _scrollController,
          searchQuery: searchQuery,
          onSearchChanged: _updateSearchQuery,
          onAddPressed: _onAddStaff,
        );
    }
  }

  Future<void> _onAddInvoicePressed() async {
    AddPurchaseBottomSheet(context, _setSelectedImage, pdf: true, pick_Size: 5, ManualAdd: true);
  }

  Future<void> _onAddExpense() async {
    AppRoutes.navigateTo(context, Addexpensescreen());
  }

  Future<void> _onAddStaff() async {
    AppRoutes.navigateTo(context, AddStaffScreen(add: true));
  }

  Future<void> _setSelectedImage(List<File> files) async {
    List<String> croppedPaths = [];

    for (var file in files) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.kPrimary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.kPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      if (croppedFile != null) {
        croppedPaths.add(croppedFile.path);
      }
    }

    if (croppedPaths.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(paths: croppedPaths),
        ),
      );
    }
  }

  void _onButtonPrintPressed(BuildContext context, SaleModel sale) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.kWhiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.70,
        minChildSize: 0.60,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ReceiptPrinterPage(
            sale: sale,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}
