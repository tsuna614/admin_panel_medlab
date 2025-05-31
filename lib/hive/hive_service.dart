import 'package:hive/hive.dart';

abstract class HiveService {
  static final Box _credentialsBox = Hive.box('credentialsBox');

  static Future<void> storeLocale(String locale) async {
    await _credentialsBox.put('locale', locale);
  }

  static Future<String> getLocale() async {
    return await _credentialsBox.get('locale', defaultValue: 'en');
  }

  static Future<void> storeUserToken({
    required String id,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _credentialsBox.put('id', id);
    await _credentialsBox.put('accessToken', accessToken);
    await _credentialsBox.put('refreshToken', refreshToken);
  }

  static Future<void> updateAccessToken({required String accessToken}) async {
    await _credentialsBox.put('accessToken', accessToken);
  }

  static Future<void> clearUserToken() async {
    await _credentialsBox.delete('id');
    await _credentialsBox.delete('accessToken');
    await _credentialsBox.delete('refreshToken');
  }

  static Future<String> getUserId() async {
    return await _credentialsBox.get('id', defaultValue: '');
  }

  static Future<String> getUserAccessToken() async {
    return await _credentialsBox.get('accessToken', defaultValue: '');
  }

  static Future<String> getUserRefreshToken() async {
    return await _credentialsBox.get('refreshToken', defaultValue: '');
  }
}
