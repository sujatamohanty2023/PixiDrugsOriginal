import 'package:intl/intl.dart';

import '../../constant/all.dart';
import '../login/mobileLoginScreen.dart';
import '../Api/ApiUtil/api_exception.dart';

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
        message.toLowerCase().contains('can\'t add more than stock available') ||
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
            padding: const EdgeInsets.all(8),
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
                  color:AppColors.kWhiteColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MyTextfield.textStyle_w600(
                    message,
                    AppUtils.size_14,
                    AppColors.kWhiteColor,
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
    Future.delayed(const Duration(seconds: 3)).then((_) => overlayEntry.remove());

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

    return null;
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
  String validateAndNormalizePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';

    // Remove all non-digit characters except '+' at start
    String cleaned = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');

    // Handle international format (+91...)
    if (cleaned.startsWith('+')) {
      if (cleaned.length == 13 && cleaned.startsWith('+91')) {
        return cleaned; // e.g., +919876543210
      } else if (cleaned.length == 14 && cleaned.startsWith('+9191')) {
        return '+91${cleaned.substring(4)}'; // Normalize +9191xxxx → +91xxxx
      }
    }

    // Handle local format: starts with 0
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // Must be exactly 10 digits (valid Indian mobile)
    if (cleaned.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return '+91$cleaned';
    }

    // Accept 11 digits starting with 91
    if (cleaned.length == 12 && cleaned.startsWith('91')) {
      return '+91${cleaned.substring(2)}';
    }

    print('⚠️ Invalid phone number: $phone → normalized to ""');
    return '';
  }

  /// New: Extract 2 numbers from a single string
  Map<String, String> extractTwoPhones(String raw) {
    final reg = RegExp(r'\+?\d{7,15}');
    final matches = reg.allMatches(raw).map((m) => m.group(0)!).toList();

    String phone1 = matches.isNotEmpty ? validateAndNormalizePhone(matches[0]) : '';
    String phone2 = matches.length > 1 ? validateAndNormalizePhone(matches[1]) : '';

    return {
      'phone1': phone1,
      'phone2': phone2,
    };
  }

  // Session handling method
  static void handleInactiveAccount(BuildContext context, {String? message}) {
    showSessionFailedDialog(context, message: message ?? "Your account is inactive. Please contact support.");
  }

  static void showSessionFailedDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.kRedColor,
                size: 24,
              ),
              SizedBox(width: 8),
              MyTextfield.textStyle_w600(
                "Session Failed",
                18,
                AppColors.kRedColor,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextfield.textStyle_w400(
                message ?? "Your session has expired or your account is inactive. Please login again.",
                16,
                AppColors.kBlackColor800,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kRedLightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.kRedLightColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.kRedColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: MyTextfield.textStyle_w400(
                        "You will be redirected to the login screen.",
                        14,
                        AppColors.kBlackColor800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await SessionManager.clearSession(); // Clear session
                // Navigate to login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MobileLoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: MyTextfield.textStyle_w600(
                "Login Again",
                16,
                Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  static bool checkForInactiveAccount(dynamic response) {
    if (response is Map<String, dynamic>) {
      final statusCode = response['statusCode'] ?? response['status_code'];
      final code = response['code']?.toString().toLowerCase() ?? '';
      final status = response['status']?.toString().toLowerCase() ?? '';
      final message = (response['message'] ?? response['error'] ?? '').toString().toLowerCase();

      // Check for numeric statusCode 201 or string '201'
      bool isStatusCode201 = statusCode == 201 || statusCode == '201';

      // Check for known inactive codes or statuses
      bool isInactiveCode = code.contains('inactive') || code.contains('account_inactive');
      bool isInactiveStatus = status == 'inactive';

      // Check for keywords in message
      bool messageIndicatesInactive = message.contains('inactive') ||
          message.contains('deactive') ||
          message.contains('disabled') ||
          message.contains('suspended');

      // Return true if any condition is met
      return isStatusCode201 || isInactiveCode || isInactiveStatus || messageIndicatesInactive;
    }
    return false;
  }


  // Global error handler for ApiException
  static void handleApiError(BuildContext context, dynamic error) {
    if (error is ApiException && error.isInactiveAccount) {
      // Handle inactive account error globally
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleInactiveAccount(context, message: error.message);
      });
    } else {
      // Handle other API errors
      final errorMessage = error is ApiException ? error.message : error.toString();
      showSnackBar(context, errorMessage);
    }
  }


}
