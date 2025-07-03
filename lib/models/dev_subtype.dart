enum DevSubtype {
  plot('Development_Plot', 'development_plot'),
  land('Development_Land', 'development_land');

  final String label;
  final String firestoreKey;
  const DevSubtype(this.label, this.firestoreKey);

  static DevSubtype fromKey(String key) {
    return DevSubtype.values.firstWhere(
          (e) => e.firestoreKey == key,
      orElse: () => DevSubtype.plot,
    );
  }

  static DevSubtype fromLabel(String label) {
    return DevSubtype.values.firstWhere(
          (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => DevSubtype.plot,
    );
  }
}
