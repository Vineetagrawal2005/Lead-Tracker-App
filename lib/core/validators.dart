/// Form validators for Lead Tracker.
///
/// All validators return `null` when the input is valid, or a user-facing
/// error string when it is not. They are pure functions so they can be tested
/// independently of the UI.
library;

import '../core/constants.dart';

/// Validates an email address. Returns null if valid or empty (optional).
String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final email = value.trim();
  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegExp.hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

/// Validates a required name (min 2 characters).
String? nameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name is required';
  }
  if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}

/// Validates a required password (min 6 characters).
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

/// Validates a signup password: min 6 chars, must contain a letter and a number.
String? signupPasswordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
  final hasDigit = RegExp(r'[0-9]').hasMatch(value);
  if (!hasLetter || !hasDigit) {
    return 'Password must contain a letter and a number';
  }
  return null;
}

/// Validates confirm password matches the given password.
String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}

/// Validates a 10-digit Indian mobile number starting with 6, 7, 8 or 9.
String? phoneValidator(String? value, {bool required = true}) {
  if (value == null || value.trim().isEmpty) {
    if (required) return 'Phone number is required';
    return null;
  }
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 10) {
    return 'Phone must be exactly 10 digits';
  }
  if (!RegExp(r'^[6-9]').hasMatch(digits)) {
    return 'Phone must start with 6, 7, 8 or 9';
  }
  return null;
}

/// Validates an optional company name (max 60 characters).
String? companyValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length > 60) {
    return 'Company must be at most 60 characters';
  }
  return null;
}

/// Validates a note (non-empty, max [kMaxNoteLength] characters).
String? noteValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Note cannot be empty';
  }
  if (value.trim().length > kMaxNoteLength) {
    return 'Note must be at most $kMaxNoteLength characters';
  }
  return null;
}
