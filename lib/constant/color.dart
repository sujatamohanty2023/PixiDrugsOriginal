import 'package:pixidrugs/constant/all.dart';

class AppColors {
  static const kPrimaryLight = Color(0xFFAAD3F6);
  static const kPrimary = Color(0xFF062A49);

  static const kWhiteColor = Color(0xFFFFFFFF);



  static const myGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.kPrimary,
        AppColors.kWhiteColor,
      ],
      stops: [0.0, 1.0],
      tileMode: TileMode.clamp);
}
