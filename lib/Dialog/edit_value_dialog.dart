import 'package:flutter/material.dart';
import 'package:pixidrugs/constant/all.dart';

class EditValueDialog extends StatelessWidget {
  final String title;
  final String initialValue;
  final void Function(String) onSave;

  const EditValueDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextfield.textStyle_w600("Enter $title", AppUtils.size_16, Colors.black),
            const SizedBox(height: 8),
            MyEdittextfield(
              controller: controller,
              hintText: "Enter $title",
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: MyTextfield.textStyle_w600(
                    "Cancel", AppUtils.size_14, AppColors.kPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    onSave(controller.text.trim());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: MyTextfield.textStyle_w600(
                    "Save", AppUtils.size_14, Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
