
import '../../constant/all.dart';

class GradientInitialsBox extends StatelessWidget {
  final double size;
  final String name;

  const GradientInitialsBox({
    Key? key,
    required this.size,
    required this.name,
  }) : super(key: key);

  String getInitials(String name) {
    if (name.trim().isEmpty) return "";

    List<String> parts = name.trim().split(RegExp(r"\s+")).where((s) => s.isNotEmpty).toList();

    if (parts.length >= 2) {
      return "${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}";
    } else if (parts.length == 1 && parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    } else {
      return parts[0][0].toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: AppColors.secondaryColor,
          width: 2,
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.kPrimary,
            AppColors.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: MyTextfield.textStyle_w600(
        getInitials(name),
        size * 0.37, // same ratio as 0.055 / 0.15
        Colors.white,
      ),
    );
  }
}
