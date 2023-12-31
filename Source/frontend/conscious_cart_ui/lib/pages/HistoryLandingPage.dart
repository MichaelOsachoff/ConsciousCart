import 'package:conscious_cart_ui/models/Recipe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // API CALLS
  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getRecipes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        List<Recipe> fetchedRecipes = [];
        for (var recipeData in responseData) {
          Recipe recipe = Recipe.fromMap(recipeData);
          fetchedRecipes.add(recipe);
        }

        setState(() {
          recipes = fetchedRecipes;
        });
      } else {
        print('Failed to fetch recipes, status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }
  }

  // BUILDING FUNCTIONS
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/history_background_stock.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                color:
                    Colors.white.withOpacity(0.8), // Adjust opacity as needed
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
                width: 40,
                height: 40,
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
              RichText(
                  text: TextSpan(
                      text: 'Name: ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                      text: recipe.recipeName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ])),
              RichText(
                  text: TextSpan(
                      text: 'Date: ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                      text: recipe.formattedDate,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ])),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No package data available for this ingredient.',
                                  style: TextStyle(
                                      fontSize:
                                          16), // Adjust the font size as needed
                                ),
                                SizedBox(
                                    height:
                                        4), // Add some space between the text and the link
                                RichText(
                                  text: TextSpan(
                                    text:
                                        'If you have information regarding the packaging, you can add it on ',
                                    style: TextStyle(
                                      fontSize:
                                          16, // Set the font size for the entire RichText
                                      color: Colors
                                          .black, // Set the color of the non-link text
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'OpenFoodFacts',
                                        style: TextStyle(
                                          color: Colors.blue, // Set link color
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // Add the URL you want to open
                                            _launchUrl(
                                                'https://world.openfoodfacts.org/help-complete-products');
                                          },
                                      ),
                                    ],
                                  ),
                                )
                              ],
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
              RichText(
                  text: TextSpan(
                      text: 'Total Waste Score: ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getScoreString(recipe.totalRecipeScore)}(${recipe.totalRecipeScore})',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: getScoreColor(recipe.totalRecipeScore)),
                    ),
                  ])),
            ],
          ),
        ),
      ),
    );
  }

  // UTILITY FUNCTIONS
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
    List<String> parts = input.split(':');
    String processedString =
        parts.length > 1 ? parts[1].replaceAll('-', ' ') : input;
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

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
