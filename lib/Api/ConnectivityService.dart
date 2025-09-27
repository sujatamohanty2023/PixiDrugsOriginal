import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../constant/all.dart'; // Adjust this to your correct import

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static late ConnectivityResult _previousResult;
  static final ValueNotifier<ConnectivityResult> connectivityNotifier =
  ValueNotifier(ConnectivityResult.none);

  /// Initialize the connectivity service
  static Future<void> initializeConnectivity(BuildContext context) async {
    // Get the initial connectivity state
    var result = await _connectivity.checkConnectivity();
    _previousResult = _extractConnectivityResult(result);
    connectivityNotifier.value = _previousResult;

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((dynamic result) {
      ConnectivityResult newResult = _extractConnectivityResult(result);

      if (newResult != _previousResult) {
        _previousResult = newResult;
        connectivityNotifier.value = newResult;

        // Show snackbar on connectivity change
        _showConnectivitySnackbar(context, newResult);
      }
    });
  }

  /// Extract first result from list or return result directly
  static ConnectivityResult _extractConnectivityResult(dynamic result) {
    if (result is List<ConnectivityResult>) {
      return result.isNotEmpty ? result.first : ConnectivityResult.none;
    } else if (result is ConnectivityResult) {
      return result;
    } else {
      return ConnectivityResult.none;
    }
  }

  /// Show snackbar based on connectivity result
  static void _showConnectivitySnackbar(
      BuildContext context, ConnectivityResult result) {
    String message = result == ConnectivityResult.none
        ? 'No internet connection!'
        : 'Connected to the internet!';

    // Ensure the context is mounted in the widget tree
    if (context.mounted) {
      AppUtils.showSnackBar(context, message);
    }
  }

  /// Check connectivity at any point in the app
  static Future<bool> isConnected() async {
    var result = await _connectivity.checkConnectivity();
    ConnectivityResult connectivityResult = _extractConnectivityResult(result);
    return connectivityResult != ConnectivityResult.none;
  }
}
