
import 'package:PixiDrugs/constant/all.dart';

import '../search/customerModel.dart';

class ReturnProductListPage extends StatefulWidget {
  CartTypeSelection? cartTypeSelection;
  CustomerModel? selectedCustomer;
  ReturnProductListPage({super.key,required this.cartTypeSelection, this.selectedCustomer});

  @override
  State<ReturnProductListPage> createState() => _ReturnProductListPageState();
}

class _ReturnProductListPageState extends State<ReturnProductListPage> {
  final List<InvoiceItem> _products = [];
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _fetchStockList();
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _fetchStockList() async {
    setState(() {
      isLoading = true;
    });
    String? userId=await SessionManager.getParentingId();
    if(widget.cartTypeSelection==CartTypeSelection.StockiestReturn){
      if(widget.selectedCustomer!=null) {
        context.read<ApiCubit>().BarcodeScan(code: '', storeId: userId!, seller_id:widget.selectedCustomer?.id.toString()??'',source: 'manual');
      }else{
        context.read<ApiCubit>().fetchStockList(user_id: userId!,page: 1,query:_searchController.text.toString());
      }
    }else if(widget.cartTypeSelection==CartTypeSelection.CustomerReturn){
      context.read<ApiCubit>().customerbarcode(storeId: userId!,code: '',customer_id:widget.selectedCustomer?.id.toString()??'',source: 'manual');
    }
  }
  void _onSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    setState(() {});// <-- Trigger UI update for clear button visibility

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchController.text.trim();

      if (query.isNotEmpty && query.length>=3) {
        String? userId = await SessionManager.getParentingId();
        if(widget.cartTypeSelection==CartTypeSelection.StockiestReturn){
          context.read<ApiCubit>().BarcodeScan(code: query, storeId: userId!, seller_id:widget.selectedCustomer?.id.toString()??'',source: 'manual');
        }else if(widget.cartTypeSelection==CartTypeSelection.CustomerReturn){
          context.read<ApiCubit>().customerbarcode(storeId: userId!,code:query,customer_id:widget.selectedCustomer?.id.toString()??'',source: 'manual');
        }
      }
    });
  }

  Future<void> _onclearTap() async {
    setState(() {
      _searchController.text='';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Same as AppBar back arrow
          Navigator.pop(context, {'code': 'manualAdd'});
          // Return false to prevent default pop (optional, if you already pop manually)
          return false;
        },
        child:  Scaffold(
      backgroundColor: AppColors.kPrimary,
      appBar: customAppBar(context, _searchController, _onclearTap),
      body: BlocConsumer<ApiCubit, ApiState>(
          listener: (context, state) {
            if (state is StockListLoaded ||
                state is BarcodeScanLoaded ||
                state is CustomerBarcodeScanLoaded) {
              isLoading = false;
              _products.clear();
              if (state is BarcodeScanLoaded) {
                _products.addAll(state.list);
              }
              if (state is CustomerBarcodeScanLoaded) {
                _products.addAll(state.list);
              } else if (state is StockListLoaded) {
                _products.addAll(state.stockList);
              }
            }
          },
            builder: (context, state) {
              final isLoading = state is StockListLoading ||
                  state is BarcodeScanLoading ||
                  state is CustomerBarcodeScanLoading;
              Widget content;

              if (isLoading) {
                content = const Center(
                  child: CircularProgressIndicator(color: AppColors.kPrimary),
                );
              } else {
                content = ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) =>
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProductCard(
                          item: _products[index],
                          returnStock: true,
                          cartTypeSelection: widget.cartTypeSelection,
                        ),
                      ),
                );
              }
            return Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                gradient: AppColors.myGradient,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: content,
            );
          }

      ),
    )
    );
  }
}
// ✅ Custom AppBar with search + barcode
PreferredSizeWidget customAppBar(BuildContext context,
    TextEditingController searchController, VoidCallback onclearTap) {
  var tittle='Search Product';
  return PreferredSize(
    preferredSize: const Size.fromHeight(120),
    child: Container(
      color: AppColors.kPrimary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context,{'code': 'manualAdd'});
                    },
                    child:
                    SvgPicture.asset(
                      AppImages.back,
                      height: 24,
                      color: AppColors.kWhiteColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyTextfield.textStyle_w600(tittle, SizeConfig.screenWidth! * 0.055, Colors.white)
                ],
              ),
            ),
            const SizedBox(height: 5),
            Padding(
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
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          hintStyle: MyTextfield.textStyle(16 ,Colors.grey,FontWeight.w300),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    searchController.text.isNotEmpty?IconButton(
                      onPressed: onclearTap,
                      icon: const Icon(Icons.clear_rounded,
                          color: Colors.grey),
                    ):SizedBox(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}