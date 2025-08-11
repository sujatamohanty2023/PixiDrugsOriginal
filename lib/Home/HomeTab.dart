
import 'package:image_cropper/image_cropper.dart';
import 'package:PixiDrugs/Dialog/show_image_picker.dart';
import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../BarcodeScan/barcode_screen_page.dart';
import '../Profile/WebviewScreen.dart';
import '../login/mobileLoginScreen.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onGoToCart;
  HomeTab({Key? key, required this.onGoToCart}) : super(key: key);
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
    // await FCMService.clearFCMToken();
    setState(() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MobileLoginScreen()),
            (route) => false,
      );
    });
  }
  Future<void> showLoginFailedDialog(BuildContext context) async {

    await showDialog(
      context: context,
      barrierDismissible: false, // This disables tap outside
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // This disables back button
          child: AlertDialog(
            title: MyTextfield.textStyle_w600("Session Failed", 25, AppColors.kPrimary),
            content: MyTextfield.textStyle_w300(
              "Please contact our support team for assistance. Or try logging in again.",
              16,
              AppColors.kBlackColor800,
            ),
            actions: [
              TextButton(
                onPressed: () => _logoutFun(),
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
                      MaterialPageRoute(
                        builder: (_) => Webviewscreen(tittle: 'Contact Us'),
                      ),
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
    String? userId = await SessionManager.getUserId();
    if (userId != null) {
      context.read<ApiCubit>().GetUserData(userId: userId);
    }

    await _profileSubscription?.cancel();

    _profileSubscription = context.read<ApiCubit>().stream.listen((state) {
      if (state is UserProfileLoaded) {
        setState(() {
          name=state.userModel.user.name;
          email=state.userModel.user.email;
          image=state.userModel.user.profilePicture;
        });
        if(state.userModel.user.status !='active'){
          showLoginFailedDialog(context);
        }
      } else if (state is UserProfileError) {
       AppUtils.showSnackBar(context,'Failed: ${state.error}');
      }
    });
  }
  void _GetBanner() async {
    context.read<ApiCubit>().fetchBanner();
    context.read<ApiCubit>().stream.listen((state) {
      if (state is BannerLoaded) {
        setState(() {
          bannerList.clear();
          for (int i = 0; i < state.banner.length; i++) {
            bannerList.add(state.banner[i].photo??'');
          }
        });
      } else if (state is BannerError) {
       AppUtils.showSnackBar(context,'Failed: ${state.error}');
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
    AppUtils.showSnackBar(context,"Notification tapped");
  }
  PreferredSizeWidget customAppBarHome(BuildContext context, VoidCallback onNotificationTap) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: AppColors.kPrimary,
        child: Container(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 12, right: 48), // right padding adjusted
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.kWhiteColor,
                      backgroundImage: image!.isNotEmpty
                          ? image!.contains('https://')
                          ? NetworkImage(image!)
                          : image!.contains('NO')
                          ? AssetImage(AppImages.AppIcon)
                          : NetworkImage('${AppString.baseUrl}${image!}')
                          : AssetImage(AppImages.AppIcon),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        MyTextfield.textStyle_w600('$name', SizeConfig.screenWidth! * 0.055, Colors.white),
                        MyTextfield.textStyle_w300('$email', 16, AppColors.kWhiteColor.withOpacity(0.5)),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: onNotificationTap,
                    child: SvgPicture.asset(
                      AppImages.notification,
                      height: 24,
                      color: AppColors.kWhiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.kPrimary,
      appBar: customAppBarHome(context, _onNotificationTap),
      body:Container(
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: bannerList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                MyTextfield.textStyle_w800(
                    "My DashBoard",20, Colors.black87),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    GestureDetector(
                      onTap: _newSaleEntry,
                      child: _buildTaskCard(
                        title: "New Sale Entry",
                        tasks: "Record a new sale",
                        icon: AppImages.sale,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppRoutes.navigateTo(context, ListScreen(type:ListType.sale));
                      },
                      child: _buildTaskCard(
                        title: "Sales Report",
                        tasks: "Track sales summary",
                        icon: AppImages.sale_list,
                      ),
                    ),
                    GestureDetector(
                      onTap: _UploadInvoice,
                      child: _buildTaskCard(
                        title: "Upload Invoice",
                        tasks: "Create a new invoice",
                        icon: AppImages.add_invoice,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppRoutes.navigateTo(context, ListScreen(type:ListType.invoice));
                      },
                      child: _buildTaskCard(
                        title: "Invoice History",
                        tasks: "View all previous invoices",
                        icon: AppImages.invoice_list,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/stockList',arguments: 2);
                      },
                      child: _buildTaskCard(
                        title: "Expired Product",
                        tasks: "View expired items",
                        icon: AppImages.expired,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/stockList',arguments: 3);
                      },
                      child: _buildTaskCard(
                        title: "Expire Soon",
                        tasks: "Track nearing expiry your product",
                        icon: AppImages.notification,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditValueDialog(
                              title: 'Invoice No.',
                              initialValue: '',
                              type:'stockReturn'
                          ),
                        );
                      },
                      child: _buildTaskCard(
                        title: "Stockist Return",
                        tasks: "Return products back to stockist or suppliers",
                        icon: AppImages.purchase_return,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditValueDialog(
                              title: 'Bill No.',
                              initialValue: '',
                              type:'saleReturn'
                          ),
                        );
                      },
                      child: _buildTaskCard(
                        title: "Customer Return",
                        tasks: "Manage products returned by customers",
                        icon: AppImages.sale_return,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppRoutes.navigateTo(context, ListScreen(type:ListType.stockReturn));
                      },
                      child: _buildTaskCard(
                        title: "Stock Return List",
                        tasks: "View returns made to suppliers",
                        icon: AppImages.stockiest_return,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppRoutes.navigateTo(context, ListScreen(type:ListType.saleReturn));
                      },
                      child: _buildTaskCard(
                        title: "Sale Return List",
                        tasks: "View returns received from customers",
                        icon: AppImages.customer_return,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20), // bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _UploadInvoice() async {
    showImageBottomSheet(context, _setSelectedImage, pdf: false, pick_Size: 1,ManualAdd: true);
  }
  Future<void> _setSelectedImage(List<File> file) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file[0].path,
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(path: croppedFile.path),
        ),
      );
    }
  }

  Future<void> _newSaleEntry() async {
    CommonConfirmationDialog.show<int>(
        context: context,
        id: 0,
        // Pass whether it's a medical record or leave record
        title: 'Start New Sale',
        content: 'This will clear the previous cart. Do you want to continue?',
        negativeButton:'Cancel',
        positiveButton:'Yes, Start New',
        onConfirmed: (int) async{
          context.read<CartCubit>().clearCart(type: CartType.barcode);
          //_scanBarcode();
          widget.onGoToCart();
        });
  }
  Future<void> _scanBarcode() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BarcodeScannerPage()));
      if (result.isNotEmpty) {
        final userId = await SessionManager.getUserId() ??'';
        context.read<ApiCubit>().BarcodeScan(code: result,storeId: userId);
        widget.onGoToCart();
      }

    } catch (e) {
      AppUtils.showSnackBar(context,'Failed to scan barcode');
    }
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
        border: Border.all(width: 1,color: AppColors.kPrimaryLight),
        boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
      ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0,right: 16,top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.kPrimaryDark,
                  child:
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(icon, height: 55, width: 55,color: AppColors.kPrimary,),
                  ),
                ),
                const SizedBox(height: 15),
                MyTextfield.textStyle_w600(title,20,AppColors.kPrimary),
                const SizedBox(height: 4),
                MyTextfield.textStyle_w300(tasks,14,AppColors.kPrimary.withOpacity(0.6)),
              ],
            ),
          ),

          // Arrow button bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: ClipPath(
              clipper: ArrowCornerClipper(),
              child: Container(
                width: 55,
                height: 35,
                //color: arrowColor.withOpacity(0.7),
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
    path.quadraticBezierTo(0, 0, curveRadius, 0); // Top-left rounded corner
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(
        size.width, size.height, size.width * 0.5, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
