import 'package:pixidrugs/constant/all.dart';

class MyElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  Color backgroundColor,titleColor;
  bool custom_design;
  // Constructor to pass the button text and onPressed action
  MyElevatedButton(
      {required this.onPressed,
        required this.buttonText,
        this.backgroundColor = AppColors.kPrimary,
        this.titleColor= AppColors.kWhiteColor,
        this.custom_design = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: custom_design
          ? AppStyles.elevatedButton_cut_style(
          color: backgroundColor)
          : AppStyles.elevatedButton_style(color: backgroundColor),
      child: MyTextfield.textStyle_w800(
          buttonText,
          custom_design ? 18 : 20,
          titleColor),
    );
  }
}
