import 'dart:ffi';

import 'package:flutter/material.dart';

class PicnicFormValidators {
  static FormFieldValidator<String> notEmpty(String message) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLength(String message, {length}) {
    return (String? value) {
      if (value == null || value.isEmpty || value.length < length) {
        return message;
      }
      return null;
    };
  }

  static FormFieldValidator<String> email([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message ?? 'Email is required';
      }

      final emailRegex = RegExp(r"^[a-zA-Z0-9. _%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid email';
      }
      return null;
    };
  }

  static FormFieldValidator<String> custom(Function callbackFunction){
    return (String? value) {
      return callbackFunction(value);
    };
  }

  static FormFieldValidator<String> composite(
    List<FormFieldValidator<String>?> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator!(value);
        if (result != null) {
          return result; // Return first error found
        }
      }
      return null; // All validators passed
    };
  }
}
