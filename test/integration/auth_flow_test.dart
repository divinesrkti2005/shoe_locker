import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_locker/features/auth/presentation/view/login_view.dart';
import 'package:shoe_locker/features/auth/presentation/view/register_view.dart';
import 'package:shoe_locker/features/home/presentation/view/bottom_view/dashboard_view.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    testWidgets('login form validation flow', (WidgetTester tester) async {
      // Start with login view
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Verify initial state
      expect(find.text('Welcome to ShoeLocker'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Try to login without entering credentials
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify validation errors are shown
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Enter valid email but short password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify password validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('register form validation flow', (WidgetTester tester) async {
      // Start with register view
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Verify initial state
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join ShoeLocker today'), findsOneWidget);

      // Try to register without entering data
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Verify validation errors
      expect(find.text('Please enter your first name'), findsOneWidget);
      expect(find.text('Please enter your last name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);

      // Enter partial data
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'invalid-email');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Verify email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Enter valid email but mismatched passwords
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.enterText(find.byType(TextFormField).at(5), 'differentpassword');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Verify password confirmation error
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('password visibility toggle flow', (WidgetTester tester) async {
      // Test login view password visibility
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Find the password visibility toggle button
      final passwordField = find.byType(TextFormField).last;
      final visibilityButton = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );

      // Verify button exists
      expect(visibilityButton, findsOneWidget);

      // Tap the visibility toggle
      await tester.tap(visibilityButton);
      await tester.pump();

      // Test register view password visibility
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Find both password visibility toggle buttons
      final passwordFields = find.byType(TextFormField);
      final passwordVisibilityButtons = find.descendant(
        of: passwordFields,
        matching: find.byType(IconButton),
      );

      // Verify both buttons exist
      expect(passwordVisibilityButtons, findsNWidgets(2));
    });

    testWidgets('navigation flow between login and register', (WidgetTester tester) async {
      // Start with login view
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Verify we're on login screen
      expect(find.text('Welcome to ShoeLocker'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Navigate to register (simulate navigation)
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Verify we're on register screen
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join ShoeLocker today'), findsOneWidget);

      // Navigate back to login (simulate navigation)
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Verify we're back on login screen
      expect(find.text('Welcome to ShoeLocker'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('dashboard view test', (WidgetTester tester) async {
      // Test dashboard view
      await tester.pumpWidget(const MaterialApp(home: DashboardView()));

      // Verify dashboard elements
      expect(find.text('ShoeLocker'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // Test bottom navigation
      await tester.tap(find.text('Cart'));
      await tester.pump();

      await tester.tap(find.text('Profile'));
      await tester.pump();

      await tester.tap(find.text('About'));
      await tester.pump();

      await tester.tap(find.text('Home'));
      await tester.pump();
    });

    testWidgets('form field interaction flow', (WidgetTester tester) async {
      // Test login form interactions
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Enter text in email field
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.pump();

      // Enter text in password field
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      // Clear fields
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.enterText(find.byType(TextFormField).last, '');
      await tester.pump();

      // Test register form interactions
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Enter text in all fields
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.enterText(find.byType(TextFormField).at(5), 'password123');
      await tester.pump();

      // Verify all fields have the entered text
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
    });

    testWidgets('loading state flow', (WidgetTester tester) async {
      // Test login loading state
      await tester.pumpWidget(const MaterialApp(home: LoginView()));

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Test register loading state
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Enter valid data
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.enterText(find.byType(TextFormField).at(5), 'password123');

      // Tap sign up button
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
} 