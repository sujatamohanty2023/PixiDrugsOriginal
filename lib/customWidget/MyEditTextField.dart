import 'package:flutter/services.dart';
import 'package:pixidrugs/constant/all.dart';

class MyEdittextfield extends StatelessWidget {
  final TextEditingController controller;
  String hintText;
  TextInputType keyboardType;
  int maxLines;
  bool readOnly, login;
  Function()? onTap;
  String? Function(String?)? validator;
  final Function(String)? onChanged;
  MyEdittextfield({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.login = false,
    this.onTap,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: login
          ? null
          : BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(12), // Rounded corners
              border: Border.all(
                color: AppColors.kPrimaryDark, // Border color
                width: 1, // Border width
              ),
            ),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none, // Remove default border
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
        style: MyTextfield.textStyle(
            login ? 18 : 14,
            login ? AppColors.kPrimary : Colors.black45,
            login ? FontWeight.w800 : FontWeight.w600),
        inputFormatters: keyboardType == TextInputType.number
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        validator: validator ??
                (value) {
              if (value == null || value.isEmpty) return 'Please $hintText';
              return null;
            },
        readOnly: readOnly, // Make the TextField read-only
        onTap: onTap,
        onChanged: onChanged,
      ),
    );
  }
}
