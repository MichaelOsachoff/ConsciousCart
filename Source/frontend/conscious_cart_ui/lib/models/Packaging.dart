class Packaging {
  int ecoscoreMaterialScore;
  String material;

  double weightMeasured;
  String numberOfUnits;
  String nonRecyclableAndNonBiodegradable;
  String recycling;
  String shape;

  Packaging(
      this.ecoscoreMaterialScore,
      this.material,
      this.weightMeasured,
      this.numberOfUnits,
      this.nonRecyclableAndNonBiodegradable,
      this.recycling,
      this.shape);

  Map<String, dynamic> toJson() {
    return {
      'ecoscoreMaterialScore': ecoscoreMaterialScore,
      'material': material,
      'weightMeasured': weightMeasured,
      'numberOfUnits': numberOfUnits,
      'nonRecyclableAndNonBiodegradable': nonRecyclableAndNonBiodegradable,
      'recycling': recycling,
      'shape': shape,
    };
  }

  // Factory constructor to create a Packaging object from a Map
  factory Packaging.fromMap(Map<String, dynamic> map) {
    // Assuming the keys in the map match the field names in your Packaging class
    return Packaging(
      map['ecoscoreMaterialScore'] ?? 0,
      map['material'] ?? '',
      map['weightMeasured']?.toDouble() ?? 0.0,
      map['numberOfUnits'] ?? '',
      map['nonRecyclableAndNonBiodegradable'] ?? '',
      map['recycling'] ?? '',
      map['shape'] ?? '',
    );
  }
}
  // - packaging VVVV (list)
  // - ecoscore_material_score, 
  // - material, 
  // - weight_measured, 
  // - number of units, 
  // - quantity_per_unit_value, 
  // - quantity_per_unit_unit, 
  // - non_recyclable_and_non_biodegradable, 
  // - recycling
