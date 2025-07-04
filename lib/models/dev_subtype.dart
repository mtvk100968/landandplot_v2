enum DevSubtype {
  developmentPlot(label: 'Development Plot', firestoreKey: 'Development Plot'),
  developmentLand(label: 'Development Land', firestoreKey: 'Development Land'); // ✅ FIXED CASE HERE

  final String label;
  final String firestoreKey;

  const DevSubtype({required this.label, required this.firestoreKey});

  static DevSubtype? fromKey(String key) {
    try {
      return DevSubtype.values.firstWhere((e) => e.firestoreKey == key);
    } catch (_) {
      return null;
    }
  }

  static DevSubtype fromLabel(String label) {
    return DevSubtype.values.firstWhere(
          (e) => e.label == label,
      orElse: () => DevSubtype.developmentPlot,
    );
  }

  @override
  String toString() => label;
}
