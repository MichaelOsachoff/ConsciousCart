const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
const PORT = 3000; // You can use any available port

app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect("mongodb://localhost:27017/ConsciousCart", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// MongoDB Schema
const productSchema = new mongoose.Schema({
  _id: String,
  _keywords: [String],
  abbreviated_product_name: String,
  brands: String,
  brands_tags: [String],
  // Other fields as per your requirement
});

const Product = mongoose.model("Products", productSchema);

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
      "product_name quantity serving_size ecoscore_data"
    ).exec();
    const extractedProductsList = extractProductInformation(products);

    res.json(extractedProductsList);
  } catch (error) {
    res.status(500).json({ error: error.message });
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
    };
    extractedPackagesList.push(extractedPackage);
  });

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
