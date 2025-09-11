
import 'package:PixiDrugs/constant/all.dart';

class SessionManager {
  static const _accessTokenKey = 'access_token';
  static const _roleKey = 'role';
  static const _userIdKey = 'user_id';
  static const _parentingIdKey = 'parent_id';
  static const _addressModelKey = 'user_address_model';
  static const _currentLatLngKey = 'saved_latlng';

  // Save login response
  static Future<void> saveLoginResponse(LoginResponse response) async {
    int? id=0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, response.accessToken??'');
    await prefs.setString(_roleKey, response.user?.role ?? 'guest');
    await prefs.setString(_userIdKey,response.user!.id.toString());
    if(response.user!.role=='staff'){
      id=response.user!.parentId;
    }else if(response.user!.role=='owner'){
      id=response.user!.id;
    }
    await prefs.setString(_parentingIdKey,id.toString());
  }

  // Load access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  static Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey,token);
  }

  // Load role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Load Parenting ID
  static Future<String?> getParentingId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_parentingIdKey);
  }
  // Load Parenting ID
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
    await prefs.remove(_parentingIdKey);
    await prefs.remove(_addressModelKey);
  }
}

class UserRoles {
  static const String doctor = 'doctor';
  static const String user = 'user';
  static const String clinic = 'clinic';
}
