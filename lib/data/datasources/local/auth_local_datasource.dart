import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

class AuthLocalDataSource {
  Box? _box;

  Future<Box> get box async {
    _box ??= await Hive.openBox(AppConstants.authBoxName);
    return _box!;
  }

  Future<bool> isLoggedIn() async {
    final b = await box;
    return b.get('isLoggedIn', defaultValue: false);
  }

  Future<void> login(String email) async {
    final b = await box;
    await b.put('isLoggedIn', true);
    await b.put('email', email);
  }

  Future<void> logout() async {
    final b = await box;
    await b.put('isLoggedIn', false);
    await b.delete('email');
  }

  Future<String?> getEmail() async {
    final b = await box;
    return b.get('email');
  }
}
