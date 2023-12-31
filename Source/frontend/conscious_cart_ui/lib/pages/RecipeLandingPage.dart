import 'package:conscious_cart_ui/models/Packaging.dart';
import 'package:conscious_cart_ui/models/Ingredient.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const colourDefault = Color(0xFF000000);
const colourBad = Color(0xFFC20000);
const colourOkay = Color(0xFFC26E00);
const colourGood = Color(0xFF00C21D);

class RecipeLandingPage extends StatefulWidget {
  @override
  _RecipeLandingPageState createState() => _RecipeLandingPageState();
}

class _RecipeLandingPageState extends State<RecipeLandingPage> {
  bool _isFormVisible = false;

  String recipeName = '';

  String searchTerm = '';
  List<Ingredient> availableIngredients = [];
  List<Ingredient> selectedIngredients = [];
  bool hasSearched = false;

  double totalRecipeScore = 0;
  String totalRecipeScoreString = '';
  Color totalRecipeScoreColour = colourDefault;

  //API CALLS
  Future<void> fetchAvailableIngredients() async {
    final response = await http
        .get(Uri.parse('http://localhost:3000/products?search=$searchTerm'));

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON data
      final List<dynamic> responseData = json.decode(response.body);

      //This is one of the worst data processing functions I have ever written. Don't use this
      List<Ingredient> responseProducts = [];
      for (var response in responseData) {
        List<Packaging> tempPackageList = [];
        for (var package in response["packages"]) {
          var tempPackage = Packaging(
            package["ecoscoreMaterialScore"] ?? 0,
            package["material"] ?? "",
            parseWeight(package["weight_measured"]),
            package["numberOfUnits"] ?? "",
            package["nonRecyclableAndNonBiodegradable"] ?? "",
            package["recycling"] ?? "",
            package["shape"] ?? "",
          );
          tempPackageList.add(tempPackage);
        }
        var tempProduct = Ingredient(
          response["id"] ?? "",
          response["name"] ?? "",
          response["quantity"] ?? "",
          response["servingSize"] ?? "",
          response["warning"] ?? "",
          response["packagingScore"]?.toDouble() ?? 0.0,
          response["numberNonRecyclableAndNonBiodegradableMaterials"] ?? 0,
          response["imageUrl"] ?? "",
          tempPackageList,
        );
        responseProducts.add(tempProduct);
      }

      setState(() {
        availableIngredients = responseProducts;
      });
    } else {
      // If the server did not return a 200 OK response, handle the error
      throw Exception(
          'Failed to load data, status code: ${response.statusCode}');
    }
    hasSearched = true;
  }

  Future<void> submitRecipe() async {
    if (selectedIngredients.isEmpty) {
      return;
    }
    final List<Map<String, dynamic>> recipeData =
        selectedIngredients.map((ingredient) => ingredient.toJson()).toList();

    // Generate the current date
    DateTime currentDate = DateTime.now();

    // Convert the date to a string in a format suitable for your backend
    String formattedDate = currentDate.toIso8601String();

    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/submitRecipe'), // Replace with your backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'recipeName': recipeName,
        'totalRecipeScore': totalRecipeScore,
        'dateOfCreation': formattedDate,
        'ingredients': recipeData
      }),
    );
    if (response.statusCode == 200) {
      print('Recipe sent to backend successfully!');
      // Optionally, you can handle the response from the backend
    } else {
      print('Failed to send recipe, status code: ${response.statusCode}');
      // Handle the error
    }
  }

  //BUILDING FUNCTIONS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Creation'),
      ),
      body: _isFormVisible ? _buildForm() : _buildButton(),
    );
  }

  Widget _buildButton() {
    resetCreateRecipePage();
    return Container(
      height: MediaQuery.of(context)
          .size
          .height, // Set the height to the entire screen height
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/create_recipe_background_stock.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isFormVisible = true;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New Recipe', style: TextStyle(fontSize: 20)),
                  Icon(Icons.add, size: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 40, // Adjust the size as needed
                height: 40, // Adjust the size as needed
                decoration: BoxDecoration(
                  shape: BoxShape
                      .circle, // or BoxShape.rectangle for a rounded rectangle
                  color: Theme.of(context).primaryColor,
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isFormVisible = false;
                    });
                  },
                )),
            Row(
              children: [
                Text(
                  'Recipe Name:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(child: TextField(
                  onChanged: (value) {
                    setState(() {
                      recipeName = value;
                    });
                  },
                )),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            _buildIngredientSearch(),
            SizedBox(height: 16),
            _buildSelectedIngredients(),
            SizedBox(height: 16),
            // Total Waste Score & Done Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Total Waste Score: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('$totalRecipeScoreString($totalRecipeScore)',
                        style: TextStyle(
                            color: totalRecipeScoreColour, fontSize: 18)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isFormVisible = false;
                      submitRecipe();
                    });
                  },
                  child: Text('Done', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search ingredients...',
                ),
                onChanged: (value) {
                  setState(() {
                    searchTerm = value;
                    availableIngredients = [];
                  });
                },
              ),
            ),
            IconButton(
              onPressed: fetchAvailableIngredients,
              icon: Icon(Icons.search_rounded),
            )
          ]),
          SizedBox(
            height: 400, // Set the desired height for the list
            child: hasSearched
                ? availableIngredients.isEmpty
                    ? Center(
                        child: Text('No products found'),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: availableIngredients.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: EdgeInsets.all(
                                      0), // Remove default padding
                                  title: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      availableIngredients[index].imageUrl != ""
                                          ? _fetchImage(
                                              availableIngredients[index]
                                                  .imageUrl)
                                          : Placeholder(
                                              fallbackWidth: 50,
                                              fallbackHeight: 50,
                                            ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  8.0), // Adjust padding as needed
                                          child: Text(
                                            "${availableIngredients[index].name} (${availableIngredients[index].quantity})",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedIngredients
                                          .add(availableIngredients[index]);
                                      totalRecipeScore =
                                          calculateTotalRecipeScore(
                                              selectedIngredients);
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      )
                : Container(), // Empty container when searchTerm is empty
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedIngredients.map((ingredient) {
        return Row(
          children: [
            Text("${ingredient.name} - ${ingredient.quantity}"),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedIngredients.remove(ingredient);
                  totalRecipeScore =
                      calculateTotalRecipeScore(selectedIngredients);
                });
              },
              child: Text('X'),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _fetchImage(String url) {
    return Image.network(
      url,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          // If the image is fully loaded, return the Image widget
          return child;
        } else {
          // If the image is still loading, you can show a loading indicator
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        // If there's an error loading the image, you can display a placeholder or an error message
        return Placeholder(
          fallbackWidth: 50,
          fallbackHeight: 50,
        ); // Placeholder widget can be replaced with your custom error widget
      },
    );
  }

  //UTILITY FUNCTIONS
  double calculateTotalRecipeScore(List<Ingredient> ingredients) {
    if (ingredients.isEmpty) {
      totalRecipeScoreString = 'Okay';
      totalRecipeScoreColour = colourDefault;
      return 0;
    }

    double totalScore = 0;
    for (Ingredient ingredient in ingredients) {
      if (ingredient.warning != "packaging_data_missing") {
        totalScore += ingredient.packagingScore;
      }
    }

    double averageScore = totalScore / ingredients.length;
    averageScore = double.parse(averageScore.toStringAsFixed(2));
    if (averageScore < 0) {
      totalRecipeScoreString = 'Bad';
      totalRecipeScoreColour = colourBad;
    } else if (averageScore < 50) {
      totalRecipeScoreString = 'Okay';
      totalRecipeScoreColour = colourOkay;
    } else {
      totalRecipeScoreString = 'Good';
      totalRecipeScoreColour = colourGood;
    }

    return averageScore;
  }

  double parseWeight(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }

  void resetCreateRecipePage() {
    availableIngredients = [];
    selectedIngredients = [];
    hasSearched = false;
    recipeName = '';
    totalRecipeScore = 0;
    totalRecipeScoreString = '';
    totalRecipeScoreColour = colourDefault;
  }
}
