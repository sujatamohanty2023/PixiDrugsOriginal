import 'package:PixiDrugs/Expense/ExpenseResponse.dart';
import 'package:PixiDrugs/Staff/AddStaffScreen.dart';
import 'package:PixiDrugs/Staff/StaffModel.dart';
import 'package:PixiDrugs/StockReturn/PurchaseReturnModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:PixiDrugs/Cart/ReceiptPrinterPage.dart';
import 'package:PixiDrugs/Home/HomePageScreen.dart';
import 'package:PixiDrugs/Ledger/LedgerListWidget.dart';
import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/ListPageScreen/InvoiceListWidget.dart';
import 'package:PixiDrugs/ListPageScreen/SaleListWidget.dart';
import 'package:PixiDrugs/SaleList/sale_details.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';
import '../Cart/receipt_pdf_generator.dart';
import '../Dialog/AddPurchaseBottomSheet.dart';
import '../Expense/AddExpenseScreen.dart';
import '../Expense/ExpenseListWidget.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../SaleReturn/SaleReturnListWidget.dart';
import '../Staff/StaffListWidget.dart';
import '../StockReturn/StockReturnListWidget.dart';

enum ListType { invoice, sale, ledger, stockReturn, saleReturn,expense,staff }

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
  List<Invoice> invoiceList = [];
  List<SaleModel> saleList = [];
  List<LedgerModel> ledgerList = [];
  List<PurchaseReturnModel> stockReturnList= [];
  List<CustomerReturnsResponse> saleReturnList= [];
  List<ExpenseResponse> expenseList= [];
  List<StaffModel> staffList= [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchRecord();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchRecord();
    }
  }

  @override
  void didPopNext() {
    _fetchRecord();
  }

  Future<void> _fetchRecord() async {
    final userId = await SessionManager.getParentingId();
    if (userId == null) return;
    switch (widget.type) {
      case ListType.invoice:
        context.read<ApiCubit>().fetchInvoiceList(user_id: userId);
        break;
      case ListType.sale:
        context.read<ApiCubit>().fetchSaleList(user_id: userId);
        break;
      case ListType.ledger:
        context.read<ApiCubit>().fetchLedgerList(user_id: userId);
        break;
      case ListType.stockReturn:
        context.read<ApiCubit>().fetchStockReturnList(store_id: userId);
        break;
      case ListType.saleReturn:
        context.read<ApiCubit>().fetchSaleReturnList(store_id: userId);
        break;
      case ListType.expense:
        context.read<ApiCubit>().fetchExpenseList(store_id: userId);
        break;
      case ListType.staff:
        context.read<ApiCubit>().fetchStaffList(store_id: userId);
        break;
    }
  }

  Future<void> _onAddInvoicePressed() async {
    AddPurchaseBottomSheet(context, _setSelectedImage, pdf: true, pick_Size: 5,ManualAdd: true);
  }
  Future<void> _onAddExpense() async {
    AppRoutes.navigateTo(context, Addexpensescreen());
  }
  Future<void> _onAddStaff() async {
    AppRoutes.navigateTo(context, AddStaffScreen(add:true));
  }

  Future<void> _setSelectedImage(List<File> file) async {
    List<String> croppedFileList =[];
    for(var item in file) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: item.path,
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
      croppedFileList.add(croppedFile!.path);
    }

    if (croppedFileList.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(paths:croppedFileList),
        ),
      );
    }
  }
  void _deleteRecord(String id) async {
    try {
      switch (widget.type) {
        case ListType.invoice:
          await context.read<ApiCubit>().InvoiceDelete(invoice_id: id);
          setState(() => invoiceList.removeWhere((inv) => inv.invoiceId == id));
          break;
        case ListType.sale:
          await context.read<ApiCubit>().SaleDelete(billing_id: id);
          setState(() => saleList.removeWhere((sale) => sale.invoiceNo == int.parse(id)));
          break;
        default:
          break;
      }
      AppUtils.showSnackBar(context,"Record deleted successfully");
    } catch (e) {
      AppUtils.showSnackBar(context,"Failed to delete record: $e");
    }
  }

  void _showDeleteDialog(BuildContext context,String id) {
    CommonConfirmationDialog.show<String>(
      context: context,
      id: id,
      title: 'Delete ${widget.type.name} Record?',
      content: 'Are you sure you want to delete this ${widget.type.name} record?',
      onConfirmed: (_) => _deleteRecord(id),
    );
  }

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
              state is ExpenseListLoading||
              state is StaffListLoading;

          if (state is InvoiceListLoaded) {
            invoiceList = state.invoiceList;
          }else if (state is SaleListLoaded) {
            saleList = state.saleList;
          }else if (state is LedgerListLoaded) {
            ledgerList = state.leadgerList;
          }else if (state is StockReturnListLoaded) {
            stockReturnList = state.returnList;
          }else if (state is SaleReturnListLoaded) {
            saleReturnList = state.billList;
          }else if (state is ExpenseListLoaded) {
            expenseList = state.list;
          }else if (state is StaffListLoaded) {
            staffList = state.staffList;
          }

          return Container(
            color: AppColors.kPrimary,
            padding: EdgeInsets.only(top: screenWidth * 0.06),
            child: Column(
              children: [
                _buildTopBar(screenWidth),
                _buildSearchBar(screenWidth),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchRecord,
                    child: _buildListBody(isLoading),
                    color: AppColors.kPrimary,
                    backgroundColor: AppColors.kPrimaryLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListBody(bool isLoading) {
    switch (widget.type) {
      case ListType.invoice:
        return InvoiceListWidget(
            invoices: invoiceList,
            isLoading: isLoading,
            searchQuery: searchQuery,
            onSearchChanged: (v) => setState(() => searchQuery = v),
            onAddPressed: _onAddInvoicePressed,
            onDeletePressed: (id) {
              _showDeleteDialog(context, id);
            },
            onEditPressed: (inv) =>
                AppRoutes.navigateTo(context, AddPurchaseBill(invoice: inv)));
      case ListType.sale:
        print('SaleList${saleList.length}');
        return SaleListWidget(
          sales: saleList,
          isLoading: isLoading,
          searchQuery: searchQuery,
          onSearchChanged: (v) => setState(() => searchQuery = v),
          onDeletePressed: (id) {
            _showDeleteDialog(context, id);
          },
          onEditPressed: (sale) =>
              AppRoutes.navigateTo(context, SaleDetailsPage(sale: sale, edit: true)),
          onPrintPressed: (sale) {
            _onButtonPrintPressed(context, sale);
          },
          onSharePressed: (sale) =>ReceiptPdfGenerator.generateAndSharePdf(context, sale),
          onAddPressed: () {  },
        );
      case ListType.ledger:
        return LedgerListWidget(
          items: ledgerList,
          isLoading: isLoading,
          searchQuery: searchQuery,
          onSearchChanged: (v) => setState(() => searchQuery = v),
        );
      case ListType.stockReturn:
        return StockReturnListWidget(
          items: stockReturnList,
          isLoading: isLoading,
          searchQuery: searchQuery,
          onSearchChanged: (v) => setState(() => searchQuery = v),
        );
      case ListType.saleReturn:
        return SaleReturnListWidget(
          items: saleReturnList,
          isLoading: isLoading,
          searchQuery: searchQuery,
          onSearchChanged: (v) => setState(() => searchQuery = v),
        );
      case ListType.expense:
        return ExpenseListWidget(
          items: expenseList,
          isLoading: isLoading,
          searchQuery: searchQuery,
          onAddPressed: _onAddExpense,
          onSearchChanged: (v) => setState(() => searchQuery = v)
        );
      case ListType.staff:
        return StaffListWidget(
            list: staffList,
            isLoading: isLoading,
            searchQuery: searchQuery,
            onAddPressed: _onAddStaff,
            onSearchChanged: (v) => setState(() => searchQuery = v)
        );
    }
  }

  Widget _buildTopBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
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
          MyTextfield.textStyle_w400(titleMap[widget.type] ?? '', screenWidth * 0.055,Colors.white,),
        ],
      ),
    );
  }
  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.07),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search by name",
            hintStyle: MyTextfield.textStyle(16 ,Colors.grey,FontWeight.w300),
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (value) => setState(() => searchQuery = value),
        ),
      ),
    );
  }
  void _onButtonPrintPressed(BuildContext context,SaleModel saleItem) {
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
            sale: saleItem,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

}
