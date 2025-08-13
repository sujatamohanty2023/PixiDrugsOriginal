import 'package:flutter/gestures.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/onboardingscreen/intro_widget.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {


  final PageController  _pageController = PageController();

  int _activePage = 0;

  void onNextPage(){
    if(_activePage  < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut,);
    }
  }

  final List<Map<String, dynamic>> _pages = [
  {
    'title': 'Welcome to PixiDrugs',
    'image': AppImages.Intro1,
    'description': "Easily manage your entire medical stock with PixiDrugs. From purchase to sales, our powerful tools simplify every step of inventory tracking, ensuring accuracy and convenience for pharmacies and clinics.",
    'skip': true
  },
  {
    'title': "Scan Invoices Effortlessly",
    'image': AppImages.Intro2,
  'description': "Use your phone's camera to scan medicine invoices and automatically extract data like names, quantities, and prices. Our AI-powered OCR ensures fast, reliable, and accurate recordkeeping without manual entry.",
  'skip': true
  },
  {
    'title': 'Expiry & Stock Alerts',
    'image': AppImages.Intro3,
    'description': "Stay ahead of medicine expiries and low stock with instant alerts. PixiDrugs helps you maintain compliance, reduce wastage, and ensure critical medicines are always available when needed.",
    'skip': false
  },
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            scrollBehavior: AppScrollBehavior(),
            onPageChanged: (int page) {
              setState(() {
                _activePage = page;
              });
            },
            itemBuilder: (BuildContext context, int index){
              return IntroWidget(
                index: index,
                title: _pages[index]['title'],
                description: _pages[index]['description'],
                image: _pages[index]['image'],
                skip: _pages[index]['skip'],
                onTab: onNextPage,
              );
            }
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 1.85,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildIndicator()
                )
              ],
            ),
          )

        ],
      ),
    );
  }

  List<Widget> _buildIndicator() {
    final indicators =  <Widget>[];

    for(var i = 0; i < _pages.length; i++) {

      if(_activePage == i) {
        indicators.add(_indicatorsTrue());
      }else{
        indicators.add(_indicatorsFalse());
      }
    }
    return  indicators;
  }

  Widget _indicatorsTrue() {
    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: 6,
      width: 42,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color:AppColors.kPrimary,
      ),
    );
  }

  Widget _indicatorsFalse() {
    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: 8,
      width: 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey.shade500,
      ),
    );
  }
}