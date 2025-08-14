import 'package:PixiDrugs/constant/all.dart';

class CommonConfirmationDialog {
  static Future<void> show<T>({
    required BuildContext context,
    required T id,
    required String title,
    required String content,
    required Function(T) onConfirmed,
    String negativeButton = 'No',
    String positiveButton = 'Yes',
  }) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Make dialog background transparent
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.myGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                MyTextfield.textStyle_w800(title, 20,AppColors.kPrimary),
                const SizedBox(height: 12),
                // Content
                MyTextfield.textStyle_w300(content, 16, Colors.black54),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: MyTextfield.textStyle_w800(
                        negativeButton,
                        18,
                        AppColors.kRedColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.kPrimaryDark, width: 1),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: MyTextfield.textStyle_w800(
                          positiveButton,
                          18,
                          AppColors.kWhiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      onConfirmed(id);
    }
  }
}