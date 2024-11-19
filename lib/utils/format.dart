// lib/utils/format.dart

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

String formatPrice(double price, String propertyType) {
  if (propertyType == 'agri land') {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)}C';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L';
    } else {
      return price.toStringAsFixed(0);
    }
  } else {
    if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L';
    } else {
      return price.toStringAsFixed(0);
    }
  }
}
