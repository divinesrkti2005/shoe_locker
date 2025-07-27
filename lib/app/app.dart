import 'package:flutter/material.dart';
import '../features/splash/presentation/view/splash_view.dart';
import '../features/auth/presentation/view/login_view.dart';
import '../features/auth/presentation/view/register_view.dart';
import '../features/home/presentation/view/bottom_view/dashboard_view.dart';
import '../core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoe Locker',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/login': (context) => const LoginView(),
        '/signup': (context) => const RegisterView(),
        '/dashboard': (context) => const DashboardView(),
      },
    );
  }
} 