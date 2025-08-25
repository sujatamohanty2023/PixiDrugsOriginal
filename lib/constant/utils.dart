import 'package:intl/intl.dart';

import 'package:PixiDrugs/constant/all.dart';

class AppUtils {
  // Common spacing
  static const double size_14 = 14;
  static const double size_16 = 16;
  static const double size_18 = 18;
  static const double size_25 = 25;

  static AppBar BaseAppBar(
      {required BuildContext context,
      required String title,
      bool leading = true,
      List<Widget>? actions,
      TabBar? bottom}) {
    return AppBar(
      backgroundColor: AppColors
          .kPrimary, // Set to transparent so we can add custom decoration
      elevation: 0,
      title: MyTextfield.textStyle_w600(title, SizeConfig.screenWidth! * 0.055, AppColors.kWhiteColor),
      leading: leading
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.kWhiteColor,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Navigate back to the previous screen
              },
            )
          : null,
      automaticallyImplyLeading: leading,
      actions: actions,
      bottom: bottom,
    );
  }

  static Theme CalenderTheme({required Widget? child}) {
    return Theme(
      data: ThemeData(
        primaryColor: AppColors.kPrimary, // Custom primary color
        hintColor: AppColors.kPrimary, // Custom accent color
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
        // Customizing the header and other button colors
        colorScheme: ColorScheme.light(
          primary: AppColors.kPrimary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      child: child!,
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    var isError = message.toLowerCase().contains('Error:') ||
        message.toLowerCase().contains('error')||
        message.toLowerCase().contains('failed') ||
        message.toLowerCase().contains('please') ||
        message.toLowerCase().contains('no product founds')||
        message.toLowerCase().contains('Multiple different invoice IDs found');

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16, // Below status bar
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isError ? AppColors.error : AppColors.success,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error : Icons.check_circle,
                  color:Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MyTextfield.textStyle_w600(
                    message,
                    AppUtils.size_16,
                    Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after 2 seconds
    Future.delayed(const Duration(seconds: 2)).then((_) => overlayEntry.remove());

  }

  String formatDateForServerInput(String inputDate) {
    // Define the input format matching your string
    DateFormat inputFormat = DateFormat('d MMM, yyyy');
    // Parse the string into a DateTime object
    DateTime dateTime = inputFormat.parse(inputDate);
    // Format it into the desired format
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  String formatDate(String inputDate) {
    // Define the input format matching your string
    DateFormat inputFormat = DateFormat('yyyy-MM-dd');
    // Parse the string into a DateTime object
    DateTime dateTime = inputFormat.parse(inputDate);
    // Format it into the desired format
    String formattedDate = DateFormat('d MMM, yyyy').format(dateTime);
    return formattedDate;
  }

  UnitType? detectUnitType(String? packing) {
    if (packing == null || packing.isEmpty) return null;

    final lowerPacking = packing.toLowerCase();

    // If packing contains GM, G, ML treat as Other (liquid/weight)
    if (lowerPacking.contains("gm") ||
        lowerPacking.contains("g") ||
        lowerPacking.contains("ml") ||
        lowerPacking.contains("kit")) {
      return UnitType.Other;
    }

    // ✅ Check for common tablet or capsule indicators
    if (lowerPacking.contains("unit") ||
        lowerPacking.contains("tablet") ||
        lowerPacking.contains("tab") ||
        lowerPacking.contains("capsule") ||
        lowerPacking.contains("cap") ||
        RegExp(r"'\s?s$").hasMatch(lowerPacking) ||  // Matches "10's", "30's"
        lowerPacking.contains("s)")) { // Optional fallback for variations like (10s)
      return UnitType.Tablet;
    }

    // If digits are present and no tablet keywords matched, assume strip
    if (RegExp(r'\d').hasMatch(lowerPacking)) {
      return UnitType.Strip;
    }

    return UnitType.Other;
  }

  int extractPackingQuantity(String? packing) {
    if (packing == null || packing.isEmpty) return 0;

    final numbers = RegExp(r'\d+').allMatches(packing).map((e) => int.tryParse(e.group(0) ?? '0') ?? 0).toList();

    if (numbers.length >= 2) {
      return numbers[0] * numbers[1]; // e.g., 10x1 => 10 * 1 = 10
    } else if (numbers.length == 1) {
      return numbers[0]; // e.g., "30's" => 30
    }
    return 0;
  }

}
