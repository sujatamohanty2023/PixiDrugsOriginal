import 'package:PixiDrugs/constant/all.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 5),
            MyTextfield.textStyle_w600(text, AppUtils.size_16, textColor)
          ],
        ),
      ),
    );
  }
}
