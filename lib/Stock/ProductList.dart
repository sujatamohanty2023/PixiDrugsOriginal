import 'package:PixiDrugs/Stock/ProductTile.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../search/customerModel.dart';
import '../search/sellerModel.dart';

class ProductListPage extends StatefulWidget {
  final int flag;
  Seller? selectedSeller;
  CustomerModel? selectedCustomer;
  ProductListPage({super.key,required this.flag,this.selectedSeller,this.selectedCustomer});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
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
    if(widget.flag==1) {
      context.read<ApiCubit>().fetchStockList(user_id: userId!);
    }else if(widget.flag==2) {
      context.read<ApiCubit>().expiredStockList(user_id: userId!);
    }else if(widget.flag==3) {
      context.read<ApiCubit>().expireSoonStockList(user_id: userId!);
    }else if(widget.flag==4){
      if(widget.selectedSeller!=null || widget.selectedCustomer !=null) {
        context.read<ApiCubit>().BarcodeScan(code: '', storeId: userId!, source: 'manual',seller_id:widget.selectedSeller?.id.toString()??'',customer_id:widget.selectedCustomer?.id.toString()??'');
      }else{
        context.read<ApiCubit>().fetchStockList(user_id: userId!);
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
        context.read<ApiCubit>().BarcodeScan(code: query, storeId: userId!, source: 'manual',seller_id:widget.selectedSeller?.id.toString()??'',customer_id:widget.selectedCustomer?.id.toString()??'');
      } else {
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
              state is ExpiredStockListLoaded ||
              state is ExpireSoonStockListLoaded||
              state is BarcodeScanLoaded) {
            isLoading=false;
            _products.clear();
            if(widget.flag==4 && state is BarcodeScanLoaded){
              _products.addAll(state.list);
            }else {
              if (state is StockListLoaded) {
                _products.addAll(state.stockList);
              } else if (state is ExpiredStockListLoaded) {
                _products.addAll(state.stockList);
              } else if (state is ExpireSoonStockListLoaded) {
                _products.addAll(state.stockList);
              }
              _filteredProducts = List.from(_products);
            }
          }
        },
          builder: (context, state) {
            Widget content;

            if (state is StockListLoading ||
                state is ExpiredStockListLoading ||
                state is ExpireSoonStockListLoading||
                state is BarcodeScanLoading) {
              content = const Center(
                child: CircularProgressIndicator(color: AppColors.kPrimary),
              );
            } else if (isLoading==false && widget.flag!=4 && _filteredProducts.isEmpty) {
              content = _buildEmptyPage(flag: widget.flag, onAddProduct: _onAddProduct);
            }else {
              content = ListView.builder(
                itemCount: widget.flag==4?_products.length:_filteredProducts.length,
                itemBuilder: (context, index) =>
                    widget.flag==4?Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProductCard(
                        item: _products[index],
                        mode: ProductCardMode.search
                      ),
                    ):ProductTile(product: _filteredProducts[index]),
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
      floatingActionButton: widget.flag==1 &&_filteredProducts.isNotEmpty?SizedBox(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.kPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)),
          onPressed: _onAddProduct,
          icon: const Icon(Icons.add,color: Colors.white,),
          label: MyTextfield.textStyle_w800("ADD",16,AppColors.kWhiteColor,),
        ),
      ):SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
Widget _buildEmptyPage({required int flag,required VoidCallback onAddProduct}) {
  return  Container(
    padding: EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
      gradient: AppColors.myGradient,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(30),
        topLeft: Radius.circular(30),
      ),
    ),
    child: NoItemPage(
      onTap: onAddProduct,
      image: AppImages.no_expiry,
      tittle: "Your list is Empty",
      description: "Looks like you haven't added anything \nto your stock yet.",
      button_tittle: flag==1?'Add Now':'',
    ),
  );
}
// ✅ Custom AppBar with search + barcode
PreferredSizeWidget customAppBar(BuildContext context,
    TextEditingController searchController, VoidCallback onclearTap, {required int flag}) {
  var tittle='';
  if(flag==1) {
    tittle='My Stock';
  }else if(flag==2) {
    tittle='Expired Stock';
  }else if(flag==3) {
    tittle='ExpireSoon Stock';
  }else if(flag==4) {
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