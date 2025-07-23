import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:PixiDrugs/Cart/CartTab.dart';
import 'package:PixiDrugs/Home/HomeTab.dart';
import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:PixiDrugs/Stock/ProductList.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/Profile/profileTab.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPos = 0;

  void switchToTab(int index) {
    setState(() {
      selectedPos = index;
    });
  }

  Widget getBody() {
    switch (selectedPos) {
      case 0:
        return HomeTab(onGoToCart: () => switchToTab(1));
      case 1:
        return CartTab(barcodeScan: true, onPressedProduct: () {});
      case 2:
        return ListScreen(type:'ledger');
      case 3:
        return ProductListPage(flag: 1);
      case 4:
        return ProfileScreen();
      default:
        return Center(child: Text("Unknown"));
    }
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
              AppImages.scan_cart,
              height: 24,
              color: selectedPos == 1 ?AppColors.kWhiteColor : AppColors.kPrimaryLight,
            ),
            title: 'Cart',
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
