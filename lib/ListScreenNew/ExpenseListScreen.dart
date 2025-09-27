
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Api/app_initialization_service.dart';

import 'package:intl/intl.dart';
import '../Expense/AddExpenseScreen.dart';
import '../Expense/ExpenseResponse.dart';
import '../Home/HomePageScreen.dart';
import '../../constant/all.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';
import 'FilterWidget.dart';

class ExpenseListScreen extends StatefulWidget {

  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> with WidgetsBindingObserver, RouteAware {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  String? role;
  UserProfile? user;

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isRefresh = false;

  final expenseList = <ExpenseResponse>[];

  DateTime? fromDate;
  DateTime? toDate;
  String selectedRange = '';
  String selectedPaymentType = '';
  String selectedPaymentReason = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearch);
    _scrollController.addListener(_onScroll);
    _fetchRecord(refresh: true);
  }
  Future<void> _loadUserRole() async {
    role = await AppInitializationService.getRole();
    user=AppInitializationService.getCachedProfile(context);
    // Profile is already loaded at app startup, no need to call API
  }

  @override
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
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
      _fetchRecord();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("API=resume");
      //_fetchRecord(refresh: true);
    }
  }

  /* @override
  void didPopNext() => _fetchRecord();*/

  Future<void> _fetchRecord({bool refresh = false}) async {
    final userId = await SessionManager.getParentingId();
    if (userId == null) return;

    if (refresh) {
      currentPage = 1;
      hasMoreData = true;
      isRefresh=true;
    }

    if (isLoadingMore || !hasMoreData) return;

    setState(() => isLoadingMore = true);

    String? from = fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : null;
    String? to = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : null;

    await context.read<ApiCubit>().fetchExpenseList(store_id: userId, page: currentPage,from:from??'',to:to??'',reason:selectedPaymentReason,filter: searchQuery);
    setState(() => isLoadingMore = false);
  }

  void _updatePaginatedList<T extends Object>(
      List<T> targetList,
      List<T> newItems,
      int lastPage,
      ) {
    if (isRefresh) {
      targetList.clear();
      isRefresh = false;
    }

    for (var newItem in newItems) {
      final index = targetList.indexWhere((oldItem) {
        if (oldItem is Invoice && newItem is Invoice) {
          return oldItem.id == newItem.id; // ✅ compare by unique ID
        }
        return oldItem == newItem; // fallback for other types
      });

      if (index >= 0) {
        // Item already exists → check if changed
        if (targetList[index] != newItem) {
          targetList[index] = newItem; // ✅ replace with updated one
        }
      } else {
        // Item not found → add it
        targetList.add(newItem);
      }
    }

    hasMoreData = lastPage > currentPage;
    if (hasMoreData) currentPage++;
  }
  // ---- Build Method ----

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocBuilder<ApiCubit, ApiState>(
        builder: (context, state) {
          final isLoading = state is ExpenseListLoading;

          // Populate lists from state
          if (state is ExpenseListLoaded) {
            _updatePaginatedList(expenseList, state.list, state.last_page);
          }else if (state is UserProfileLoaded) {
            user = state.userModel.user;
          }

          return Container(
            color: AppColors.kPrimary,
            padding: EdgeInsets.only(top: screenWidth * 0.06),
            child: Column(
              children: [
                _buildTopBar(screenWidth),
                SizedBox(height: screenWidth * 0.01,),
                _buildSearchBar(screenWidth),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchRecord(refresh: true),
                    color: AppColors.kPrimary,
                    backgroundColor: AppColors.kPrimaryLight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.myGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(screenWidth * 0.07),
                          topRight: Radius.circular(screenWidth * 0.07),
                        ),
                      ),
                      child:(isLoading || isRefresh) && expenseList.isEmpty?
                      Center(
                        child: SpinKitThreeBounce(
                          color: AppColors.kPrimary,
                          size: 30.0,
                        ),
                      )
                          : (!isLoading && !isRefresh) && expenseList.isEmpty
                          ? NoItemPage(
                        onTap: _onAddExpense,
                        image: AppImages.no_invoice,
                        tittle: 'No Expenses Found',
                        description: 'You haven\'t recorded any expenses yet. Add your first expense to keep track of your store\'s spending.',
                        button_tittle: 'Add Expense',
                      )
                          : _buildListBody(isLoading),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<ApiCubit, ApiState>(
        builder: (context, state) {
          // Show floating action button only when list is not empty
          if (expenseList.isNotEmpty) {
            return FloatingActionButton(
              onPressed: _onAddExpense,
              backgroundColor: AppColors.kPrimary,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              tooltip: 'Add Expense',
            );
          }
          return SizedBox.shrink(); // Hide when list is empty
        },
      ),
    );
  }
  Future<void> _onAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Addexpensescreen()),
    );

    if (result == true) {
      _fetchRecord(refresh: true);
    }
  }
  Widget _buildTopBar(double screenWidth) {
    return Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.02,right: screenWidth * 0.02),
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
            Expanded(
              child: MyTextfield.textStyle_w400(
                'Expense List',
                screenWidth * 0.052,
                Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: _showFilterTopSheet,
            )
          ],
        ));
  }
  void _showFilterTopSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
            color: AppColors.kWhiteColor,
            child: Container(
              width: double.infinity,
              child: FilterWidget(
                  type:ListType.expense,
                  initialFrom: fromDate,
                  initialTo: toDate,
                  initialRange: selectedRange,
                  initialPaymentType:selectedPaymentType,
                  initialPaymentReason: selectedPaymentReason,
                  onApply: (from, to, range, paymentType,paymentReason) async {
                    setState(() {
                      fromDate = from;
                      toDate = to;
                      selectedRange = range;
                      selectedPaymentType = paymentType??'';
                      selectedPaymentReason = paymentReason??'';
                    });
                    await _fetchRecord(refresh: true);
                    if (mounted) Navigator.pop(context);
                  },
                  onReset:() async {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                      selectedRange = '';
                      selectedPaymentType = '';
                      selectedPaymentReason='';
                    });
                    await _fetchRecord(refresh: true);
                    if (mounted) Navigator.pop(context);
                  }
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1),  // start above the screen
            end: Offset(0, 0),     // slide to original position
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }
  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.03,right: screenWidth * 0.03,bottom:screenWidth * 0.03 ),
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by expense title or category',
                  hintStyle: MyTextfield.textStyle(
                      16, Colors.grey, FontWeight.w300),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                onPressed: _onclearTap,
                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
  void _onSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    setState(() {}); // show clear button

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchController.text.trim();

      if (query.length >= 3 || query.isEmpty) {
        if (query != searchQuery) {
          setState(() {
            searchQuery = query;
          });
        }
        _fetchRecord(refresh: true);
      }
    });
  }

  Future<void> _onclearTap() async {
    setState(() {
      _searchController.clear();
      searchQuery='';
    });
    _fetchRecord(refresh: true);
  }
  Widget _buildListBody(bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = expenseList.length + (hasMoreData ? 1 : 0);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == itemCount-1 && hasMoreData) {
            return BottomLoader();
          }
          return _buildExpenseCard(expenseList[index], screenWidth,context);
        },
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseResponse item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        GoNextPageFun(items:item);
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            children: [
              GradientInitialsBox(
                size: screenWidth * 0.15,
                name: item.title,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.title,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('Dt: ${item.expanseDate}',screenWidth * 0.035,Colors.grey.shade700,maxLines: true),
                    MyTextfield.textStyle_w600("Reason: ${item.note}", screenWidth * 0.035, Colors.teal,maxLines: true),
                    SizedBox(height: screenWidth * 0.01)
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: screenWidth * 0.015),
                  Builder(
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        child: MyTextfield.textStyle_w600(
                          "₹${item.amount}",
                          screenWidth * 0.04,
                          Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> GoNextPageFun({bool edit=false, required ExpenseResponse items}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Addexpensescreen(expenseResponse: items)),
    );

    if (result == true) {
      _fetchRecord(refresh: true);
    }
  }
}
