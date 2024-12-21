import 'package:flutter/services.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

String capitalizeEachWord(String input) {
  if (input.isEmpty) return input;
  return input
      .split(' ')
      .map((word) => word.isEmpty ? word : word.capitalize())
      .join(' ');
}

TextInputFormatter capitalizeWordsInputFormatter() {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    String transformed = capitalizeEachWord(newValue.text);
    return newValue.copyWith(
      text: transformed,
      selection: TextSelection.collapsed(offset: transformed.length),
    );
  });
}

// Your existing price formatting functions remain unchanged
String formatPrice(double price) {
  String formatValue(double value) {
    // Format value and remove .0 if it exists
    String formatted = value.toStringAsFixed(1);
    return formatted.endsWith('.0')
        ? formatted.substring(0, formatted.length - 2)
        : formatted;
  }

  if (price >= 10000000) {
    return '₹${formatValue(price / 10000000)}C';
  } else if (price >= 100000) {
    return '₹${formatValue(price / 100000)}L';
  } else {
    return '₹${formatValue(price)}';
  }
}

String formatIndianPrice(double price) {
  final formatter = RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))');
  return price
      .toString()
      .replaceAllMapped(formatter, (match) => '${match[1]},');
}

String formatValue(double value) {
  // Format value and remove .0 if it exists
  String formatted = value.toStringAsFixed(1);
  return formatted.endsWith('.0')
      ? formatted.substring(0, formatted.length - 2)
      : formatted;
}
