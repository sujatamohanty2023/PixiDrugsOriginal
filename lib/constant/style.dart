import 'package:pixidrugs/constant/all.dart';

class AppStyles {

  static ButtonStyle elevatedButton_cut_style(
      {var color = AppColors.kPrimary}) {
    return ElevatedButton.styleFrom(
        backgroundColor: color,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
        elevation: 5);
  }
  static ButtonStyle elevatedButton_style({var color = AppColors.kPrimary}) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, 50),
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  static BoxDecoration Custom_Appbar_bg() {
    return BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.kPrimary, AppColors.kPrimary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border:
        Border.all(width: 0.2, color: AppColors.kPrimary.withOpacity(0.3)));
  }
  static BoxDecoration bg_radius_50_decoration() {
    return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.kPrimaryLight,
            AppColors.kWhiteColor,
          ],
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp),
      borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(50),
          topRight: const Radius.circular(50)),
    );
  }
}
