// lib/models/dev_subtype.dart

enum DevSubtype {
  plot    ('Development_Plot', 'development_plot'),
  land    ('Development_Land', 'development_land');

  final String label, firestoreKey;
  const DevSubtype(this.label, this.firestoreKey);

  static DevSubtype fromLabel(String dbValue) {
    return values.firstWhere(
          (e) => e.label.toLowerCase() == dbValue.toLowerCase(),
      orElse: () => DevSubtype.plot,
    );
  }
}
