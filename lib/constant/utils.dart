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
    var errorField=message.toLowerCase().contains('error')||message.toLowerCase().contains('failed') ||
    message.toLowerCase().contains('please')|| message.toLowerCase().contains('no product founds');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyTextfield.textStyle_w600(message, AppUtils.size_16,AppColors.kWhiteColor),
        backgroundColor: errorField? AppColors.error:AppColors.success, // Background color
        behavior: SnackBarBehavior.floating, // Floating style
       /* margin: EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).size.height - 120, // Push to top
        ),*/
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
}
