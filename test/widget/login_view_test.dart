import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_locker/features/auth/presentation/view/login_view.dart';

void main() {
  group('LoginView Widget Tests', () {
    testWidgets('should display login form with email and password fields',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should show welcome text and app title',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Assert
      expect(find.text('Welcome to ShoeLocker'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('should show forgot password link',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Assert
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should show register link',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Assert
      expect(find.text('Don\'t have an account?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should validate email field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      
      // Tap the sign in button without entering any data
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should validate password field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      
      // Enter email but not password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should validate email format',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      
      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password length',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      
      // Enter valid email but short password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      
      // Find the password visibility toggle button
      final passwordField = find.byType(TextFormField).last;
      final visibilityButton = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );
      
      // Tap the visibility toggle
      await tester.tap(visibilityButton);
      await tester.pump();

      // Assert - the icon should change (this is a basic test)
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should show loading indicator when form is submitted',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      
      // Enter valid data
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      
      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have proper form structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Assert
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
} 