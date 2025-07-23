
import 'package:PixiDrugs/constant/all.dart';

class SessionManager {
  static const _accessTokenKey = 'access_token';
  static const _roleKey = 'role';
  static const _userIdKey = 'user_id';
  static const _addressModelKey = 'user_address_model';
  static const _currentLatLngKey = 'saved_latlng';

  // Save login response
  static Future<void> saveLoginResponse(LoginModel response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, response.accessToken);
    await prefs.setString(_roleKey, response.user!.role);
    await prefs.setString(_userIdKey, response.user!.id.toString());
  }

  // Load access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Load role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Load user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Clear session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_addressModelKey);
  }
}

class UserRoles {
  static const String doctor = 'doctor';
  static const String user = 'user';
  static const String clinic = 'clinic';
}
