import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constant/all.dart';
import '../customWidget/CustomAppBar.dart';
import 'ProductTile.dart';
import 'StockFilterWidget.dart';

class ProductListPage extends StatefulWidget {
  final List<InvoiceItem> searchResults;
  final int flag;
  ProductListPage({super.key, required this.flag,this.searchResults=const []});

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

  String? sellerName='';
  String? medicineName='';
  String? composition='';
  String? selectedStockStatus='';
  String? selectedExpiryStatus='';

  bool isInitialLoading = true;

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.myGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(10),
                child: StockFilterWidget(
                  onApply: (sellerName1, medicineName1, composition1, stockStatus, expiryStatus) {
                    var stockStatusApi='';
                    if(stockStatus=='In stock'){
                      stockStatusApi='in_stock';
                    }else if(stockStatus=='Out of stock'){
                      stockStatusApi='out_of_stock';
                    }else if(stockStatus=='Highest stock'){
                      stockStatusApi='highstock';
                    }else if(stockStatus=='Lowest stock'){
                      stockStatusApi='lowstock';
                    }

                    setState(() {
                      // Update the filter parameters
                      sellerName = sellerName1;
                      medicineName = medicineName1;
                      composition = composition1;
                      selectedStockStatus = stockStatusApi;
                      selectedExpiryStatus = expiryStatus?.toLowerCase();
                    });
                    _fetchStockList(refresh: true);
                    Navigator.pop(context);  // Close the filter sheet
                  },
                  onReset: () {
                    setState(() {
                      // Reset all filters
                      sellerName = '';
                      medicineName = '';
                      composition = '';
                      selectedStockStatus = '';  // Default value for stock status
                      selectedExpiryStatus = '';  // Default value for expiry status
                    });
                    _fetchStockList(refresh: true);
                  },
                  sellerName: sellerName,
                  medicineName: medicineName,
                  composition: composition,
                  stockStatus: selectedStockStatus,
                  expiryStatus: selectedExpiryStatus,
                ),
              );
            },
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _scrollController.addListener(_onScroll);
    print("API${widget.searchResults.length}");
    if(widget.flag==4 && widget.searchResults.isNotEmpty){
      _products.addAll(widget.searchResults);
      hasMoreData = false;
      isInitialLoading=false;
    }else {
      _fetchStockList(refresh: true);
    }
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
      setState(() {
        isInitialLoading = true;
      });
    }

    if (isLoadingMore || !hasMoreData) return;
    setState(() => isLoadingMore = true);

    final query = _searchController.text.trim();

    final filter = {
      'seller': sellerName,
      'medicine': medicineName,
      'composition': composition,
      'stock_status': selectedStockStatus,
      'expiry_status': selectedExpiryStatus,
    };

    if (widget.flag == 1) {
      context.read<ApiCubit>().fetchStockList(user_id: userId, page: currentPage, query: query, filters: filter);
    } else if (widget.flag == 4) {
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
        // For barcode scan, disable pagination
        hasMoreData = false;
        context.read<ApiCubit>().BarcodeScan(code: query, storeId: userId!, source: 'manual');
      } else {
        // For regular search and other operations, enable pagination
        hasMoreData = true;
        _fetchStockList(refresh: true);
      }
    });
  }

  Future<void> _onclearTap() async {
    setState(() {
      _searchController.clear();
      _products.clear();
      hasMoreData = true; // Re-enable pagination when clearing search
    });
    _fetchStockList(refresh: true);
  }

  void _onAddProduct() {
    AppRoutes.navigateTo(context, AddPurchaseBill());
  }
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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (widget.flag == 4) {
            Navigator.pop(context);
            return false; // Prevent default pop
          }
          return true;
        },
        child:  Scaffold(
      backgroundColor: AppColors.kPrimary,
      appBar: widget.flag == 4 
        ? CustomAppBar(
            title: getTitle(widget.flag),
            showSearch: true,
            searchController: _searchController,
            searchHint: 'Search Product/Stockiest Name...',
            onSearchClear: _onclearTap,
            onSearchChanged: (value) => setState(() {}),
            showCartButton: true,
            onCartPressed: () => Navigator.pop(context, {"goToCart": true}),
          )
        : CustomAppBar(
            title: getTitle(widget.flag),
            showSearch: true,
            searchController: _searchController,
            searchHint: 'Search Product/Stockiest Name...',
            showBackButton: widget.flag == 2 || widget.flag == 3,
            onSearchClear: _onclearTap,
            onSearchChanged: (value) => setState(() {}),
            showFilterButton: widget.flag == 1,
            onFilterPressed: widget.flag == 1 ? _showFilterSheet : null,
          ),
      body: BlocConsumer<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is StockListLoaded || state is ExpiredStockListLoaded || state is ExpireSoonStockListLoaded || state is BarcodeScanLoaded) {
            // Add data to list
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
              isInitialLoading = false; // Mark initial load complete
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

          if (isInitialLoading) {
            content = Center(
                child: SpinKitThreeBounce(
                  color:AppColors.kPrimary,
                  size: 30.0,
                )
            );
          } else if (_products.isEmpty) {
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
                      itemCount: _products.length + (hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _products.length) {
                          return _buildBottomLoader();
                        }
                        
                        if (widget.flag == 4) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ProductCard(
                              item: _products[index],
                              mode: ProductCardMode.search,
                            ),
                          );
                        } else {
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
    )
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



