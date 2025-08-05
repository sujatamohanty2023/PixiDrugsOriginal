import 'package:PixiDrugs/constant/all.dart';

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
      color: AppColors.kPrimaryDark,
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
                gradient: AppColors.myGradient,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(100)
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: Column(
                  children: [
                    const SizedBox(height: 62,),
                    MyTextfield.textStyle_w800(title, 28, AppColors.kPrimary),
                    const SizedBox(height: 16,),
                    MyTextfield.textStyle_w300(description, 20, Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 10,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: skip
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){},
                    child:
                  MyTextfield.textStyle_w300('Skip Now', 16,  AppColors.kPrimary),
                  ),
                  GestureDetector(
                    onTap: onTab,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary,
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.kPrimary,
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: const Icon(Icons.arrow_forward, color: AppColors.kWhiteColor, size: 30)),
                    ),
                  )
                ],
              )
              : SizedBox(
                  height: 48,
                  width: double.infinity,
                  child:MyElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onBoardComplete', true);
                      Navigator.pushNamed(context, '/login');
                    },
                    custom_design: false,
                    buttonText: AppString.get_started,
                  )
              )
            ),
          )
        ],
      ),
    );
  }
}