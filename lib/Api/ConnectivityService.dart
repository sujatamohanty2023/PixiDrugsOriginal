

import 'package:PixiDrugs/constant/all.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static late ConnectivityResult _previousResult;
  static final ValueNotifier<ConnectivityResult> connectivityNotifier =
      ValueNotifier(ConnectivityResult.none);

  // Initialize the connectivity service
  static Future<void> initializeConnectivity(BuildContext context) async {
    // Get the initial connectivity state
    _previousResult = await _connectivity.checkConnectivity();
    connectivityNotifier.value = _previousResult;

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != _previousResult) {
        _previousResult = result;
        connectivityNotifier.value = result;

        // Ensure SnackBar is shown in the right context
        _showConnectivitySnackbar(context, result);
      }
    });
  }

  // Show snackbar based on connectivity result
  static void _showConnectivitySnackbar(
      BuildContext context, ConnectivityResult result) {
    String message = '';
    if (result == ConnectivityResult.none) {
      message = 'No internet connection!';
    } else {
      message = 'Connected to the internet!';
    }

    // Only show the SnackBar if context is valid and in the widget tree
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Check connectivity at any point in the app
  static Future<bool> isConnected() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
