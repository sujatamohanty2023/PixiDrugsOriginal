
import 'package:pixidrugs/Dialog/show_image_picker.dart';
import 'package:pixidrugs/ListPageScreen/ListScreen.dart';
import 'package:pixidrugs/constant/all.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onGoToCart;

  const HomeTab({Key? key, required this.onGoToCart}) : super(key: key);
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<String> bannerList = [
    'assets/images/banner1.jpeg',
    'assets/images/banner2.jpeg',
    'assets/images/banner3.jpeg',
  ];

  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  String? name = 'Guest';
  String? email = '';
  String? image = '';

  @override
  void initState() {
    super.initState();
    _GetProfileCall();
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
  void _GetProfileCall() async {
    String? userId = await SessionManager.getUserId();
    if (userId != null) {
      context.read<ApiCubit>().GetUserData(userId: userId);
    } else {
      setState(() {

      });
    }
    context.read<ApiCubit>().stream.listen((state) {
      if (state is UserProfileLoaded) {
        setState(() {
          name = state.userModel.name;
          email = state.userModel.email;
          image = state.userModel.profilePicture;
        });
      } else if (state is UserProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${state.error}')),
        );
      }
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  void _onNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification tapped")),
    );
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
                            image: AssetImage(bannerList[index]),
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
                      onTap: _UploadInvoice,
                      child: _buildTaskCard(
                        color: const Color(0xFFD2F9F2),
                        progressColor: Colors.teal,
                        title: "Upload Invoice",
                        tasks: "Create a new invoice",
                        percent: 0.81,
                        icon: AppImages.add_invoice,
                        arrowColor: Colors.teal,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppRoutes.navigateTo(context, ListScreen(type:'invoice'));
                      },
                      child: _buildTaskCard(
                        color: const Color(0xFFDCEBFF),
                        progressColor: Colors.blue,
                        title: "Invoice History",
                        tasks: "View all previous invoices",
                        percent: 0.60,
                        icon: AppImages.invoice_list,
                        arrowColor: Colors.blue,
                      ),
                    ),
                    GestureDetector(
                      onTap: _newSaleEntry,
                      child: _buildTaskCard(
                        color: const Color(0xFFE8F5E9),
                        progressColor: Colors.green,
                        title: "New Sale Entry",
                        tasks: "Record a new sale",
                        percent: 0.42,
                        icon: AppImages.sale,
                        arrowColor: Colors.green,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppRoutes.navigateTo(context, ListScreen(type:'sale'));
                      },
                      child: _buildTaskCard(
                        color: const Color(0xFFEDE7F6),
                        progressColor: Colors.deepPurple,
                        title: "Sales Report",
                        tasks: "Track sales summary",
                        percent: 0.90,
                        icon: AppImages.sale_list,
                        arrowColor: Colors.deepPurple,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/stockList',arguments: 2);
                      },
                      child: _buildTaskCard(
                        color: const Color(0xFFFFE2E5),
                        progressColor: Colors.red,
                        title: "Expired Product",
                        tasks: "View expired items",
                        percent: 0.30,
                        icon: AppImages.expired,
                        arrowColor: Colors.red,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/stockList',arguments: 3);
                      },
                      child: _buildTaskCard(
                        color: const Color(0xFFFFF1D7),
                        progressColor: Colors.orange,
                        title: "Expire Soon",
                        tasks: "Track nearing expiry your product",
                        percent: 0.55,
                        icon: AppImages.notification,
                        arrowColor: Colors.orange,
                      ),
                    ),
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
    showImageBottomSheet(context, _setSelectedImage, pdf: false, pick_Size: 1);
  }
  void _setSelectedImage(List<File> file) {
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPurchaseBill(path: file[0].path),
        ),
      );
    });
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
          _scanBarcode();
        });
  }
  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        context.read<ApiCubit>().BarcodeScan(code: result.rawContent);
        widget.onGoToCart();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan barcode')),
      );
    }
  }
  Widget _buildTaskCard({
    required Color color,
    required Color progressColor,
    required String title,
    required String tasks,
    required double percent,
    required String icon,
    required Color arrowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0,right: 16,top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Circle
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 4,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                        MyTextfield.textStyle_w600("${(percent * 100).toInt()}%",16 ,progressColor),
                      ],
                    ),
                    SizedBox(width: 40,),
                    SvgPicture.asset(icon, width: 55, height: 55,color: progressColor.withOpacity(0.4),),
                  ],
                ),
                const SizedBox(height: 16),
                MyTextfield.textStyle_w600(title,20,progressColor),
                const SizedBox(height: 4),
                MyTextfield.textStyle_w300(tasks,14,progressColor.withOpacity(0.6)),
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
                color: arrowColor.withOpacity(0.7),
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

