
import 'package:PixiDrugs/constant/all.dart';

class MyTextfield {
  // Helper method for generating text with a specific font weight and style
  static Text textStyle_w800(String text, double size, Color color,
      {var maxLines = 2}) {
    return Text(
      text,
      maxLines: maxLines,
      style: textStyle(size, color, FontWeight.w800),
    );
  }

  static Text textStyle_w600(String text, double size, Color color,{var maxLines = false}) {
    return Text(
      text,
      maxLines: maxLines?1:null,
      style: textStyle(size, color, FontWeight.w600),
    );
  }
  static Text textStyle_w400(String text, double size, Color color,{var maxLines = false}) {
    return Text(
      text,
      maxLines: maxLines?1:null,
      style: textStyle(size, color, FontWeight.w400),
    );
  }

  static Text textStyle_w300(String text, double size, Color color) {
    return Text(
      text,
      style: textStyle(size, color, FontWeight.w300),
    );
  }

  static Text textStyle_w200(String text, double size, Color color,
      {var maxLines = 10, TextDecoration decoration = TextDecoration.none}) {
    return Text(
      text,
      maxLines: maxLines,
      style: textStyle(size, color, FontWeight.w200, decoration: decoration),
    );
  }

  // Central method to define text style
   static TextStyle textStyle(
      double size,
      Color color,
      FontWeight fontWeight, {
        TextDecoration decoration = TextDecoration.none,
        TextDecorationStyle? decorationStyle,
      }) {
    return GoogleFonts.signika(
      color: color,
      fontSize: size,
      fontWeight: fontWeight,
      decoration: decoration,
      decorationStyle: decoration != TextDecoration.none ? (decorationStyle ?? TextDecorationStyle.solid) : null,
    );
  }
}
