import 'package:image_cropper/image_cropper.dart';
import 'package:PixiDrugs/Dialog/show_image_picker.dart';
import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:PixiDrugs/constant/all.dart';
import '../Profile/WebviewScreen.dart';
import '../login/mobileLoginScreen.dart';

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
                      MaterialPageRoute(builder: (_) => Webviewscreen(tittle: 'Contact Us')),
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

  Future<void> _onNotificationTap() async {
    AppUtils.showSnackBar(context, "Notification tapped");
  }

  PreferredSizeWidget customAppBarHome(BuildContext context, VoidCallback onNotificationTap) {
    double width = MediaQuery.of(context).size.width;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: AppColors.kPrimary,
        padding: const EdgeInsets.only(top: 15.0, left: 12, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: width * 0.07,
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
                      name ?? 'Guest', width * 0.045, Colors.white),
                  Text(
                    email ?? '',
                    style: TextStyle(
                        color: AppColors.kWhiteColor.withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                        fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onNotificationTap,
              child: SvgPicture.asset(
                AppImages.notification,
                height: 24,
                color: AppColors.kWhiteColor,
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
      appBar: customAppBarHome(context, _onNotificationTap),
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
                SizedBox(
                  height: screenHeight * 0.25,
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
                MyTextfield.textStyle_w800("My DashBoard", 20, Colors.black87),
                const SizedBox(height: 10),

                // Responsive Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth < 360
                        ? 1
                        : constraints.maxWidth < 600
                        ? 2
                        : 3;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _dashboardTile("New Sale Entry", "Record a new sale", AppImages.sale, _newSaleEntry),
                        _dashboardTile("Sales Report", "Track sales summary", AppImages.sale_list, () {
                          AppRoutes.navigateTo(context, ListScreen(type: ListType.sale));
                        }),
                        _dashboardTile("Upload Invoice", "Create a new invoice", AppImages.add_invoice, _UploadInvoice),
                        _dashboardTile("Invoice History", "View all previous invoices", AppImages.invoice_list, () {
                          AppRoutes.navigateTo(context, ListScreen(type: ListType.invoice));
                        }),
                        _dashboardTile("Expired Product", "View expired items", AppImages.expired, () {
                          Navigator.pushNamed(context, '/stockList', arguments: 2);
                        }),
                        _dashboardTile("Expire Soon", "Track nearing expiry your product", AppImages.notification, () {
                          Navigator.pushNamed(context, '/stockList', arguments: 3);
                        }),
                        _dashboardTile("Stockist Return", "Return products back to stockist or suppliers", AppImages.purchase_return, () {
                          showDialog(
                            context: context,
                            builder: (_) => EditValueDialog(
                              title: 'Invoice No.',
                              initialValue: '',
                              type: 'stockReturn',
                            ),
                          );
                        }),
                        _dashboardTile("Customer Return", "Manage products returned by customers", AppImages.sale_return, () {
                          showDialog(
                            context: context,
                            builder: (_) => EditValueDialog(
                              title: 'Bill No.',
                              initialValue: '',
                              type: 'saleReturn',
                            ),
                          );
                        }),
                        _dashboardTile("Stock Return List", "View returns made to suppliers", AppImages.stockiest_return, () {
                          AppRoutes.navigateTo(context, ListScreen(type: ListType.stockReturn));
                        }),
                        _dashboardTile("Sale Return List", "View returns received from customers", AppImages.customer_return, () {
                          AppRoutes.navigateTo(context, ListScreen(type: ListType.saleReturn));
                        }),
                      ],
                    );
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
    showImageBottomSheet(context, _setSelectedImage, pdf: true, pick_Size: 5, ManualAdd: true);
  }

  Future<void> _setSelectedImage(List<File> file) async {
    List<String> croppedFileList = [];
    for (var item in file) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: item.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.kPrimary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.kPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      if (croppedFile != null) {
        croppedFileList.add(croppedFile.path);
      }
    }

    if (croppedFileList.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(paths: croppedFileList),
        ),
      );
    }
  }

  Future<void> _newSaleEntry() async {
    CommonConfirmationDialog.show<int>(
      context: context,
      id: 0,
      title: 'Start New Sale',
      content: 'This will clear the previous cart. Do you want to continue?',
      negativeButton: 'Cancel',
      positiveButton: 'Yes, Start New',
      onConfirmed: (int) async {
        context.read<CartCubit>().clearCart(type: CartType.barcode);
        widget.onGoToCart();
      },
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String tasks,
    required String icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: AppColors.kPrimaryLight),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
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
                const SizedBox(height: 15),
                MyTextfield.textStyle_w600(title, SizeConfig.screenWidth! * 0.045, AppColors.kPrimary),
                const SizedBox(height: 4),
                MyTextfield.textStyle_w300(tasks, SizeConfig.screenWidth! * 0.035, AppColors.kPrimary.withOpacity(0.6)),
              ],
            ),
          ),
          Positioned(
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
          ),
        ],
      ),
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
