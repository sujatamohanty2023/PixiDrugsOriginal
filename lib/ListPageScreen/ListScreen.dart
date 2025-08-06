import 'package:PixiDrugs/Expense/ExpenseResponse.dart';
import 'package:PixiDrugs/Staff/AddStaffScreen.dart';
import 'package:PixiDrugs/Staff/StaffModel.dart';
import 'package:PixiDrugs/StockReturn/PurchaseReturnModel.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:PixiDrugs/Cart/ReceiptPrinterPage.dart';
import 'package:PixiDrugs/Home/HomePageScreen.dart';
import 'package:PixiDrugs/Ledger/LedgerListWidget.dart';
import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/ListPageScreen/InvoiceListWidget.dart';
import 'package:PixiDrugs/ListPageScreen/SaleListWidget.dart';
import 'package:PixiDrugs/SaleList/sale_details.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/shareFileToWhatsApp.dart';
import '../Dialog/show_image_picker.dart';
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
    final userId = await SessionManager.getUserId();
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
    showImageBottomSheet(context, _setSelectedImage, pdf: false, pick_Size: 1);
  }
  Future<void> _onAddExpense() async {
    AppRoutes.navigateTo(context, Addexpensescreen());
  }
  Future<void> _onAddStaff() async {
    AppRoutes.navigateTo(context, AddStaffScreen(add:true));
  }

  void _setSelectedImage(List<File> files) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(path: files[0].path),
        ),
      );
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Record deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete record: $e")),
      );
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
            padding: EdgeInsets.only(top: screenWidth * 0.12),
            child: Column(
              children: [
                _buildTopBar(screenWidth),
                _buildSearchBar(screenWidth),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchRecord,
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
          onPrintPressed: _onButtonPrintPressed,
          onSharePressed: _shareReceiptAsPdf, onAddPressed: () {  },
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
  void _onButtonPrintPressed(SaleModel saleItem) {
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
  Future<void> _shareReceiptAsPdf(SaleModel saleItem) async {
      final pdf = pw.Document();

      final fontData = await rootBundle.load('assets/fonts/Signika-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      // Load logo image (optional)
      pw.MemoryImage? logoImage;
      try {
        final bytes = (await rootBundle.load(AppImages.AppIcon)).buffer.asUint8List();
        logoImage = pw.MemoryImage(bytes);
      } catch (_) {}

      // Calculate totals & subtotals
      double calculateSubtotal(SaleItem item) {
        final price = item.price ?? 0;
        final quantity = item.quantity ?? 0;
        final discount = item.discount ?? 0;
        final total = price * quantity;
        return total - (total * discount / 100);
      }

      final items = saleItem.items ?? [];
      final totalItemAmount = items.fold<double>(0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 0)));
      final totalDiscount = items.fold<double>(0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 0) * ((item.discount ?? 0) / 100)));
      final totalAmount = totalItemAmount - totalDiscount;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoImage != null)
                  pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.Image(logoImage, height: 80),
                  ),

                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text('PixiDrugs',
                      style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF062A49))),
                ),

                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text('GSTIN: 1234567890', style: pw.TextStyle(font: ttf, fontSize: 9)),
                ),

                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text('Phone: 123456789', style: pw.TextStyle(font: ttf, fontSize: 9)),
                ),

                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text('Address: Berhampur', style: pw.TextStyle(font: ttf, fontSize: 9)),
                ),

                pw.Divider(color: PdfColors.grey400, thickness: 1, height: 20),

                // Invoice info
                pw.Row(
                  children: [
                    pw.Text('Invoice No:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                    pw.Text('#${saleItem.invoiceNo}', style: pw.TextStyle(font: ttf)),
                  ],
                ),
                pw.Row(
                  children: [
                    pw.Text('Date:', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                    pw.Text('${saleItem.date ?? ''}', style: pw.TextStyle(font: ttf)),
                  ],
                ),

                pw.SizedBox(height: 12),

                // Customer details
                pw.Text('Customer Details', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColor.fromInt(0xFF062A49))),
                pw.Text('Name: ${saleItem.customer.name ?? ''}', style: pw.TextStyle(font: ttf, fontSize: 11)),
                pw.Text('Phone: ${saleItem.customer.phone ?? ''}', style: pw.TextStyle(font: ttf, fontSize: 11)),
                pw.Text('Address: ${saleItem.customer.address ?? ''}', style: pw.TextStyle(font: ttf, fontSize: 11)),

                pw.SizedBox(height: 20),

                // Items table header with blue background
                pw.Container(
                  color: PdfColor.fromInt(0xFF062A49),
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 4, child: pw.Text('Item', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                      pw.Expanded(flex: 2, child: pw.Text('Qty', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('MRP', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 2, child: pw.Text('Disc', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('Total', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                ),

                // Items list
                ...items.map((item) {
                  final subtotal = calculateSubtotal(item);
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 4, child: pw.Text(item.productName ?? '', style: pw.TextStyle(font: ttf, fontSize: 11))),
                        pw.Expanded(flex: 2, child: pw.Text('${item.quantity ?? 0}', style: pw.TextStyle(font: ttf, fontSize: 11), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('${(item.price ?? 0).toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 11), textAlign: pw.TextAlign.right)),
                        pw.Expanded(flex: 2, child: pw.Text('${item.discount ?? 0}%', style: pw.TextStyle(font: ttf, fontSize: 11), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('${subtotal.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 11), textAlign: pw.TextAlign.right)),
                      ],
                    ),
                  );
                }).toList(),

                pw.SizedBox(height: 10),

                // Totals summary box
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFC4DAF6),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Subtotal:', style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${totalItemAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 14)),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Discount:', style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('-${totalDiscount.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 14, color: PdfColors.red)),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total:', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),


                // Footer message
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 30),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromInt(0xFFC4DAF6)),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Terms and Conditions',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF062A49),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '1. Medicines must be stored as per the instructions on the packaging.\n'
                            '2. Please consult your healthcare professional before using any medicine.\n'
                            '3. Returns or exchanges are accepted only for damaged or defective products within 7 days.\n'
                            '4. Keep the receipt as proof of purchase for warranty and returns.\n'
                            '5. We are not responsible for any misuse or side effects of the medicines.\n'
                            '6. Prices are subject to change without prior notice.\n'
                            '7. Thank you for choosing PixiDrugs.',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey800,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text('Thank you for shopping at PixiDrugs!',
                    style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.grey600),
                  ),
                ),

              ],
            );
          },
        ),
      );

      // Save & share the PDF
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receipt_${saleItem.invoiceNo}.pdf');
      await file.writeAsBytes(await pdf.save());

      if(saleItem.customer.phone.isNotEmpty && saleItem.customer.phone!='no number') {
          _sharePdfViaWhatsApp(saleItem,file.path);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Mobile No.')),
        );
      }
    }
  Future<void> _sharePdfViaWhatsApp(SaleModel saleItem, String filePath1) async {
    await shareFileToWhatsApp(
      phoneNumber: "91${saleItem.customer.phone.replaceAll("+91", '')}",
      filePath: filePath1,
      message: '''
Dear ${saleItem.customer.name},

Thank you for your purchase.

Invoice No: ${saleItem.invoiceNo}  
Amount: ₹${saleItem.totalAmount}

Please find your receipt attached.

Best regards,  
PixiDrugs
''',
    );
  }
}
