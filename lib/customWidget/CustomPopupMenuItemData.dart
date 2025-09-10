import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constant/color.dart';
import 'MyTextField.dart';

class CustomPopupMenuItemData {
  final String value;
  final String label;
  final String iconAsset;
  final Color textColor;

  CustomPopupMenuItemData({
    required this.value,
    required this.label,
    required this.iconAsset,
    this.textColor=AppColors.kPrimary,
  });
}

class CustomPopupMenu extends StatelessWidget {
  final List<CustomPopupMenuItemData> items;
  final void Function(String value) onSelected;
  final double iconSize;
  final Color backgroundColor;
  final IconData menuIcon;

  const CustomPopupMenu({
    Key? key,
    required this.items,
    required this.onSelected,
    this.iconSize = 24.0,
    this.backgroundColor = Colors.white,
    this.menuIcon = Icons.more_vert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(menuIcon, size: iconSize),
      elevation: 10,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<String>(
          value: item.value,
          height: 36,
          padding: EdgeInsets.zero,
          child: _buildMenuItem(item),
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem(CustomPopupMenuItemData item) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          SvgPicture.asset(item.iconAsset, height: 18,color: item.textColor),
          SizedBox(width: 8),
          MyTextfield.textStyle_w600(item.label, 13,item.textColor),
        ],
      ),
    );
  }
}
