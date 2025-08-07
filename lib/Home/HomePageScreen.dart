import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:PixiDrugs/Cart/CartTab.dart';
import 'package:PixiDrugs/Home/HomeTab.dart';
import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:PixiDrugs/Stock/ProductList.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/Profile/profileTab.dart';

import '../Profile/WebviewScreen.dart';
import '../login/mobileLoginScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPos = 0;
  UserProfileResponse? userModel;
  StreamSubscription? _profileSubscription;

  void switchToTab(int index) {
    setState(() {
      selectedPos = index;
    });
  }

  Widget getBody() {
    switch (selectedPos) {
      case 0:
        if (userModel == null) {
          return Center(child: CircularProgressIndicator(color: AppColors.kPrimary,));
        }
        return HomeTab(onGoToCart: () => switchToTab(2),userModel:userModel);
      case 1:
        return ListScreen(type:ListType.ledger);
      case 2:
      return CartTab(barcodeScan: true, onPressedProduct: () {});
      case 3:
        return ProductListPage(flag: 1);
      case 4:
        return ProfileScreen();
      default:
        return Center(child: Text("Unknown"));
    }
  }
  @override
  void initState() {
    super.initState();
    _GetProfileCall();
  }
  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
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
         userModel = state.userModel;
        });
        if(state.userModel.user.status !='active'){
          showLoginFailedDialog(context);
        }
      } else if (state is UserProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${state.error}')),
        );
      }
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
    bool _navigatedToContact = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: MyTextfield.textStyle_w600("Session Failed", 25, AppColors.kPrimary),
          content: MyTextfield.textStyle_w300("Please contact our support team for assistance.Or Try login again", 16, AppColors.kBlackColor800),
          actions: [
            TextButton(
              onPressed: () =>_logoutFun,
              child: MyTextfield.textStyle_w800('Login Again', 18, AppColors.kRedColor),
            ),
            Container(
              decoration: BoxDecoration(
                color:AppColors.kPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.kPrimaryDark, width: 1),
              ),
              child: TextButton(
                onPressed: (){
                  if (_navigatedToContact) return;
                  _navigatedToContact = true;
                  Navigator.of(context).pop();
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
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimaryLight,
      body: getBody(),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: AppColors.kPrimary,
        activeColor: AppColors.kWhiteColor,
        color: AppColors.kPrimaryLight,
        initialActiveIndex: selectedPos,
        onTap: (int index) {
          setState(() {
            selectedPos = index;
          });
        },
        items: [
          TabItem(
            icon: SvgPicture.asset(
              AppImages.home,
              height: 24,
              color: selectedPos == 0 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Home',
          ),
          TabItem(
            icon: SvgPicture.asset(
              AppImages.ledger,
              height: 24,
              color: selectedPos == 2 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Ledger',
          ),
          TabItem(
            icon: SvgPicture.asset(
              AppImages.scan_cart,
              height: 24,
              color: selectedPos == 1 ?AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Sell',
          ),
          TabItem(
            icon: SvgPicture.asset(
              AppImages.stock,
              height: 24,
              color: selectedPos == 2 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Stock',
          ),
          TabItem(
            icon: SvgPicture.asset(
              AppImages.profile,
              height: 24,
              color: selectedPos == 3 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Profile',
          ),
        ],
      ),
    );
  }
}
