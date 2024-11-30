// lib/utils/format.dart

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

String formatPrice(double price, String propertyType) {
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
  } else if (price >= 1000) {
    return '₹${formatValue(price / 1000)}K';
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
