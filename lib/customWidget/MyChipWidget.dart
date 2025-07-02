
import 'package:pixidrugs/constant/all.dart';

class MyChipWidget extends StatelessWidget {
  Color color;
  String text;
  Color textColor;
  VoidCallback onPressed;
  MyChipWidget(
      {super.key,
      required this.color,
      required this.text,
      required this.textColor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: textColor, width: 1.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 5),
              MyTextfield.textStyle_w800(text, 20, textColor)
            ],
          ),
        ),
      ),
    );
  }
}
