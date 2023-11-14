import 'package:conscious_cart_ui/models/Packaging.dart';

class Ingredient {
  String id;
  String name;
  String quantity;
  String servingSize;
  String warning;
  double packagingScore;
  int numberNonRecyclableAndNonBiodegradableMaterials;
  List<Packaging> packages;

  Ingredient(
      this.id,
      this.name,
      this.quantity,
      this.servingSize,
      this.warning,
      this.packagingScore,
      this.numberNonRecyclableAndNonBiodegradableMaterials,
      this.packages);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'servingSize': servingSize,
      'warning': warning,
      'packagingScore': packagingScore,
      'numberNonRecyclableAndNonBiodegradableMaterials':
          numberNonRecyclableAndNonBiodegradableMaterials,
      'packages': packages.map((package) => package.toJson()).toList(),
    };
  }

  // Factory constructor to create an Ingredient object from a Map
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    List<Packaging> parsedPackages = [];
    if (map['packages'] is List<dynamic>) {
      // Check if 'packages' is a list
      for (var packageData in map['packages']) {
        if (packageData is Map<String, dynamic>) {
          // Check if each item in the list is a map
          Packaging package = Packaging.fromMap(packageData);
          parsedPackages.add(package);
        }
      }
    }
    return Ingredient(
      map['id'] ?? '',
      map['name'] ?? '',
      map['quantity'] ?? '',
      map['servingSize'] ?? '',
      map['warning'] ?? '',
      map['packagingScore']?.toDouble() ?? 0.0,
      map['numberNonRecyclableAndNonBiodegradableMaterials'] ?? 0,
      parsedPackages,
    );
  }
}

//Fields to care about:
/*
_id/id
product_name
quantity
serving_size

ecoscore_data - adjustments VVVV
- score
- non_recyclable_and_non_biodegradable_materials
- warning
- Packaging

*/
