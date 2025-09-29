
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constant/all.dart';

/// Comprehensive loading management system for the app
class AppLoader {
  static OverlayEntry? _overlayEntry;
  static bool _isLoading = false;

  /// Show full screen loading overlay
  static void show(BuildContext context, {String? message}) {
    if (_isLoading) return;

    _isLoading = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingOverlay(message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide full screen loading overlay
  static void hide() {
    if (!_isLoading) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isLoading = false;
  }

  /// Check if loader is currently showing
  static bool get isLoading => _isLoading;

  /// Force hide loader (use carefully)
  static void forceHide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isLoading = false;
  }
}

/// Full screen loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7), // semi-transparent background
      child: Center(
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 24,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitThreeBounce(
                  color: AppColors.kPrimary,
                  size: 40.0,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kBlackColor800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

