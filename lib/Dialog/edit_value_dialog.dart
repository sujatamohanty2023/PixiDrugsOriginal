import 'package:flutter/material.dart';
import 'package:PixiDrugs/constant/all.dart';

class EditValueDialog extends StatelessWidget {
  final String title;
  final String initialValue;
  final void Function(String)? onSave;
  final void Function(String)? addMore;
  final String type;

  const EditValueDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.onSave,
    this.addMore,
    this.type='',
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
              keyboardType: TextInputType.text,
              autofocus: true,
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
                  onPressed: () async {
                    if (onSave != null) {
                      onSave?.call(controller.text.trim());
                      Navigator.pop(context);
                    }else if(addMore !=null){
                      addMore?.call(controller.text.trim());
                      Navigator.pop(context);
                    }else if(type =='stockReturn'){
                      Navigator.pop(context);
                      await Future.delayed(Duration(milliseconds: 100));
                      Navigator.pushNamed(context, '/purchaseReturn',arguments: controller.text.trim());
                    }else if(type =='saleReturn'){
                      Navigator.pop(context);
                      await Future.delayed(Duration(milliseconds: 100));
                      Navigator.pushNamed(context, '/saleReturn',arguments: controller.text.trim());
                    }else if(type =='barcode'){
                      Navigator.pop(context);
                      await Future.delayed(Duration(milliseconds: 100));
                      Navigator.pop(context,controller.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: MyTextfield.textStyle_w600(
                    onSave!=null?'Save':'Search', AppUtils.size_14, Colors.white,
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
