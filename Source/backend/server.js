const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const { productSchema } = require("./models/productSchema");
const { ingredientSchema } = require("./models/ingredientSchema");

const app = express();
const PORT = 3000; // You can use any available port

app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect("mongodb://localhost:27017/ConsciousCart", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

//Models
const Product = mongoose.model("Products", productSchema);
const Recipe = mongoose.model("Recipes", {
  recipeName: String,
  totalRecipeScore: Number,
  dateOfCreation: { type: Date, default: Date.now },
  ingredients: [ingredientSchema],
});

// API Endpoints
app.get("/products", async (req, res) => {
  try {
    const searchTerm = req.query.search;

    const products = await Product.find(
      {
        $or: [
          { abbreviated_product_name: { $regex: searchTerm, $options: "i" } },
          { _keywords: { $regex: searchTerm, $options: "i" } },
        ],
      },
      "product_name quantity serving_size ecoscore_data image_front_thumb_url"
    ).exec();
    const extractedProductsList = extractProductInformation(products);

    res.json(extractedProductsList);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/submitRecipe", async (req, res) => {
  try {
    const recipeData = req.body.ingredients;
    const totalRecipeScore = req.body.totalRecipeScore;
    const recipeName = req.body.recipeName;
    const dateOfCreation = req.body.dateOfCreation;
    const recipe = new Recipe({
      recipeName: recipeName,
      totalRecipeScore: totalRecipeScore,
      dateOfCreation: dateOfCreation,
      ingredients: recipeData,
    });
    await recipe.save();

    res.status(200).json({ message: "Recipe saved successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// GET endpoint to retrieve all recipes
app.get("/getRecipes", async (req, res) => {
  try {
    const recipes = await Recipe.find().exec();
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const User = mongoose.model("Users", {
  name: String,
  username: String,
  email: String,
  password: String,
});

app.get("/getUserData", async (req, res) => {
  try {
    const user = await User.findOne().exec();

    if (!user) {
      // No user found, return an empty response
      return res.status(200).json({});
    }

    res.json({
      name: user.name,
      username: user.username,
      email: user.email,
      password: user.password,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/updateUserData", async (req, res) => {
  try {
    const { name, username, email, password } = req.body;

    // Assuming there is only one user in the database
    const user = await User.findOne().exec();

    if (!user) {
      // No user found, create a new user
      const newUser = new User({ name, username, email, password });
      await newUser.save();
    } else {
      // Update existing user
      user.name = name;
      user.username = username;
      user.email = email;
      user.password = password;
      await user.save();
    }

    res.status(200).json({ message: "User data updated successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

function extractProduct(item, index, arr) {
  const extractedPackagesList = [];
  const packagings =
    item["_doc"]["ecoscore_data"]["adjustments"]["packaging"]["packagings"] ??
    [];

  packagings.forEach((package) => {
    var extractedPackage = {
      ecoscoreMaterialScore: package["ecoscore_material_score"],
      material: package["material"],
      weightMeasured: package["weight_measured"],
      numberOfUnits: String(package["number_of_units"]),
      nonRecyclableAndNonBiodegradable:
        package["non_recyclable_and_non_biodegradable"],
      recycling: package["recycling"],
      shape: package["shape"],
    };
    extractedPackagesList.push(extractedPackage);
  });

  const image_url = item["_doc"]["image_front_thumb_url"];

  const extractedProduct = {
    id: item["_id"],
    name: item["_doc"]["product_name"],
    quantity: item["_doc"]["quantity"],
    servingSize: item["_doc"]["serving_size"],
    warning:
      item["_doc"]["ecoscore_data"]["adjustments"]["packaging"]["warning"],
    packagingScore:
      item["_doc"]["ecoscore_data"]["adjustments"]["packaging"]["score"],
    numberNonRecyclableAndNonBiodegradableMaterials:
      item["_doc"]["ecoscore_data"]["adjustments"]["packaging"][
        "non_recyclable_and_non_biodegradable_materials"
      ],
    imageUrl: image_url ? item["_doc"]["image_front_thumb_url"].replace(
      "openfoodfacts.net",
      "openfoodfacts.org"
    ) : "",
    packages: extractedPackagesList,
  };
  return extractedProduct;
}

function extractProductInformation(products) {
  var extractedProductsList = [];
  products.forEach((product) => {
    extractedProductsList.push(extractProduct(product));
  });
  return extractedProductsList;
}
