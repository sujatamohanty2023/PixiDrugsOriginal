import '../../constant/all.dart';

class Mychoicechip extends StatelessWidget {
  String label;
  bool selected;
  VoidCallback onSelected;
  Mychoicechip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: MyTextfield.textStyle_w600(
          label, 16, selected ? AppColors.kPrimary : Colors.black),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.kPrimaryLight,
      backgroundColor: AppColors.kWhiteColor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // Adjusted padding
      labelPadding:
          EdgeInsets.symmetric(horizontal: 8), // Added for better spacing
    );
  }
}
