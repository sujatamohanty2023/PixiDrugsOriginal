import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/services.dart';
import '../Cart/CartTab.dart';
import '../Home/HomeTab.dart';

import '../Stock/ProductList.dart';
import '../../constant/all.dart';
import '../Profile/profileTab.dart';

import '../ListScreenNew/LedgerListScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPos = 0;

  Future<void> switchToCart(int index) async {
    setState(() {
      selectedPos = index;
    });
  }
  Future<void> switchToScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuikScanPage()),
    );

    if (result != null && result is Map && result["goToCart"] == true) {
      switchToCart(2); // Jump to Cart tab
    }
  }
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.kPrimary,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }
  Widget getBody() {
    switch (selectedPos) {
      case 0:
        return HomeTab(onGoToCart: () => switchToCart(2),onQuickScan: () => switchToScan());
      case 1:
        return LedgerListScreen();
      case 2:
        return CartTab();
      case 3:
        return ProductListPage(flag: 1);
      case 4:
        return ProfileScreen();
      default:
        return HomeTab(onGoToCart: () => switchToCart(2),onQuickScan: () => switchToScan(),);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColors.kPrimaryLight,
      body: getBody(),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle, // or TabStyle.reactCircle
        backgroundColor: AppColors.kPrimary,
        activeColor: AppColors.kWhiteColor,
        color: AppColors.kPrimaryLight,
        initialActiveIndex: selectedPos,
        onTap: (int index) async {
          if (index == 2) {
            /*final cartCubit = context.read<CartCubit>();
            final cartState = cartCubit.state;

            final isCartEmpty = cartState.cartItems.isEmpty;

            if (isCartEmpty) {
              cartCubit.clearCart(type: CartType.main);
              switchToCart(2);
              return;
            } else {
              setState(() {
                selectedPos = index;
              });
            }*/
            switchToScan();
            return;
          } else {
            setState(() {
              selectedPos = index;
            });
          }
        },
        items: [
          TabItem(
            icon: SvgPicture.asset(
              AppImages.home,
              height: SizeConfig.blockHeight * 3,
              color: selectedPos == 0 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Home',
          ),
          TabItem(
            icon: SvgPicture.asset(
              AppImages.ledger,
              height: SizeConfig.blockHeight * 3,
              color: selectedPos == 1 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Ledger',
          ),
          TabItem(
            icon: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
               color: AppColors.kWhiteColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppImages.scan_cart,
                height: SizeConfig.blockHeight * 4, // Bigger size
                color: AppColors.kPrimary,
              ),
            ),
            title: 'Scan',
          ),
          TabItem(
            icon: SvgPicture.asset(
              AppImages.stock,
              height: SizeConfig.blockHeight * 3,
              color: selectedPos == 3 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Stock',
          ),
          TabItem(
            icon: SvgPicture.asset(
              AppImages.profile,
              height: SizeConfig.blockHeight * 3,
              color: selectedPos == 4 ? AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Profile',
          ),
        ],
      ),

    )
    );
  }
}
