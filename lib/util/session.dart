import 'package:customer/pages/login_page.dart';
import 'package:customer/util/bottom_navigation_bar_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _userKey = 'loggedUserID';

/// Saves the logged-in user and opens the main app, clearing the login and
/// register screens so Back doesn't return to them.
Future<void> startSession(BuildContext context, int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_userKey, userId);
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => BottomNavigationBarPage(userId: userId)),
    (_) => false,
  );
}

/// Forgets the user and returns to the login screen with an empty history.
Future<void> endSession(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_userKey);
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (_) => false,
  );
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please enter your email';
  if (!_emailPattern.hasMatch(v)) return 'Please enter a valid email';
  return null;
}

String? validateRequired(String? value, String what) {
  if (value == null || value.trim().isEmpty) return 'Please enter your $what';
  return null;
}

String? validatePhone(String? value) {
  final digits = value?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
  if (digits.isEmpty) return 'Please enter your phone number';
  if (!RegExp(r'^\+?\d{10,13}$').hasMatch(digits)) {
    return 'Please enter a valid phone number';
  }
  return null;
}
