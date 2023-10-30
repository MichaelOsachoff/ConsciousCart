import 'package:conscious_cart_ui/models/Packaging.dart';

class Product {
  String id;
  String name;
  String quantity;
  String servingSize;
  String warning;
  double packagingScore;
  int numberNonRecyclableAndNonBiodegradableMaterials;
  List<Packaging> packages;

  Product(
      this.id,
      this.name,
      this.quantity,
      this.servingSize,
      this.warning,
      this.packagingScore,
      this.numberNonRecyclableAndNonBiodegradableMaterials,
      this.packages);
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