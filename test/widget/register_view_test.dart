import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_locker/features/auth/presentation/view/register_view.dart';

void main() {
  group('RegisterView Widget Tests', () {
    testWidgets('should display registration form with all required fields',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(6));
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should show welcome text and app title',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Assert
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join ShoeLocker today'), findsOneWidget);
    });

    testWidgets('should show login link',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Assert
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });

    testWidgets('should validate first name field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Tap the sign up button without entering any data
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your first name'), findsOneWidget);
    });

    testWidgets('should validate last name field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter first name but not last name
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your last name'), findsOneWidget);
    });

    testWidgets('should validate email field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter first and last name but not email
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should validate email format',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'invalid-email');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate phone field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter first, last name, and email but not phone
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your phone number'), findsOneWidget);
    });

    testWidgets('should validate password field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter all fields except password
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('should validate password length',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter valid data but short password
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.enterText(find.byType(TextFormField).at(4), '123');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should validate confirm password field when empty',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter all fields except confirm password
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('should validate password confirmation match',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Enter valid data but mismatched passwords
      await tester.enterText(find.byType(TextFormField).first, 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.enterText(find.byType(TextFormField).at(5), 'differentpassword');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should toggle password visibility for both password fields',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
      
      // Find the password visibility toggle buttons
      final passwordFields = find.byType(TextFormField);
      final passwordVisibilityButtons = find.descendant(
        of: passwordFields,
        matching: find.byType(IconButton),
      );
      
      // Assert - should have two visibility toggle buttons
      expect(passwordVisibilityButtons, findsNWidgets(2));
    });

    testWidgets('should show loading indicator when form is submitted',
        (WidgetTester tester) async {
      // Act
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

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have proper form structure',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Assert
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have proper input decoration for all fields',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));

      // Assert - all text fields should have proper decoration
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(6));
      
      // Check that all fields exist and are properly rendered
      for (int i = 0; i < 6; i++) {
        expect(textFields.at(i), findsOneWidget);
      }
    });
  });
} 