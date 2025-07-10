import 'package:pixidrugs/Home/HomePageScreen.dart';
import 'package:pixidrugs/ListPageScreen/InvoiceListWidget.dart';
import 'package:pixidrugs/ListPageScreen/SaleListWidget.dart';
import 'package:pixidrugs/SaleList/sale_details.dart';
import 'package:pixidrugs/SaleList/sale_model.dart';
import 'package:pixidrugs/constant/all.dart';
import '../Dialog/show_image_picker.dart';

class ListScreen extends StatefulWidget {
  final String? type;

  const ListScreen({Key? key, this.type = ''}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen>
    with WidgetsBindingObserver, RouteAware {
  String searchQuery = "";
  List<Invoice> invoiceList = [];
  List<SaleModel> saleList = [];

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
    if (widget.type == 'invoice') {
      context.read<ApiCubit>().fetchInvoiceList(user_id: userId);
    } else {
      context.read<ApiCubit>().fetchSaleList(user_id: userId);
    }
  }

  Future<void> _onAddInvoicePressed() async {
    showImageBottomSheet(context, _setSelectedImage, pdf: true, pick_Size: 1);
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
      if (widget.type == 'invoice') {
        await context.read<ApiCubit>().InvoiceDelete(invoice_id: id);
        setState(() {
          invoiceList.removeWhere((invoice) => invoice.invoiceId == id);
        });
      } else if (widget.type == 'sale') {
        await context.read<ApiCubit>().SaleDelete(billing_id: id);
        setState(() {
          saleList.removeWhere((sale) => sale.invoiceNo == int.parse(id));
        });
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
      title: 'Delete ${widget.type} Record?',
      content: 'Are you sure you want to delete this ${widget.type} record?',
      onConfirmed: (_) => _deleteRecord(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is InvoiceListLoaded) {
            invoiceList = state.invoiceList;
          } else if (state is SaleListLoaded) {
            saleList = state.saleList;
          }
        },
        child: Container(
          color: AppColors.kPrimary,
          padding: EdgeInsets.only(top: screenWidth * 0.12),
          child: Column(
            children: [
              _buildTopBar(screenWidth),
              _buildSearchBar(screenWidth),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchRecord,
                  child: widget.type == 'invoice'
                      ? InvoiceListWidget(
                    invoices: invoiceList,
                    isLoading: context.watch<ApiCubit>().state is InvoiceListLoading,
                    searchQuery: searchQuery,
                    onSearchChanged: (value) => setState(() => searchQuery = value),
                    onAddPressed: _onAddInvoicePressed,
                    onDeletePressed: (id){
                      _showDeleteDialog(context,id);
                    },
                    onEditPressed: (invoice){
                      AppRoutes.navigateTo(context, AddPurchaseBill(invoice:invoice));
                    },
                  )
                      : SaleListWidget(
                    sales: saleList,
                    isLoading: context.watch<ApiCubit>().state is InvoiceListLoading,
                    searchQuery: searchQuery,
                    onSearchChanged: (value) => setState(() => searchQuery = value),
                    onAddPressed: _onAddInvoicePressed,
                    onDeletePressed: (id){
                        _showDeleteDialog(context,id);
                    },
                      onEditPressed: (saleItem){
                        AppRoutes.navigateTo(
                          context,
                          SaleDetailsPage(sale: saleItem, edit: true),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.type == 'invoice' && invoiceList.isNotEmpty
          ? FloatingActionButton(
        onPressed: _onAddInvoicePressed,
        backgroundColor: AppColors.kPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildTopBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
                    (route) => false,
              );
            },
          ),
          Text(
            widget.type == 'invoice' ? 'Invoice List' : 'Sale List',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          decoration: const InputDecoration(
            hintText: "Search by name",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (value) => setState(() => searchQuery = value),
        ),
      ),
    );
  }
}
