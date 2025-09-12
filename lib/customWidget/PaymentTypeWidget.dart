import 'package:PixiDrugs/constant/color.dart';
import 'package:PixiDrugs/customWidget/size_confige.dart';
import 'package:flutter/material.dart';

import '../constant/utils.dart';
import 'MyTextField.dart';

class PaymentPopupMenu extends StatelessWidget {
  final String selectedValue;
  final void Function(String) onChanged;
  final List<PaymentPopupMenuItemData> items;
  final String label;

  const PaymentPopupMenu({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.firstWhere(
          (item) => item.value == selectedValue,
      orElse: () => items.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w400(
              label,
              AppUtils.size_16,
              Colors.black54,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kPrimaryDark, width: 1), // Replace with your color
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: PopupMenuButton<String>(
            onSelected: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            elevation: 8,
            itemBuilder: (context) {
              return items.map((item) {
                return PopupMenuItem<String>(
                  value: item.value,
                  height: 36,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 20, color: AppColors.kPrimary), // Change color as needed
                        const SizedBox(width: 10),
                        MyTextfield.textStyle_w400(
                          item.value,
                          SizeConfig.screenWidth! *0.035,
                          AppColors.kPrimary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(selectedItem.icon, size: 20, color: AppColors.kPrimary),
                    const SizedBox(width: 10),
                    MyTextfield.textStyle_w400(
                      selectedValue,
                      SizeConfig.screenWidth! *0.035,
                      AppColors.kPrimary,
                    ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentPopupMenuItemData {
  final String value;
  final IconData icon;

  PaymentPopupMenuItemData({required this.value, required this.icon});
}