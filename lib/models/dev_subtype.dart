enum DevSubtype {
  developmentPlot(label: 'Development Plot', firestoreKey: 'development plot'),
  developmentLand(label: 'Development Land', firestoreKey: 'development land');

  final String label;
  final String firestoreKey;

  const DevSubtype({required this.label, required this.firestoreKey});

  static DevSubtype? fromKey(String key) {
    return DevSubtype.values.firstWhere(
          (e) => e.firestoreKey == key,
      orElse: () => DevSubtype.developmentPlot,
    );
  }

  static DevSubtype fromLabel(String label) {
    return DevSubtype.values.firstWhere(
          (e) => e.label == label,
      orElse: () => DevSubtype.developmentPlot,
    );
  }
}


// enum DevSubtype {
//   developmentPlot('Development Plot', 'development plot'),
//   developmentLand('Development Land', 'development land');
//
//   final String label;
//   final String firestoreKey;
//
//   const DevSubtype(this.label, this.firestoreKey);
//
//   static DevSubtype? fromKey(String key) {
//     return DevSubtype.values.firstWhere(
//           (e) => e.firestoreKey == key,
//       orElse: () => DevSubtype.developmentPlot,
//     );
//   }
//
//   static DevSubtype fromLabel(String label) {
//     return DevSubtype.values.firstWhere(
//           (e) => e.label == label,
//       orElse: () => DevSubtype.developmentPlot,
//     );
//   }
// }
