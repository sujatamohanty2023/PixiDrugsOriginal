import '../../constant/all.dart';

class SizeConfig {
  static double? screenWidth;
  static double? screenHeight;
  static late double blockWidth;
  static late double blockHeight;

  static initSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    blockWidth = screenWidth! / 100;
    blockHeight = screenHeight! / 100;
  }
}

double getRelativeHeight(double percentage) {
  return percentage * SizeConfig.screenHeight!;
}

double getRelativeWidth(double percentage) {
  return percentage * SizeConfig.screenWidth!;
}
