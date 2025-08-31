import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:PixiDrugs/constant/all.dart';
import '../Dialog/AddPurchaseBottomSheet.dart';
import '../Dialog/update_bottom_sheet.dart';
import '../Profile/contact_us.dart';
import '../ReturnCart/ReturnCartTab.dart';
import '../login/mobileLoginScreen.dart';
import '../report/report_page.dart';
import 'YoutubeVideoListPage.dart';

class DashboardItem {
  final String title;
  final String desc;
  final String icon;
  final VoidCallback onTap;

  DashboardItem({required this.title, required this.desc, required this.icon, required this.onTap});
}

class HomeTab extends StatefulWidget {
  final VoidCallback onGoToCart;
  const HomeTab({Key? key, required this.onGoToCart}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> bannerList = [];

  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  String? name = 'Guest';
  String? email = '';
  String? image = '';
  StreamSubscription? _profileSubscription;
  var dashboardItems = [];

  @override
  void initState() {
    super.initState();
    _GetProfileCall();
    _GetStaffStatusCheck();
    _GetBanner();

    _timer = Timer.periodic(Duration(seconds: 8), (Timer timer) {
      if (_currentPage < bannerList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    dashboardItems = [
      DashboardItem(title: "New Sale Entry",desc: "Record a new sale", icon:AppImages.sale,
          onTap:() {
            _newSaleEntry('Start New Sale', 'This will clear the previous cart. Do you want to continue?',CartTypeSelection.Sale);
          }
      ),
      DashboardItem(title: "Sales Report", desc:"Track sales summary", icon:AppImages.sale_list, onTap: () {
        AppRoutes.navigateTo(context, ListScreen(type: ListType.sale));
      }),
      DashboardItem(title: "Upload Invoice",desc: "Create a new invoice", icon:AppImages.add_invoice,onTap:  _UploadInvoice),
      DashboardItem(title: "Invoice History", desc:"View all previous invoices", icon:AppImages.invoice_list,onTap:  () {
        AppRoutes.navigateTo(context, ListScreen(type: ListType.invoice));
      }),
      DashboardItem(title: "Expired Product",desc: "View expired items", icon:AppImages.expired,onTap:  () {
        Navigator.pushNamed(context, '/stockList', arguments: 2);
      }),
      DashboardItem(title: "Expire Soon", desc:"Track nearing expiry your product", icon:AppImages.notification,onTap:  () {
        Navigator.pushNamed(context, '/stockList', arguments: 3);
      }),
      DashboardItem(title: "Stockist Return",desc: "Return products back to stockist", icon:AppImages.purchase_return, onTap: () {
        /*showDialog(
          context: context,
          builder: (_) => EditValueDialog(
            title: 'Invoice No.',
            initialValue: '',
            type: 'stockReturn',
          ),
        );*/
        _newSaleEntry('Start New Stockist Return', 'This will clear the previous cart. Do you want to continue?',CartTypeSelection.StockiestReturn);
      }),
      DashboardItem(title: "Customer Return",desc: "Manage products returned by customers", icon:AppImages.sale_return,onTap:  () {
        /*showDialog(
          context: context,
          builder: (_) => EditValueDialog(
            title: 'Bill No.',
            initialValue: '',
            type: 'saleReturn',
          ),
        );*/
        _newSaleEntry('Start New Customer Return', 'This will clear the previous cart. Do you want to continue?',CartTypeSelection.CustomerReturn);
      }),
      DashboardItem(title: "Stock Return List", desc:"View returns made to suppliers", icon:AppImages.stockiest_return,onTap:  () {
        AppRoutes.navigateTo(context, ListScreen(type: ListType.stockReturn));
      }),
      DashboardItem(title: "Sale Return List", desc:"View returns received from customers", icon:AppImages.customer_return,onTap:  () {
        AppRoutes.navigateTo(context, ListScreen(type: ListType.saleReturn));
      }),
      DashboardItem(title: "Top Creditors", desc:"View returns made to suppliers", icon:AppImages.creditor,onTap:  () {
        AppRoutes.navigateTo(context, ListScreen(type: ListType.stockReturn));
      }),
      DashboardItem(title: "Top Debitors", desc:"View returns received from customers", icon:AppImages.debitor,onTap:  () {
        AppRoutes.navigateTo(context, ListScreen(type: ListType.saleReturn));
      }),
    ];

  }

  void _logoutFun() async {
    await SessionManager.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MobileLoginScreen()),
          (route) => false,
    );
  }
  Future<void> showLoginFailedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: MyTextfield.textStyle_w600("Session Failed", 25, AppColors.kPrimary),
            content: MyTextfield.textStyle_w300(
              "Please contact our support team for assistance. Or try logging in again.",
              16,
              AppColors.kBlackColor800,
            ),
            actions: [
              TextButton(
                onPressed: _logoutFun,
                child: MyTextfield.textStyle_w800('Login Again', 18, AppColors.kRedColor),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.kPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.kPrimaryDark, width: 1),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ContactUsPage()/*Webviewscreen(tittle: 'Contact Us')*/),
                    );
                  },
                  child: MyTextfield.textStyle_w800('Contact', 18, AppColors.kWhiteColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _GetProfileCall() async {
    String? userId = await SessionManager.getParentingId();
    String? role = await SessionManager.getRole();
    if (userId != null) {
      context.read<ApiCubit>().GetUserData(userId: userId, useCache: false);
    }

    await _profileSubscription?.cancel();

    _profileSubscription = context.read<ApiCubit>().stream.listen((state) {
      if (state is UserProfileLoaded) {
        name = state.userModel.user.name;
        email = state.userModel.user.email;
        image = state.userModel.user.profilePicture;
        if (role == 'owner' && state.userModel.user.status != 'active') {
          showLoginFailedDialog(context);
        }
      } else if (state is UserProfileError) {
        AppUtils.showSnackBar(context, 'Failed: ${state.error}');
      }
    });
  }

  void _GetStaffStatusCheck() async {
    String? userId = await SessionManager.getUserId();
    String? role = await SessionManager.getRole();
    if (role == 'staff' && userId != null) {
      context.read<ApiCubit>().GetUserData(userId: userId);
    }

    await _profileSubscription?.cancel();

    _profileSubscription = context.read<ApiCubit>().stream.listen((state) {
      if (state is UserProfileLoaded) {
        setState(() {
          name = state.userModel.user.name;
          email = state.userModel.user.email;
          image = state.userModel.user.profilePicture;
        });
        if (role == 'staff' && state.userModel.user.status != 'active') {
          showLoginFailedDialog(context);
        }
      } else if (state is UserProfileError) {
        AppUtils.showSnackBar(context, 'Failed: ${state.error}');
      }
    });
  }

  void _GetBanner() {
    context.read<ApiCubit>().fetchBanner();
    context.read<ApiCubit>().stream.listen((state) {
      if (state is BannerLoaded) {
        setState(() {
          bannerList.clear();
          bannerList.addAll(state.banner.map((e) => e.photo ?? '').toList());
        });
      } else if (state is BannerError) {
        AppUtils.showSnackBar(context, 'Failed: ${state.error}');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onYouTubeTap() async {
    AppRoutes.navigateTo(context, YoutubeVideoListPage());
  }

  PreferredSizeWidget customAppBarHome(BuildContext context, VoidCallback onYouTubeTap) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Container(
        color: AppColors.kPrimary,
        padding: const EdgeInsets.only(top: 22.0, left: 12, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: SizeConfig.screenWidth! * 0.07,
              backgroundColor: AppColors.kWhiteColor,
              backgroundImage: image != null && image!.isNotEmpty
                  ? (image!.contains('https://')
                  ? NetworkImage(image!)
                  : NetworkImage('${AppString.baseUrl}${image!}')) as ImageProvider
                  : AssetImage(AppImages.AppIcon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyTextfield.textStyle_w600(
                      name ?? 'Guest', SizeConfig.screenWidth! * 0.055, Colors.white,maxLines: true),
                  Text(
                    email ?? '',
                    style: TextStyle(
                        color: AppColors.kWhiteColor.withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                        fontSize: SizeConfig.screenWidth! * 0.035),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onYouTubeTap,
              child: SvgPicture.asset(
                AppImages.youtube,
                height: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.kPrimary,
      appBar: customAppBarHome(context, _onYouTubeTap),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Update Banner (instead of button)
                /*InkWell(
                  onTap: () => {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [
                              MyTextfield.textStyle_w400(
                                  "A Newer App Version is Available",
                                  SizeConfig.screenWidth! * 0.04,
                                  Colors.white
                              ),
                              SizedBox(height: 4),
                              MyTextfield.textStyle_w400(
                                  "Click this Banner to Update App to Latest Version",
                                  SizeConfig.screenWidth! * 0.03,
                                  Colors.white
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),*/
                SizedBox(
                  height: screenHeight * 0.18,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: bannerList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage('http://pixidrugs.com/${bannerList[index]}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 5),
                const ReportPage(),
                const SizedBox(height: 10),

                MyTextfield.textStyle_w800("My DashBoard", SizeConfig.screenWidth! * 0.055, Colors.black87),
                const SizedBox(height: 10),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(), // Prevents scroll conflict
                  shrinkWrap: true, // Makes GridView take only needed height
                  itemCount: dashboardItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return _dashboardTile(item.title, item.desc, item.icon, item.onTap);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dashboardTile(String title, String desc, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _buildTaskCard(title: title, tasks: desc, icon: icon),
    );
  }

  Future<void> _UploadInvoice() async {
    AddPurchaseBottomSheet(context, _setSelectedImage, pdf: true, pick_Size: 5, ManualAdd: true);
  }

  Future<void> _setSelectedImage(List<File> files) async {
    if (files.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(
            paths: files.map((e) => e.path).toList(),
          ),
        ),
      );
    }
  }

  Future<void> _newSaleEntry(String tittle,String content,CartTypeSelection type) async {
    CommonConfirmationDialog.show<int>(
      context: context,
      id: 0,
      title: tittle,
      content: content,
      negativeButton: 'Cancel',
      positiveButton: 'Yes, Start New',
      onConfirmed: (int) async {
        context.read<CartCubit>().clearCart(type: CartType.barcode);
        if(type==CartTypeSelection.Sale){
          widget.onGoToCart();
        }else{
          AppRoutes.navigateTo(context, ReturnCartTab(cartTypeSelection:type));
        }
      },
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String tasks,
    required String icon,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.myGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1, color: AppColors.kPrimaryLight),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16,bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.kPrimaryDark,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(icon, height: 40, width: 40, color: AppColors.kPrimary),
                      ),
                    ),
                    const SizedBox(height: 5),
                    //MyTextfield.textStyle_w600(title, SizeConfig.screenWidth! * 0.043, AppColors.kPrimary),
                    //MyTextfield.textStyle_w300(tasks, SizeConfig.screenWidth! * 0.030, AppColors.kPrimary.withOpacity(0.6)),
                  ],
                ),
              ),
              /*Positioned(
                bottom: 0,
                right: 0,
                child: ClipPath(
                  clipper: ArrowCornerClipper(),
                  child: Container(
                    width: 55,
                    height: 35,
                    color: AppColors.kPrimary,
                    child: const Icon(Icons.arrow_forward, size: 22, color: Colors.white),
                  ),
                ),
              ),*/
            ],
          ),
        ),
        SizedBox(height: 5,),
        MyTextfield.textStyle_w600(title, SizeConfig.screenWidth! * 0.035, AppColors.kPrimary),
      ],
    );
  }
  void _showUpdateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const UpdateBottomSheet(),
    );
  }
}

class ArrowCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double curveRadius = 20;
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, curveRadius);
    path.quadraticBezierTo(0, 0, curveRadius, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(size.width, size.height, size.width * 0.5, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
