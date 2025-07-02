
import 'package:pixidrugs/constant/all.dart';

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
  static TextStyle textStyle(double size, Color color, FontWeight fontWeight,
      {TextDecoration decoration = TextDecoration.none}) {
    return GoogleFonts.metrophobic(
      color: color,
      fontSize: size,
      fontWeight: fontWeight,
      decoration: decoration,
    );
  }

  static TextStyle slotBooktextStyle(
      double size,
      Color color,
      FontWeight fontWeight,
      TextDecoration? decoration,
      Color decorationColor) {
    return GoogleFonts.metrophobic(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
        decoration: decoration,
        decorationColor: decorationColor);
  }
}
