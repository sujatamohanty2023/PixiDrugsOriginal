import '../../constant/all.dart';

class MyChipWithIconWidget extends StatelessWidget {
  Color color;
  IconData icon;
  String text;
  Color textColor;
  final VoidCallback? onPressed;

  MyChipWithIconWidget({
    Key? key,
    required this.color,
    required this.icon,
    required this.text,
    required this.textColor,
    this.onPressed, // onPressed is optional now
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size:  SizeConfig.screenWidth! * 0.035, color: textColor),
              const SizedBox(width: 5),
              MyTextfield.textStyle_w600(text,  SizeConfig.screenWidth! * 0.035, textColor)
            ],
          ),
        ),
      ),
    );
  }
}
