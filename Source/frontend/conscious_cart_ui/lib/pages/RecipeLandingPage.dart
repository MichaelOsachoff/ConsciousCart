import 'package:conscious_cart_ui/models/Packaging.dart';
import 'package:conscious_cart_ui/models/Product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeLandingPage extends StatefulWidget {
  @override
  _RecipeLandingPageState createState() => _RecipeLandingPageState();
}

class _RecipeLandingPageState extends State<RecipeLandingPage> {
  bool _isFormVisible = false;
  List<Product> availableIngredients = [];

  List<Product> selectedIngredients = [];
  String searchTerm = '';

  Future<void> fetchAvailableIngredients() async {
    final response = await http
        .get(Uri.parse('http://localhost:3000/products?search=$searchTerm'));

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON data
      final List<dynamic> responseData = json.decode(response.body);

      //This is one of the worst data processing functions I have ever written. Don't use this
      List<Product> responseProducts = [];
      for (var response in responseData) {
        List<Packaging> tempPackageList = [];
        for (var package in response["packages"]) {
          var tempPackage = Packaging(
            package["ecoscoreMaterialScore"] ?? 0,
            package["material"] ?? "",
            package["weightMeasured"] ?? 0,
            package["numberOfUnits"] ?? "",
            package["nonRecyclableAndNonBiodegradable"] ?? "",
            package["recycling"] ?? "",
          );
          tempPackageList.add(tempPackage);
        }
        double packagingScore;
        if (response["packagingScore"] == null) {
          packagingScore = 0.0;
        } else {
          packagingScore = response["packagingScore"].toDouble();
        }
        var tempProduct = Product(
          response["id"] ?? "",
          response["name"] ?? "",
          response["quantity"] ?? "",
          response["servingSize"] ?? "",
          response["warning"] ?? "",
          packagingScore,
          response["numberNonRecyclableAndNonBiodegradableMaterials"] ?? 0,
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
  }

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
    return Center(
      child: ElevatedButton(
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
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildIngredientSearch(),
          SizedBox(height: 16),
          _buildSelectedIngredients(),
          SizedBox(height: 16),
          // Total Waste Score & Done Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Waste Score: 0'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isFormVisible = false;
                  });
                },
                child: Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientSearch() {
    return Column(
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
              });
            },
          )),
          IconButton(
              onPressed: fetchAvailableIngredients,
              icon: Icon(Icons.search_rounded))
        ]),
        SizedBox(
          height: 200, // Set the desired height for the list
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableIngredients.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Name:${availableIngredients[index].name} - Quantity:${availableIngredients[index].quantity}"),
                onTap: () {
                  setState(() {
                    selectedIngredients.add(availableIngredients[index]);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedIngredients.map((ingredient) {
        return Row(
          children: [
            Text(ingredient.name),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedIngredients.remove(ingredient);
                });
              },
              child: Text('X'),
            ),
          ],
        );
      }).toList(),
    );
  }
}
