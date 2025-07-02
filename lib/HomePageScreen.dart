import 'package:flutter/material.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:pixidrugs/Cart/CartTab.dart';
import 'package:pixidrugs/HomeTab.dart';
import 'package:pixidrugs/Stock/ProductList.dart';
import 'package:pixidrugs/constant/all.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPos = 0;
  late CircularBottomNavigationController _navigationController;

  final List<TabItem> tabItems = [
    TabItem(
      Icons.home,
      "Home",
      AppColors.kWhiteColor,
      labelStyle: TextStyle(color:AppColors.kPrimary,fontWeight: FontWeight.bold),
    ),
    TabItem(
      Icons.add_shopping_cart,
      "Cart",
      AppColors.kWhiteColor,
      labelStyle: TextStyle(color:AppColors.kPrimary,fontWeight: FontWeight.bold),
    ),
    TabItem(
      Icons.receipt,
      "Product",
      AppColors.kWhiteColor,
      labelStyle: TextStyle(color:AppColors.kPrimary,fontWeight: FontWeight.bold),

    ),
    TabItem(
      Icons.person,
      "Profile",
      AppColors.kWhiteColor,
      labelStyle: TextStyle(color:AppColors.kPrimary,fontWeight: FontWeight.bold),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(selectedPos);
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  Widget getBody() {
    switch (selectedPos) {
      case 0:
        return HomeTab();
      case 1:
        return CartTab(barcodeScan: true, onPressedProduct: () {  },);
      case 2:
        return ProductListPage();
      case 3:
        return Center(child: Text("👤 Profile Screen", style: TextStyle(fontSize: 24)));
      default:
        return Center(child: Text("Unknown"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Page content
          Padding(
            padding: const EdgeInsets.only(bottom: 60), // Reserve space for nav bar
            child: getBody(),
          ),

          // Bottom Navigation fixed position
          Align(
            alignment: Alignment.bottomCenter,
            child: CircularBottomNavigation(
              tabItems,
              controller: _navigationController,
              barHeight: 60, // Set bar height to match padding
              barBackgroundColor: AppColors.kWhiteColor,
              selectedIconColor: AppColors.kPrimary,
              normalIconColor: AppColors.kgrey,
              circleStrokeWidth: 3,
              selectedCallback: (int? selected) {
                setState(() => selectedPos = selected ?? 0);
              },
            ),
          ),
        ],
      ),
    );
  }

}
