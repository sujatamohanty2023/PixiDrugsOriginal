import 'package:PixiDrugs/widgets/ErrorHandler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Api/app_initialization_service.dart';
import '../../constant/all.dart';
import '../Dialog/AddPurchaseBottomSheet.dart';
import '../Dialog/update_bottom_sheet.dart';
import '../ListScreenNew/InvoiceReportScreen.dart';
import '../ListScreenNew/SaleReportScreen.dart';
import '../ListScreenNew/SaleReturnListScreen.dart';
import '../ListScreenNew/StockistReturnList.dart';
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
  final VoidCallback onQuickScan;
  const HomeTab({Key? key, required this.onGoToCart, required this.onQuickScan}) : super(key: key);

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
  StreamSubscription? _bannerSubscription;
  var dashboardItems = [];
  bool _showReport = false;
  bool _bannerLoading = true;
  bool _bannerLoadError = false;

  @override
  void initState() {
    super.initState();
    _GetProfileCall();
    _GetStaffStatusCheck();
    _GetBanner();
    dashboardItems = [
      DashboardItem(title: "New Sale Entry",desc: "Record a new sale", icon:AppImages.sale,
          onTap:() {
            _newSaleEntry('Start New Sale', 'This will clear the previous cart. Do you want to continue?');
          }
      ),
      DashboardItem(title: "Sales Report", desc:"Track sales summary", icon:AppImages.sale_list, onTap: () {
        AppRoutes.navigateTo(context, Salereportscreen());
      }),
      DashboardItem(title: "Upload Invoice",desc: "Create a new invoice", icon:AppImages.add_invoice,onTap:  _UploadInvoice),
      DashboardItem(title: "Invoice History", desc:"View all previous invoices", icon:AppImages.invoice_list,onTap:  () {
        //AppRoutes.navigateTo(context, ListScreen(type: ListType.invoice));
        AppRoutes.navigateTo(context, Invoicereportscreen());
      }),
      DashboardItem(title: "Expired Product",desc: "View expired items", icon:AppImages.expired,onTap:  () {
        Navigator.pushNamed(context, '/stockList', arguments: 2);
      }),
      DashboardItem(title: "Expire Soon", desc:"Track nearing expiry your product", icon:AppImages.expire_soon,onTap:  () {
        Navigator.pushNamed(context, '/stockList', arguments: 3);
      }),
      DashboardItem(title: "Stockist Return",desc: "Return products back to stockist", icon:AppImages.purchase_return, onTap: () {
        _returnProduct('Start New Stockist Return', 'This will clear the previous cart. Do you want to continue?',CartTypeSelection.StockiestReturn,1);
      }),
      DashboardItem(title: "Customer Return",desc: "Manage products returned by customers", icon:AppImages.sale_return,onTap:  () {
        _returnProduct('Start New Customer Return', 'This will clear the previous cart. Do you want to continue?',CartTypeSelection.CustomerReturn,2);
      }),
      DashboardItem(title: "Stock Return List", desc:"View returns made to suppliers", icon:AppImages.stock_return,onTap:  () {
        AppRoutes.navigateTo(context, StockistReturnScreen());
      }),
      DashboardItem(title: "Sale Return List", desc:"View returns received from customers", icon:AppImages.customer_return,onTap:  () {
        AppRoutes.navigateTo(context, SaleReturnScreen());
      }),
      DashboardItem(title: "Top Creditors", desc:"View returns made to suppliers", icon:AppImages.creditor,onTap:  () {
        AppRoutes.navigateTo(context, Invoicereportscreen(topCreditor: true,));
      }),
      DashboardItem(title: "Top Debitors", desc:"View returns received from customers", icon:AppImages.debitor,onTap:  () {
        AppRoutes.navigateTo(context, Salereportscreen(topDebitor: true,));
      }),
    ];

  }

  void _GetProfileCall() async {
    String? role = await SessionManager.getRole();
    String? userId = await SessionManager.getParentingId();
    final apiCubit = context.read<ApiCubit>();

    // Profile is already loaded during app startup, just use cached data
    if (apiCubit.cachedUser != null) {
      name = apiCubit.cachedUser!.user.name;
      email = apiCubit.cachedUser!.user.email;
      image = apiCubit.cachedUser!.user.profilePicture;

      if (role == 'owner' && apiCubit.cachedUser!.user.status != 'active') {
        ErrorHandler.showAuthenticationErrorDialog(context);
      }
    } else {
      // ❌ ID is null or user not cached – make API call
      apiCubit.GetUserData(userId:userId!); // You might already have this method
    }
    await _profileSubscription?.cancel();

    _profileSubscription = context.read<ApiCubit>().stream.listen((state) {
      if (state is UserProfileLoaded) {
        name = state.userModel.user.name;
        email = state.userModel.user.email;
        image = state.userModel.user.profilePicture;
        if (role == 'owner' && state.userModel.user.status != 'active') {
          ErrorHandler.showAuthenticationErrorDialog(context);
        }
      } else if (state is UserProfileError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ErrorHandler.showErrorRetry(context,state.error,() async => _GetProfileCall());
        });
      }
    });
  }

  void _GetStaffStatusCheck() async {
    String? role = await AppInitializationService.getRole();
    final apiCubit = context.read<ApiCubit>();

    // Profile is already loaded during app startup, just use cached data for staff check
    if (role == 'staff' && apiCubit.cachedUser != null) {
      // Staff status check using cached data
      // Add your staff status check logic here if needed
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
          ErrorHandler.showAuthenticationErrorDialog(context);
        }
      } else if (state is UserProfileError) {
        AppUtils.showSnackBar(context, 'Failed: ${state.error}');
      }
    });
  }

  void _GetBanner() async {
    // Cancel previous subscription to avoid memory leaks
    await _bannerSubscription?.cancel();
    
    // Fetch banner data
    setState(() {
      _bannerLoading = true;
      _bannerLoadError = false;
    });
    
    final apiCubit = context.read<ApiCubit>();
    apiCubit.fetchBanner();
    
    _bannerSubscription = apiCubit.stream.listen((state) {
      if (mounted) {
        if (state is BannerLoaded) {
          setState(() {
            bannerList.clear();
            bannerList.addAll(state.banner.map((e) => e.photo ?? '').where((photo) => photo.isNotEmpty).toList());
            _bannerLoading = false;
            _bannerLoadError = false;
          });
          _startBannerTimer();
        } else if (state is BannerError) {
          setState(() {
            _bannerLoading = false;
            _bannerLoadError = true;
          });
        }
      }
    });
  }
  
  void _startBannerTimer() {
    _timer?.cancel(); // Cancel existing timer
    if (bannerList.length > 1) {
      _timer = Timer.periodic(Duration(seconds: 8), (Timer timer) {
        if (mounted && _pageController.hasClients) {
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
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _profileSubscription?.cancel();
    _bannerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onYouTubeTap() async {
    AppRoutes.navigateTo(context, YoutubeVideoListPage());
  }

  PreferredSizeWidget customAppBarHome(BuildContext context, VoidCallback onYouTubeTap) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        color: AppColors.kPrimary,
        padding: EdgeInsets.only(left: SizeConfig.screenWidth! * 0.02, right: SizeConfig.screenWidth! * 0.02),
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
                      name ?? '', SizeConfig.screenWidth! * 0.055, Colors.white,maxLines: true),
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
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: SvgPicture.asset(
                  AppImages.youtube,
                  height: 30,
                ),
              ),
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                final itemCount = cartState is CartLoaded ? cartState.cartItems.length : 0;

                return GestureDetector(
                  onTap: widget.onGoToCart,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset(
                          AppImages.cart,
                          height: 30,
                          color: Colors.white,
                        ),
                        if (itemCount > 0)
                          Positioned(
                            right: 0,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 15,
                                minHeight: 15,
                              ),
                              child: Center(
                                child: MyTextfield.textStyle_w600(
                                  itemCount > 99 ? '99+' : itemCount.toString(),
                                  12,
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
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
                  height: screenHeight * 0.2,
                  child: _buildBannerSection(),
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, // Full width
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showReport = !_showReport;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.02, // Responsive height
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      backgroundColor: AppColors.kPrimary,
                    ),
                    child: MyTextfield.textStyle_w600(
                      _showReport ? 'Hide Report' : 'Show Report',
                      MediaQuery.of(context).size.width * 0.045,
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_showReport) const ReportPage(),
                const SizedBox(height: 10),

                MyTextfield.textStyle_w800("My DashBoard", 18, Colors.black87),
                const SizedBox(height: 10),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(), // Prevents scroll conflict
                  shrinkWrap: true, // Makes GridView take only needed height
                  itemCount: dashboardItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 600 ? 5 : 3, // Tablets get 5 columns
                      crossAxisSpacing: screenWidth * 0.02,
                      mainAxisSpacing: screenWidth * 0.02,
                      childAspectRatio: screenWidth > 600 ? 1.0 : 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return _dashboardTile(item.title, item.desc, item.icon, item.onTap,screenWidth);
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

  Widget _dashboardTile(String title, String desc, String icon, VoidCallback onTap, double screenWidth) {
    return GestureDetector(
      onTap: onTap,
      child: _buildTaskCard(title: title, tasks: desc, icon: icon,screenWidth:screenWidth),
    );
  }

  Future<void> _UploadInvoice() async {
    AddPurchaseBottomSheet(context, _setSelectedImage, pdf: true, pick_Size: 5, ManualAdd: true);
  }

  Future<void> _setSelectedImage(List<File> files) async {
    print("🔍 Raw scannedDocuments = ${files.length}");
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

  Future<void> _newSaleEntry(String tittle,String content) async {
    CommonConfirmationDialog.show<int>(
      context: context,
      id: 0,
      title: tittle,
      content: content,
      negativeButton: 'Cancel',
      positiveButton: 'Yes, Start New',
      onConfirmed: (int) async {
        context.read<CartCubit>().clearCart(type: CartType.main);
        widget.onQuickScan();
      },
    );
  }
  Future<void> _returnProduct(String tittle,String content,CartTypeSelection cartTypeSelection,int flag) async {
    CommonConfirmationDialog.show<int>(
      context: context,
      id: flag,
      title: tittle,
      content: content,
      negativeButton: 'Cancel',
      positiveButton: 'Yes, Start New',
      onConfirmed: (int) async {
        context.read<CartCubit>().clearCart(type: CartType.main);
        switchToReturnproductCart(cartTypeSelection);
      },
    );
  }
  Future<void> switchToReturnproductCart(CartTypeSelection type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuikScanPage(cartTypeSelection: type)),
    );
  }
  Widget _buildBannerSection() {
    if (_bannerLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SpinKitThreeBounce(
            color: AppColors.kPrimary,
            size: 30.0,
          ),
        ),
      );
    }
    
    if (_bannerLoadError || bannerList.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 8),
              MyTextfield.textStyle_w400(
                _bannerLoadError ? 'Failed to load banners' : 'No banners available',
                14,
                Colors.grey.shade600,
              ),
              if (_bannerLoadError) ...[
                SizedBox(height: 8),
              ],
            ],
          ),
        ),
      );
    }
    
    return PageView.builder(
      controller: _pageController,
      itemCount: bannerList.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://pixidrugs.com/${bannerList[index]}',
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.kPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                        SizedBox(height: 8),
                        MyTextfield.textStyle_w400('Failed to load image', 12, Colors.grey.shade600),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String tasks,
    required String icon,required double screenWidth,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.kPrimary,
                  AppColors.secondaryColor,
                ],
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 0.5, color: AppColors.secondaryColor),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16,bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.08,
                      backgroundColor: AppColors.kWhiteColor,
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.010),
                        child: SvgPicture.asset(icon, height: screenWidth * 0.09),
                      ),
                    ),
                    const SizedBox(height: 5),
                    //MyTextfield.textStyle_w600(title, screenWidth * 0.043, AppColors.kPrimary),
                    //MyTextfield.textStyle_w300(tasks, screenWidth * 0.030, AppColors.kPrimary.withOpacity(0.6)),
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
        MyTextfield.textStyle_w600(title, screenWidth * 0.035, AppColors.kPrimary),
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
