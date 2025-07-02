import 'package:pixidrugs/constant/all.dart';

class CommonConfirmationDialog {
  static Future<void> show<T>({
    required BuildContext context,
    required T id,
    required String title,
    required String content,
    required Function(T) onConfirmed,
  }) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: MyTextfield.textStyle_w800(title, 20, Colors.black),
          content: MyTextfield.textStyle_w300(content, 16, Colors.black54),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: MyTextfield.textStyle_w600('No', 16, Colors.green),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: MyTextfield.textStyle_w600('Yes', 16, Colors.red),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onConfirmed(id);
    }
  }
}
