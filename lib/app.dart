import 'package:flutter/material.dart';
import 'view/splash_screen.dart';
import 'view/login_page.dart';
import 'view/signup_page.dart';
import 'view/dashboard_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoe Locker',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/dashboard': (context) => DashboardPage(),
      },
    );
  }
}
