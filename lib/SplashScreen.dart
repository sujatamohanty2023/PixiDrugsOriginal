
import 'package:flutter/services.dart';

import '../Api/app_initialization_service.dart';
import '../../constant/all.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.kWhiteColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulates splash delay
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('onBoardComplete') ?? false;
    final userId = await SessionManager.getParentingId() ??'';

    if (!showOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    } else if (userId.isNotEmpty) {
      // Load user profile once when app starts
      await AppInitializationService.initializeUserProfile(context);
      AppRoutes.navigateToHome(context);
    }else{
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.initSize(context);
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.Splash,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}