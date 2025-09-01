import 'package:PixiDrugs/constant/all.dart';

class AppColors {
  static const kPrimaryLight = Color(0xFFDCEBFF);
  static const kPrimaryDark = Color(0xFFC4DAF6);
  static const loginbg = Color(0xFF173C6E);
  static const kPrimary = Color(0xFF062A49);
  static const secondaryColor = Color(0xff1ca4ac);
  static const secondaryColorLight = Color(0xffdcf3f4);

  static const kWhiteColor = Color(0xFFFFFFFF);
  static const kgrey = Color(0xFFC2C3C3);
  static const kBlackColor800 = Color(0xFF404345);
  static const kBlackColor900 = Color(0xFF25282B);
  static const kRedColor = Color(0xfff11d1d);
  static const kRedLightColor = Color(0xffF7E4D9);
  static const kGreyColor700 = Color(0xFFC4C4C4);
  static const kGreyColor800 = Color(0xFFAAAAAA);
  static const error = Color(0xff980505);
  static const success = Color(0xff0c9f07);

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
