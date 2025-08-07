import 'package:PixiDrugs/constant/all.dart';

class MyElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  Color backgroundColor,titleColor;
  bool custom_design;
  final bool isLoading;
  // Constructor to pass the button text and onPressed action
  MyElevatedButton(
      {required this.onPressed,
        required this.buttonText,
        this.backgroundColor = AppColors.kPrimary,
        this.titleColor= AppColors.kWhiteColor,
        this.custom_design = false,
        this.isLoading = false,});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? () {} : onPressed,
      style: custom_design
          ? AppStyles.elevatedButton_cut_style(
          color: backgroundColor)
          : AppStyles.elevatedButton_style(color: backgroundColor),
      child:  isLoading ?
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
          :MyTextfield.textStyle_w800(
          buttonText,
          custom_design ? 16 : 20,
          titleColor),
    );
  }
}
