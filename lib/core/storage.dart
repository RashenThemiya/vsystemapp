import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _tokenKey = "token";
  static const _driverIdKey = "driver_id";

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save driverId
  static Future<void> saveDriverId(int driverId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_driverIdKey, driverId);
  }

  // Get driverId
  static Future<int> getDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_driverIdKey) ?? 0; // return 0 if not found
  }
}
