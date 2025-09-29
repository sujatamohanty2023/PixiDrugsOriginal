import '../../constant/all.dart';
import '../Profile/contact_us.dart';
import '../login/mobileLoginScreen.dart';

/// Centralized error handling system for the app
class ErrorHandler {
  static void showErrorRetry(BuildContext context, String error,
      Future<void> Function() onRetry) {

    if (error.contains('Account has been deactivated')) {
      showAuthenticationErrorDialog(context);
    } else {
      showGenericErrorDialog(context, error, onRetry);
    }
  }

  static void showAuthenticationErrorDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: MyTextfield.textStyle_w600(
                "Session Failed", 25, AppColors.kPrimary),
            content: MyTextfield.textStyle_w300(
              "Please contact our support team for assistance. Or try logging in again.",
              16,
              AppColors.kBlackColor800,
            ),
            actions: [
              TextButton(
                onPressed: () => _logoutFun(context),
                child: MyTextfield.textStyle_w800(
                    'Login Again', 18, AppColors.kRedColor),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.kPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.kPrimaryDark, width: 1),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) =>
                          ContactUsPage() /*Webviewscreen(tittle: 'Contact Us')*/),
                    );
                  },
                  child: MyTextfield.textStyle_w800(
                      'Contact', 18, AppColors.kWhiteColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _logoutFun(BuildContext context) async {
    await SessionManager.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MobileLoginScreen()),
          (route) => false,
    );
  }

  /// Show generic error snack bar
  static void showGenericErrorDialog(BuildContext context, String error,
      Future<void> Function() onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                MyTextfield.textStyle_w800('WARNING', 25, Colors.red),
              ],
            ),
            content:  MyTextfield.textStyle_w400(error,18,AppColors.kPrimary),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius
                        .zero, // rectangle shape (no rounded corners)
                  ),
                ),
                child: MyTextfield.textStyle_w600('Cancel', 18, Colors.grey),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.kPrimary),
                  ),
                ),
                child: MyTextfield.textStyle_w600(
                    'Retry', 18, AppColors.kWhiteColor),
              ),
            ],
          ),
    );
  }
}
  /// Timeout exception class
class TimeoutException implements Exception {
  final String message;

  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
