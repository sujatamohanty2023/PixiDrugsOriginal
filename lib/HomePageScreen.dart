import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> bannerList = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("assets/dorthy.png"), // Replace with actual image
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Dorthy Miller",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("64 yrs • Port Angeles",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),
              Container(
                height: 200,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: bannerList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
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
              // Health Report
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Your vitals are normal and blood sugar level is in control.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildTaskCard(
                        color: const Color(0xFFD2F9F2),
                        progressColor: Colors.teal,
                        title: "New Invoice",
                        tasks: "Create a new invoice",
                        percent: 0.81,
                        icon: 'assets/svg/add_invoice.svg',
                        arrowColor: Colors.teal),
                    _buildTaskCard(
                        color: const Color(0xFFDCEBFF),
                        progressColor: Colors.blue,
                        title: "Invoice History",
                        tasks: "View all previous invoices",
                        percent: 0.60,
                        icon: 'assets/svg/invoice_list.svg',
                        arrowColor: Colors.blue),
                    _buildTaskCard(
                        color: const Color(0xFFFFE2E5),
                        progressColor: Colors.red,
                        title: "New Sale Entry",
                        tasks: "Record a new sale",
                        percent: 0.42,
                        icon: 'assets/svg/sale.svg',
                        arrowColor: Colors.red),
                    _buildTaskCard(
                        color: const Color(0xFFFFF1D7),
                        progressColor: Colors.orange,
                        title: "Sales Report",
                        tasks: "Track sales summary",
                        percent: 0.90,
                        icon: 'assets/svg/sale_list.svg',
                        arrowColor: Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                        Text("${(percent * 100).toInt()}%",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: progressColor)),
                      ],
                    ),
                    SizedBox(width: 40,),
                    SvgPicture.asset(icon, width: 55, height: 55,color: progressColor.withOpacity(0.4),),
                  ],
                ),
                const SizedBox(height: 16),
                Text(title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: progressColor)),
                const SizedBox(height: 4),
                Text(tasks, style: TextStyle(color: progressColor.withOpacity(0.6))),
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

