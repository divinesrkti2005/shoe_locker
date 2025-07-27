import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoe_locker/app/shared_pref/shared_pref_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saveAuthData and getToken work correctly', () async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefService.saveAuthData(token: 'abc', userId: '123', role: 'customer');
    final token = await SharedPrefService.getToken();
    expect(token, 'abc');
  });
} 