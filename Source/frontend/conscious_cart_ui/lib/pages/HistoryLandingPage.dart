import 'package:conscious_cart_ui/models/Recipe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

const colourBad = Color(0xFFC20000);
const colourOkay = Color(0xFFC26E00);
const colourGood = Color(0xFF00C21D);

class HistoryLandingPage extends StatefulWidget {
  @override
  State<HistoryLandingPage> createState() => _HistoryLandingPageState();
}

class _HistoryLandingPageState extends State<HistoryLandingPage> {
  List<Recipe> recipes = [];
  bool hasFetched = false;
  int selectedRecipeIndex = -1;

  //API CALLS
  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getRecipes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        List<Recipe> fetchedRecipes = [];
        for (var recipeData in responseData) {
          // Assuming there's a constructor in your Recipe class that takes a Map
          Recipe recipe = Recipe.fromMap(recipeData);
          fetchedRecipes.add(recipe);
        }

        setState(() {
          recipes = fetchedRecipes;
        });
      } else {
        print('Failed to fetch recipes, status code: ${response.statusCode}');
        // Handle the error
      }
    } catch (error) {
      print('Error fetching recipes: $error');
      // Handle the error
    }
  }

  //BUILDING FUNCTIONS
  @override
  Widget build(BuildContext context) {
    if (selectedRecipeIndex == -1) {
      if (!hasFetched) {
        fetchRecipes();
        hasFetched = true;
      }
      return _buildRecipeSummaries();
    } else {
      return _buildRecipeDetails(selectedRecipeIndex);
    }
  }

  Widget _buildRecipeSummaries() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe History'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                // Score on the left
                Container(
                  margin: EdgeInsets.only(right: 16.0),
                  child: RichText(
                    text: TextSpan(
                      text: '', // Placeholder for the whole text
                      children: [
                        TextSpan(
                          text: '${recipe.totalRecipeScore}',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: getScoreColor(recipe.totalRecipeScore),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Name and Date in a column in the center
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${recipe.recipeName}',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${recipe.formattedDate}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
                // View button on the far-right side
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedRecipeIndex = index;
                    });
                  },
                  child: Text('View'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeDetails(int index) {
    final recipe = recipes[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, // Adjust the size as needed
                height: 40, // Adjust the size as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      fetchRecipes();
                      selectedRecipeIndex = -1;
                    });
                  },
                ),
              ),
              Row(
                children: [
                  Text('Name: ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(recipe.recipeName, style: TextStyle(fontSize: 20)),
                ],
              ),
              Row(
                children: [
                  Text('Date: ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(recipe.formattedDate, style: TextStyle(fontSize: 20)),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Ingredients:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
              SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true,
                itemCount: recipe.ingredients.length,
                itemBuilder: (context, i) {
                  final ingredient = recipe.ingredients[i];
                  final scrollController = ScrollController();
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${ingredient.packagingScore}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: getScoreColor(
                                        ingredient.packagingScore),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(ingredient.name),
                              ],
                            ),
                          ],
                        ),
                        children: <Widget>[
                          if (ingredient.warning == "packaging_data_missing")
                            TextField(
                              controller: TextEditingController(
                                  text:
                                      'No package data available for this ingredient.'),
                              readOnly: true,
                            )
                          else
                            ListTile(
                              title: Scrollbar(
                                controller: scrollController,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: scrollController,
                                  child: DataTable(
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          'Shape',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Material',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Recycling',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Impact',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                    rows: ingredient.packages.map((package) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(formatPackagingString(
                                              package.shape))),
                                          DataCell(Text(formatPackagingString(
                                              package.material))),
                                          DataCell(Text(formatPackagingString(
                                              package.recycling))),
                                          DataCell(
                                              formatImpactfromMaterialScore(
                                                  package.ecoscoreMaterialScore
                                                      .toDouble())),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Total Waste Score: ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                      '${getScoreString(recipe.totalRecipeScore)}(${recipe.totalRecipeScore})',
                      style: TextStyle(
                          fontSize: 20,
                          color: getScoreColor(recipe.totalRecipeScore))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //UTILITY FUNCTIONS
  Color getScoreColor(double score) {
    if (score < 0) {
      return colourBad;
    } else if (score < 50) {
      return colourOkay;
    } else {
      return colourGood;
    }
  }

  String getScoreString(double score) {
    if (score < 0) {
      return 'Bad';
    } else if (score < 50) {
      return 'Okay';
    } else {
      return 'Good';
    }
  }

  String formatPackagingString(String input) {
    // Split the input string using ':'
    List<String> parts = input.split(':');

    // Extract the second part and replace '-' with ' '
    String processedString =
        parts.length > 1 ? parts[1].replaceAll('-', ' ') : input;

    // Capitalize the first letter of each word
    processedString = processedString.replaceAllMapped(
        RegExp(r'(?:^|\s)\S'), (match) => match.group(0)!.toUpperCase());

    return processedString;
  }

  Text formatImpactfromMaterialScore(double score) {
    if (score <= 50) {
      return Text('High', style: TextStyle(color: colourBad));
    }
    return Text('Low', style: TextStyle(color: colourGood));
  }
}
