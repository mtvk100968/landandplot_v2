// lib/utils/validators.dart

class Validators {
  // General required field validator
  static String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Validator for phone number
  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (!RegExp(r'^\+91[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

// Validator for price (positive numbers only, supports Indian number system formatting)
  static String? priceValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    // Remove commas for validation
    String sanitizedValue = value.replaceAll(',', '');

    // Check if the sanitized value is a valid positive number
    if (double.tryParse(sanitizedValue) == null ||
        double.parse(sanitizedValue) <= 0) {
      return 'Enter a valid price';
    }

    return null;
  }

  // Validator for area (positive numbers only)
  static String? areaValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Area is required';
    }

    // Remove commas for validation
    String sanitizedValue = value.replaceAll(',', '');

    // Check if the sanitized value is a valid positive number

    if (double.tryParse(sanitizedValue) == null ||
        double.parse(sanitizedValue) <= 0) {
      return 'Enter a valid area';
    }
    return null;
  }

  // Validator for survey number
  static String? surveyNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Survey number is required';
    }
    return null;
  }

  // Validator for plot numbers
  static String? plotNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Plot number is required';
    }
    return null;
  }

  // Validator for plot numbers
  static String? hvaNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'House/Villa/Apartment number is required';
    }
    return null;
  }

  // Pincode Validator (6 digits for India)
  static String? pincodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    } else if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }
}
