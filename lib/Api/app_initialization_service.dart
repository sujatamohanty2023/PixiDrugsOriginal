import '../../constant/all.dart';

class AppInitializationService {
  static bool _isInitialized = false;
  static String? _cachedRole;
  static String? _cachedUserId;

  /// Initialize user profile and cache essential data when app starts
  static Future<void> initializeUserProfile(BuildContext context) async {
    if (_isInitialized) return; // Prevent multiple initializations

    try {
      // Get user credentials from session
      final userId = await SessionManager.getParentingId();
      final role = await SessionManager.getRole();

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found in session');
      }

      // Cache basic info
      _cachedUserId = userId;
      _cachedRole = role;

      // Get API cubit and load user profile
      final apiCubit = context.read<ApiCubit>();

      // Make API call to get user profile
      apiCubit.GetUserData(userId: userId);

      // Wait for profile to load (with timeout)
      await _waitForProfileLoad(apiCubit);

      _isInitialized = true;
    } catch (e) {
      print('❌ App initialization failed: $e');
      // Don't throw here - let the app continue to login screen
    }
  }

  /// Force refresh user profile and update cached data
  static Future<void> refreshProfile(BuildContext context) async {
    try {
      final userId = await getUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID is missing or invalid.');
      }

      final apiCubit = context.read<ApiCubit>();
      await apiCubit.GetUserData(userId: userId); // Should return Future

      print('🔄 User profile refreshed successfully');
    } catch (e) {
      print('❌ Failed to refresh user profile: $e');
      handleInitializationError(context, e.toString());
    }
  }

  /// Get the cached user profile
  static UserProfile? getCachedProfile(BuildContext context) {
    return context.read<ApiCubit>().cachedUser?.user;
  }

  /// Wait for user profile to load with timeout
  static Future<void> _waitForProfileLoad(ApiCubit apiCubit) async {
    const timeout = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 100);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      if (apiCubit.cachedUser != null) {
        return; // Profile loaded successfully
      }

      await Future.delayed(checkInterval);
    }

    throw Exception('Profile loading timeout');
  }

  /// Get cached role (faster than reading from SharedPreferences)
  static Future<String?> getRole() async {
    if (_cachedRole != null) {
      return _cachedRole;
    }

    _cachedRole = await SessionManager.getRole();
    return _cachedRole;
  }

  /// Get cached user ID (faster than reading from SharedPreferences)
  static Future<String?> getUserId() async {
    if (_cachedUserId != null) {
      return _cachedUserId;
    }

    _cachedUserId = await SessionManager.getParentingId();
    return _cachedUserId;
  }

  /// Check if user profile is initialized
  static bool get isInitialized => _isInitialized;

  /// Reset initialization state (useful for logout)
  static void reset() {
    _isInitialized = false;
    _cachedRole = null;
    _cachedUserId = null;
  }

  /// Pre-load essential app data
  static Future<void> preloadAppData(BuildContext context) async {
    try {
      final apiCubit = context.read<ApiCubit>();

      // Load banners in background
      apiCubit.fetchBanner();

      // Add more preloading here if needed:
      // - Product categories
      // - Recent transactions
      // - App settings
    } catch (e) {
      print('⚠️ Failed to preload some app data: $e');
    }
  }

  /// Check if user session is still valid
  static Future<bool> isSessionValid() async {
    try {
      final userId = await getUserId();
      final role = await getRole();

      return userId != null &&
          userId.isNotEmpty &&
          role != null &&
          role.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Validate user status (active/inactive)
  static bool validateUserStatus(dynamic userModel, String? role) {
    try {
      if (userModel?.user?.status == null) return false;

      // Both owner and staff must be active
      return userModel.user.status == 'active';
    } catch (e) {
      return false;
    }
  }

  /// Handle initialization errors gracefully
  static void handleInitializationError(BuildContext context, String error) {
    print('🚨 Initialization Error: $error');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize app. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Clear all cached data and reset state
  static Future<void> clearCache() async {
    _isInitialized = false;
    _cachedRole = null;
    _cachedUserId = null;

    await SessionManager.clearSession();
  }

  /// Initialize app with all required data
  static Future<void> fullInitialization(BuildContext context) async {
    try {
      await initializeUserProfile(context);
      await preloadAppData(context);
      print('✅ App fully initialized successfully');
    } catch (e) {
      handleInitializationError(context, e.toString());
      rethrow;
    }
  }
}
