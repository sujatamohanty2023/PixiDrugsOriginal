import 'package:pixidrugs/constant/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({
    super.key,
    required this.title,
    required this.description,
    required this.skip,
    required this.image,
    required this.onTab,
    required this.index,});

    final String title;
  final String description;
  final bool skip;
  final String image;
  final VoidCallback onTab;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.kPrimaryLight,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 1.56,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.fitHeight
              )
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 2.16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(100)
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  children: [
                    const SizedBox(height: 62,),
                    Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16,),
                    Text(description, style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.grey), textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: skip
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Skip Now', style: TextStyle(color: AppColors.kPrimary),),
                  ),
                  GestureDetector(
                    onTap: onTab,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary,
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                    ),
                  )
                ],
              )
              :  SizedBox(
                height: 46,
                child: MaterialButton(
                  color: AppColors.kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () async {
                    final prefs =
                    await SharedPreferences.getInstance();
                    await prefs.setBool(
                        'onboarding_completed', true);
                    AppRoutes.navigateToHome(context);
                  },
                  child: const Text('Get Started', style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold)),
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}