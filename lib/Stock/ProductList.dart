import 'package:pixidrugs/Stock/ProductTile.dart';
import 'package:pixidrugs/constant/all.dart';

class ProductListPage extends StatefulWidget {
  final int flag;
  const ProductListPage({super.key,required this.flag});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<InvoiceItem> _products = [];
  List<InvoiceItem> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
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
  void _fetchStockList() {
    setState(() {
      isLoading = true;
    });
    final userId=SessionManager.getUserId();
    if(widget.flag==1) {
      context.read<ApiCubit>().fetchStockList(user_id: userId.toString(),);
    }else if(widget.flag==2) {
      context.read<ApiCubit>().expiredStockList(user_id: userId.toString(),);
    }else if(widget.flag==3) {
      context.read<ApiCubit>().expireSoonStockList(user_id: userId.toString(),);
    }
  }
  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.product.toLowerCase().contains(query) ||
            product.hsn.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onBarcodeScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Barcode scan tapped")),
    );
  }

  void _onAddProduct() {
    AppRoutes.navigateTo(context, AddPurchaseBill());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimary,
      appBar: customAppBar(context, _searchController, _onBarcodeScan,flag:widget.flag),
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          setState(() {
            isLoading = false;
            if (state is StockListLoaded) {
              _products.addAll(state.stockList);
            }else  if (state is ExpiredStockListLoaded) {
              _products.addAll(state.stockList);
            }
            else  if (state is ExpireSoonStockListLoaded) {
              _products.addAll(state.stockList);
            }
            _filteredProducts = _products;
          });

        },
        child: isLoading==false && _filteredProducts.isEmpty
            ? _buildEmptyPage(flag:widget.flag,onAddProduct: _onAddProduct)
            :  Container(
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            gradient: AppColors.myGradient,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: ListView.builder(
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) =>
                ProductTile(product: _filteredProducts[index]),
          ),
        ),
      ),
      floatingActionButton: widget.flag==1 &&_filteredProducts.isNotEmpty?SizedBox(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.kPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)),
          onPressed: _onAddProduct,
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("ADD",style: TextStyle(color: Colors.white),),
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
      image: AppImages.empty_cart,
      tittle: "Your list is Empty",
      description: "Looks like you haven't added anything \nto your stock yet.",
      button_tittle: flag==1?'Add Now':'',
    ),
  );
}
// ✅ Custom AppBar with search + barcode
PreferredSizeWidget customAppBar(BuildContext context,
    TextEditingController searchController, VoidCallback onBarcodeTap, {required int flag}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(115),
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
                  flag==2 || flag==3?
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
                  const Text(
                    'Stock List',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                        decoration: const InputDecoration(
                          hintText: 'Search here...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onBarcodeTap,
                      icon: const Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.kPrimary),
                    ),
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