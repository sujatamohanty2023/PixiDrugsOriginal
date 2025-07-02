import 'package:pixidrugs/Stock/ProductTile.dart';
import 'package:pixidrugs/constant/all.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

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
    _fetchStockList();
  }
  void _fetchStockList() {
    setState(() {
      isLoading = true;
    });
    final userId=SessionManager.getUserId();
    context.read<ApiCubit>().fetchStockList(user_id: userId.toString());
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add Product tapped")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimaryLight,
      appBar: customAppBar(context, _searchController, _onBarcodeScan),
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
            if (state is StockListLoaded) {
            setState(() {
              isLoading = false;
              _products.addAll(state.stockList);
              _filteredProducts = _products;
              _searchController.addListener(_onSearch);
            });
          }
        },
        child: isLoading==false && _filteredProducts.isEmpty
            ? _buildEmptyPage()
            : Container(
          decoration: BoxDecoration(
            gradient:AppColors.myGradient,
          ),
          child: ListView.builder(
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) =>
                ProductTile(product: _filteredProducts[index]),
          ),
        ),
      ),
      floatingActionButton: _filteredProducts.isEmpty?SizedBox():SizedBox(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.kPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)),
          onPressed: _onAddProduct,
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("ADD",style: TextStyle(color: Colors.white),),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
Widget _buildEmptyPage() {
  return Container(
    decoration: const BoxDecoration(
      gradient: AppColors.myGradient,
    ),
    child: NoItemPage(
      onTap: (){},
      image: AppImages.empty_cart,
      tittle: "Your list is Empty",
      description: "Looks like you haven't added anything \nto your stock yet.",
      button_tittle:'Add Now',
    ),
  );
}
// ✅ Custom AppBar with search + barcode
PreferredSizeWidget customAppBar(BuildContext context,
    TextEditingController searchController, VoidCallback onBarcodeTap) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(120),
    child: Container(
      decoration: const BoxDecoration(
        color: AppColors.kPrimary, // Teal shade
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Stock List',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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