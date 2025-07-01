import 'package:pixidrugs/constant/all.dart';

class AppColors {
  static const kPrimaryLight = Color(0xFFDCEBFF);
  static const kPrimary = Color(0xFF062A49);

  static const kWhiteColor = Color(0xFFFFFFFF);
  static const kgrey = Color(0xFFC2C3C3);
  static const kBlackColor800 = Color(0xFF404345);
  static const kBlackColor900 = Color(0xFF25282B);
  static const kRedColor = Color(0xfff11d1d);
  static const kRedLightColor = Color(0xffF7E4D9);
  static const kGreyColor700 = Color(0xFFC4C4C4);
  static const kGreyColor800 = Color(0xFFAAAAAA);

  static const myGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.kPrimaryLight,
        AppColors.kWhiteColor,
      ],
      stops: [0.0, 1.0],
      tileMode: TileMode.clamp);
}
