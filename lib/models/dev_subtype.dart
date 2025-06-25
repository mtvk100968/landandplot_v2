// lib/models/dev_subtype.dart

enum DevSubtype {
  plot    ('Development Plot', 'development_plot'),
  land    ('Development Land', 'development_land');

  final String label, firestoreKey;
  const DevSubtype(this.label, this.firestoreKey);

  static DevSubtype fromLabel(String dbValue) {
    return values.firstWhere(
          (e) => e.label.toLowerCase() == dbValue.toLowerCase(),
      orElse: () => DevSubtype.plot,
    );
  }
}
