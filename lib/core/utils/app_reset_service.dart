import 'package:shared_preferences/shared_preferences.dart';

class AppResetService {
  Future<void> resetAll() async {
    // SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Note: Data on the server should be handled by an API call if needed
  }
}
