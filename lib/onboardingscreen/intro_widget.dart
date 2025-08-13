import 'package:PixiDrugs/constant/all.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({
    super.key,
    required this.title,
    required this.description,
    required this.skip,
    required this.image,
    required this.onTab,
    required this.index,
  });

  final String title;
  final String description;
  final bool skip;
  final String image;
  final VoidCallback onTab;
  final int index;

  @override
  Widget build(BuildContext context) {
    final screenHeight =  SizeConfig.screenHeight!;
    final screenWidth =  SizeConfig.screenWidth!;

    return SafeArea(
      child: ColoredBox(
        color: AppColors.kPrimaryDark,
        child: Stack(
          children: [
            /// Top Image
            Container(
              height: screenHeight * 0.52,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover, // Better for varying aspect ratios
                ),
              ),
            ),

            /// Gradient Container with Text
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.48,
                decoration: BoxDecoration(
                  gradient: AppColors.myGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(100),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.06),
                      MyTextfield.textStyle_w800(
                        title,
                        screenWidth * 0.07, // Responsive font size
                        AppColors.kPrimary,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      MyTextfield.textStyle_w300(
                        description,
                        screenWidth * 0.045,
                        Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Bottom Buttons: Skip / Arrow / Get Started
            Positioned(
              bottom: 20,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                child: skip
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Optional: Add skip logic here
                      },
                      child: MyTextfield.textStyle_w300(
                        'Skip Now',
                        screenWidth * 0.04,
                        AppColors.kPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: onTab,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: AppColors.kWhiteColor,
                            size: screenWidth * 0.07,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : SizedBox(
                  height: screenHeight * 0.065,
                  width: double.infinity,
                  child: MyElevatedButton(
                    onPressed: () async {
                      final prefs =
                      await SharedPreferences.getInstance();
                      await prefs.setBool('onBoardComplete', true);
                      Navigator.pushNamed(context, '/login');
                    },
                    custom_design: false,
                    buttonText: AppString.get_started,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
