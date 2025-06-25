enum PropertyType {
  plot('Plot'),
  agriLand('Agri Land'),
  farmLand('Farm Land'),
  apartment('Apartment'),
  villa('Villa'),
  house('House'),
  development('Development'),
  // developmentPlot('Development Plot'),
  // developmentLand('Development Land'),
  commercialSpace('Commercial Space');

  final String label;
  const PropertyType(this.label);


  static PropertyType fromLabel(String dbValue) {
    return PropertyType.values.firstWhere(
          (e) => e.label.toLowerCase() == dbValue.toLowerCase(),
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

  /// Returns exactly the string you store in Firestore’s `propertyType` field.
  String get firestoreKey {
    switch (this) {
      case PropertyType.plot:           return 'Plot';
      case PropertyType.agriLand:       return 'Agri Land';
      case PropertyType.farmLand:       return 'Farm Land';
      case PropertyType.apartment:      return 'Apartment';
      case PropertyType.villa:          return 'Villa';
      case PropertyType.house:          return 'House';
      case PropertyType.development:    return 'Development';
      // case PropertyType.developmentPlot:return 'development_plot';
      // case PropertyType.developmentLand:return 'development_land';
      case PropertyType.commercialSpace:return 'Commercial Space';
    }
  }
}


