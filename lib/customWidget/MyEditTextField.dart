import 'package:flutter/services.dart';
import 'package:PixiDrugs/constant/all.dart';

class MyEdittextfield extends StatefulWidget {

  final TextEditingController controller;
  String hintText;
  TextInputType keyboardType;
  int maxLines;
  bool readOnly;
  bool autofocus;
  bool obscureText;
  Function()? onTap;
  String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool mandatory;

  MyEdittextfield({
  Key? key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.obscureText=false,
    this.mandatory = true,
  }) : super(key: key);

  @override
  State<MyEdittextfield> createState() => _MyEdittextfieldState();
  }

  class _MyEdittextfieldState extends State<MyEdittextfield> {
  bool _isObscured = true;

  @override
  void initState() {
  super.initState();
  _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(12), // Rounded corners
              border: Border.all(
                color: AppColors.kPrimaryDark, // Border color
                width: 1, // Border width
              ),
            ),
      child: TextFormField(
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: MyTextfield.textStyle(14 ,Colors.grey.shade500,FontWeight.w300),
          border: InputBorder.none, // Remove default border
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: _isObscured ? Colors.grey : AppColors.kPrimaryDark,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          )
              : null,
        ),
        style: MyTextfield.textStyle(14,Colors.black,FontWeight.w600),
        inputFormatters: widget.keyboardType == TextInputType.number
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        validator: widget.mandatory
            ? widget.validator ?? (value) {
          if (value == null || value.isEmpty) return 'Please ${widget.hintText}';
          return null;
        }
            : widget.validator,
        readOnly: widget.readOnly, // Make the TextField read-only
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText ? _isObscured : false,
      ),
    );
  }
}
