import 'package:conscious_cart_ui/models/Ingredient.dart';
import 'package:intl/intl.dart';

class Recipe {
  String recipeName;
  double totalRecipeScore;
  String formattedDate;
  List<Ingredient> ingredients;

  Recipe(this.recipeName, this.totalRecipeScore, this.formattedDate,
      this.ingredients);

  // Factory constructor to create a Recipe object from a Map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    List<Ingredient> parsedIngredients = [];

    if (map['ingredients'] is List<dynamic>) {
      // Check if 'ingredients' is a list
      for (var ingredientData in map['ingredients']) {
        if (ingredientData is Map<String, dynamic>) {
          // Check if each item in the list is a map
          Ingredient ingredient = Ingredient.fromMap(ingredientData);
          parsedIngredients.add(ingredient);
        }
      }
    }

    DateTime tempFormattedDateTime = DateTime.parse(map["dateOfCreation"]);
    final customFormat = DateFormat('hh:mma - MMMM dd, yyyy', 'en_US');

    // Convert the DateTime to the desired time zone
    final saskatchewanTimeZone =
        customFormat.format(tempFormattedDateTime.toLocal());

    return Recipe(
      map['recipeName'] ?? '',
      map['totalRecipeScore']?.toDouble() ?? 0.0,
      saskatchewanTimeZone,
      parsedIngredients,
    );
  }
}
