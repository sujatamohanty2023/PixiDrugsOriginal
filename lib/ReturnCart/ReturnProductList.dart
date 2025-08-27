import 'package:PixiDrugs/Stock/ProductTile.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../search/customerModel.dart';
import '../search/sellerModel.dart';

class ReturnProductListPage extends StatefulWidget {
  CartTypeSelection? cartTypeSelection;
  final int flag;
  Seller? selectedSeller;
  CustomerModel? selectedCustomer;
  final Function(Seller)? onSellerSelected;
  final Function(CustomerModel)? onCustomerSelected;
  ReturnProductListPage({super.key,required this.cartTypeSelection, required this.flag,this.selectedSeller,this.selectedCustomer,
    this.onSellerSelected,this.onCustomerSelected,});

  @override
  State<ReturnProductListPage> createState() => _ReturnProductListPageState();
}

class _ReturnProductListPageState extends State<ReturnProductListPage> {
  final List<InvoiceItem> _products = [];
  List<InvoiceItem> _filteredProducts = [];
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
    if(widget.flag==4){
      if(widget.selectedSeller!=null || widget.selectedCustomer !=null) {
        context.read<ApiCubit>().BarcodeScan(code: '', storeId: userId!, source: 'manual',seller_id:widget.selectedSeller?.id.toString()??'',customer_id:widget.selectedCustomer?.id.toString()??'');
      }else{
        widget.cartTypeSelection==CartTypeSelection.StockiestReturn?
        context.read<ApiCubit>().fetchStockList(user_id: userId!):
        context.read<ApiCubit>().customerbarcode(storeId: userId!,code: '',source: 'manual');

      }
    }
  }
  void _onSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    setState(() {});// <-- Trigger UI update for clear button visibility

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchController.text.trim();

      if (query.isNotEmpty && query.length>=3 && widget.flag == 4) {
        String? userId = await SessionManager.getParentingId();
        if(widget.selectedSeller!=null || widget.selectedCustomer !=null) {
          context.read<ApiCubit>().BarcodeScan(code: query, storeId: userId!, source: 'manual',seller_id:widget.selectedSeller?.id.toString()??'',customer_id:widget.selectedCustomer?.id.toString()??'');
        }else {
          widget.cartTypeSelection == CartTypeSelection.StockiestReturn ?
          context.read<ApiCubit>().BarcodeScan(code: query, storeId: userId!, source: 'manual', seller_id: widget.selectedSeller?.id.toString() ?? '')
          : context.read<ApiCubit>().customerbarcode(code: query, storeId: userId!, source: 'manual');
        }
      }else {
        // Local filtering if not in search mode (flag != 4)
        setState(() {
          _filteredProducts = _products.where((product) {
            return product.product.toLowerCase().contains(query.toLowerCase()) ||
                product.hsn.toLowerCase().contains(query.toLowerCase());
          }).toList();
        });
      }
    });
  }

  Future<void> _onclearTap() async {
    setState(() {
      _searchController.text='';
    });
  }

  void _onAddProduct() {
    AppRoutes.navigateTo(context, AddPurchaseBill());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimary,
      appBar: customAppBar(context, _searchController, _onclearTap,flag:widget.flag),
      body: BlocConsumer<ApiCubit, ApiState>(
          listener: (context, state) {
            if (state is StockListLoaded ||
                state is BarcodeScanLoaded||
                state is CustomerBarcodeScanLoaded) {
              isLoading=false;
              _products.clear();
              if(state is BarcodeScanLoaded){
                _products.addAll(state.list);
              }if(state is CustomerBarcodeScanLoaded){
                _products.addAll(state.list);
              }else if (state is StockListLoaded) {
                  _products.addAll(state.stockList);
                  _filteredProducts = List.from(_products);
              }
            }
          },
          builder: (context, state) {
            Widget content;

            if (state is StockListLoading ||
                state is BarcodeScanLoading ||
                state is CustomerBarcodeScanLoading) {
              content = const Center(
                child: CircularProgressIndicator(color: AppColors.kPrimary),
              );
            }else {
              content = ListView.builder(
                itemCount: widget.flag==4?_products.length:_filteredProducts.length,
                itemBuilder: (context, index) =>
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProductCard(
                      item: _products[index],
                      mode: ProductCardMode.search,
                      returnStock:true,
                      cartTypeSelection:widget.cartTypeSelection,
                      onSellerSelected: (updatedSeller) {
                        // Notify grandparent if needed
                        setState(() {
                          widget.selectedSeller = updatedSeller;
                          widget.onSellerSelected?.call(updatedSeller);
                        });
                      },
                      onCustomerSelected: (updatedCustomer) {
                        // Notify grandparent if needed
                        setState(() {
                          widget.selectedCustomer = updatedCustomer;
                          widget.onCustomerSelected?.call(updatedCustomer);
                        });
                      }
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
    );
  }
}
// ✅ Custom AppBar with search + barcode
PreferredSizeWidget customAppBar(BuildContext context,
    TextEditingController searchController, VoidCallback onclearTap, {required int flag}) {
  var tittle='';
  if(flag==4) {
    tittle='Search Product';
  }
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
                  flag==2 || flag==3|| flag==4?
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child:
                    SvgPicture.asset(
                      AppImages.back,
                      height: 24,
                      color: AppColors.kWhiteColor,
                    ),
                  ):SizedBox(),
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