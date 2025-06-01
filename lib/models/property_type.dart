enum PropertyType {
  plot('Plot'),
  agriLand('Agri Land'),
  farmLand('Farm Land'),
  house('House'),
  villa('Villa'),
  apartment('Apartment'),
  development('Development'),
  commercialSpace('Commercial Space');

  final String label;
  const PropertyType(this.label);

  static PropertyType fromLabel(String value) {
    return PropertyType.values.firstWhere(
          (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => PropertyType.plot,
    );
  }

  static PropertyType fromEnumString(String value) {
    final lastPart = value.split('.').last;
    return PropertyType.values.firstWhere(
          (e) => e.toString().split('.').last == lastPart,
      orElse: () => PropertyType.plot,
    );
  }

  String get normalized => label.toLowerCase();
}
