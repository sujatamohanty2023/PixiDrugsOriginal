import '../constant/all.dart';
import 'ProductTile.dart';

class ProductListPage extends StatefulWidget {
  final int flag;
  const ProductListPage({super.key, required this.flag});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<InvoiceItem> _products = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _scrollController.addListener(_onScroll);
    _fetchStockList(refresh: true);
  }

  @override
  void dispose() {
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
      _fetchStockList();
    }
  }

  Future<void> _fetchStockList({bool refresh = false}) async {
    String? userId = await SessionManager.getParentingId();
    if (userId == null) return;

    if (refresh) {
      currentPage = 1;
      hasMoreData = true;
      _products.clear();
    }

    if (isLoadingMore || !hasMoreData) return;
    setState(() => isLoadingMore = true);

    final query = _searchController.text.trim();

    if (widget.flag == 1 || widget.flag == 4) {
      context.read<ApiCubit>().fetchStockList(user_id: userId, page: currentPage, query: query);
    } else if (widget.flag == 2) {
      context.read<ApiCubit>().expiredStockList(user_id: userId, page: currentPage, query: query);
    } else if (widget.flag == 3) {
      context.read<ApiCubit>().expireSoonStockList(user_id: userId, page: currentPage, query: query);
    }
  }

  void _onSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    setState(() {}); // show clear button

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchController.text.trim();
      String? userId = await SessionManager.getParentingId();

      if (query.isNotEmpty && query.length >= 3 && widget.flag == 4) {
        context.read<ApiCubit>().BarcodeScan(code: query, storeId: userId!, source: 'manual');
      } else {
        _fetchStockList(refresh: true);
      }
    });
  }

  Future<void> _onclearTap() async {
    setState(() {
      _searchController.clear();
      _products.clear();
    });
    _fetchStockList(refresh: true);
  }

  void _onAddProduct() {
    AppRoutes.navigateTo(context, AddPurchaseBill());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimary,
      appBar: customAppBar(context, _searchController, _onclearTap, flag: widget.flag),
      body: BlocConsumer<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is StockListLoaded ||
              state is ExpiredStockListLoaded ||
              state is ExpireSoonStockListLoaded ||
              state is BarcodeScanLoaded) {
            if (widget.flag == 4 && state is BarcodeScanLoaded) {
              _products.clear();
              _products.addAll(state.list);
            } else {
              if (currentPage == 1) _products.clear();

              if (state is StockListLoaded) {
                _products.addAll(state.stockList);
                hasMoreData = state.last_page > currentPage;
              } else if (state is ExpiredStockListLoaded) {
                _products.addAll(state.stockList);
                hasMoreData = state.last_page > currentPage;
              } else if (state is ExpireSoonStockListLoaded) {
                _products.addAll(state.stockList);
                hasMoreData = state.last_page > currentPage;
              }

              if (hasMoreData) currentPage++;
            }

            setState(() {
              isLoadingMore = false;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is StockListLoading ||
              state is ExpiredStockListLoading ||
              state is ExpireSoonStockListLoading ||
              state is BarcodeScanLoading;

          Widget content;

          if (isLoading && currentPage == 1) {
            content = const Center(
              child: CircularProgressIndicator(color: AppColors.kPrimary),
            );
          } else if (!isLoading && widget.flag != 4 && _products.isEmpty) {
            content = _buildEmptyPage(flag: widget.flag, onAddProduct: _onAddProduct);
          } else {
            content = Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchStockList(refresh: true),
                    color: AppColors.kPrimary,
                    backgroundColor: AppColors.kPrimaryLight,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.flag == 4
                          ? _products.length
                          : _products.length + (hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (widget.flag == 4) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ProductCard(
                              item: _products[index],
                              mode: ProductCardMode.search,
                            ),
                          );
                        } else {
                          if (index >= _products.length) {
                            return _buildBottomLoader();
                          }
                          return ProductTile(product: _products[index]);
                        }
                      },
                    ),
                  ),
                ),
              ],
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
        },
      ),
      floatingActionButton: widget.flag == 1 && _products.isNotEmpty
          ? FloatingActionButton.extended(
        backgroundColor: AppColors.kPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: _onAddProduct,
        icon: const Icon(Icons.add, color: Colors.white),
        label: MyTextfield.textStyle_w400(
          "ADD",
          SizeConfig.screenWidth! * 0.045,
          AppColors.kWhiteColor,
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ========================= Helpers =========================

Widget _buildBottomLoader() => Padding(
  padding: const EdgeInsets.symmetric(vertical: 16),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: const [
      CircularProgressIndicator(strokeWidth: 2, color: AppColors.kPrimary),
      SizedBox(height: 8),
      Text("Loading more...", style: TextStyle(color: Colors.grey)),
    ],
  ),
);

Widget _buildEmptyPage({required int flag, required VoidCallback onAddProduct}) {
  return Container(
    padding: const EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
      gradient: AppColors.myGradient,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        topLeft: Radius.circular(30),
      ),
    ),
    child: NoItemPage(
      onTap: onAddProduct,
      image: AppImages.no_expiry,
      tittle: "Your list is Empty",
      description: "Looks like you haven't added anything \nto your stock yet.",
      button_tittle: flag == 1 ? 'Add Now' : '',
    ),
  );
}

PreferredSizeWidget customAppBar(
    BuildContext context,
    TextEditingController searchController,
    VoidCallback onclearTap, {
      required int flag,
    }) {
  String getTitle(int flag) {
    switch (flag) {
      case 1:
        return 'My Stock';
      case 2:
        return 'Expired Stock';
      case 3:
        return 'ExpireSoon Stock';
      case 4:
        return 'Search Product';
      default:
        return 'Stock';
    }
  }

  return PreferredSize(
    preferredSize: const Size.fromHeight(92),
    child: Container(
      color: AppColors.kPrimary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  if (flag == 2 || flag == 3 || flag == 4)
                    GestureDetector(
                      onTap: () => Navigator.pop(context,'manualAdd'),
                      child: SvgPicture.asset(
                        AppImages.back,
                        height: 24,
                        color: AppColors.kWhiteColor,
                      ),
                    ),
                  const SizedBox(width: 10),
                  MyTextfield.textStyle_w600(
                    getTitle(flag),
                    SizeConfig.screenWidth! * 0.045,
                    Colors.white,
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
                        decoration: InputDecoration(
                          hintText: 'Search Product/Stockiest Name...',
                          hintStyle: MyTextfield.textStyle(
                              16, Colors.grey, FontWeight.w300),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: onclearTap,
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey),
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
