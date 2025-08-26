
import 'package:PixiDrugs/constant/all.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
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