
import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:intl/intl.dart';
import '../Home/HomePageScreen.dart';
import '../Staff/AddStaffScreen.dart';
import '../Staff/StaffModel.dart';
import '../constant/all.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';
import '../ListPageScreen/FilterWidget.dart';

class StaffListScreen extends StatefulWidget {

  const StaffListScreen({Key? key}) : super(key: key);

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> with WidgetsBindingObserver, RouteAware {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool isRefresh = false;

  final staffList = <StaffModel>[];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _fetchRecord(refresh: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
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

    await context.read<ApiCubit>().fetchStaffList(store_id: userId, page: currentPage);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocBuilder<ApiCubit, ApiState>(
        builder: (context, state) {
          final isLoading = state is StaffListLoading;

          // Populate lists from state
          if (state is StaffListLoaded) {
            _updatePaginatedList(staffList, state.staffList, state.last_page);
          }

          return Container(
            color: AppColors.kPrimary,
            padding: EdgeInsets.only(top: screenWidth * 0.06),
            child: Column(
              children: [
                _buildTopBar(screenWidth),
                SizedBox(height: screenWidth * 0.01,),
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
                      child:(isLoading || isRefresh) && staffList.isEmpty?
                      Center(child: CircularProgressIndicator(color: AppColors.kPrimary))
                          : (!isLoading && !isRefresh) && staffList.isEmpty
                          ?NoItemPage(
                        onTap: _onAddStaff,
                        image: AppImages.empty_cart,
                        tittle: "No Staff Members",
                        description: "Add staff to manage inventory, sales,\nand keep your business running smoothly.",
                        button_tittle: "Add Staff",
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
    );
  }
  Future<void> _onAddStaff() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddStaffScreen(add: true)),
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
                'Staff List',
                screenWidth * 0.052,
                Colors.white,
              ),
            ),
          ],
        ));
  }
  Widget _buildListBody(bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = staffList.length + (hasMoreData ? 1 : 0);
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
          return _buildStaffCard(staffList[index], screenWidth,context);
        },
      ),
    );
  }

  Widget _buildStaffCard(StaffModel item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        GoNextPageFun(items: item);
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
                name: item.name,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.name,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('Email: ${item.email}',screenWidth * 0.035,Colors.grey.shade700,maxLines: true),
                    SizedBox(height: screenWidth * 0.01),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.status == 'active' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: item.status == 'active' ? Colors.green : Colors.red,
                        ),
                      ),
                      child:
                      MyTextfield.textStyle_w800(
                          item.status,
                          14,
                          item.status == 'active' ? Colors.green : Colors.red
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01)
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      "tel:+91${item.phoneNumber}",
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.call,
                    color: Colors.green,
                    size: 25,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> GoNextPageFun({bool edit=false, required StaffModel items}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>  AddStaffScreen(staff: items),));

    if (result == true) {
      _fetchRecord(refresh: true);
    }
  }
}
