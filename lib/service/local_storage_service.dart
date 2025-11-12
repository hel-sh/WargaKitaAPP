import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _kUserUid = 'user_uid';

  Future<void> saveUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserUid, uid);
  }

  Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserUid);
  }

  Future<void> deleteUid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserUid);
  }
}