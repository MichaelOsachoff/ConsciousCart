const mongoose = require("mongoose");

// Define the ingredient schema
const ingredientSchema = new mongoose.Schema({
  // Include the fields you want for ingredients
  id: String,
  name: String,
  quantity: String,
  servingSize: String,
  warning: String,
  packagingScore: Number,
  numberNonRecyclableAndNonBiodegradableMaterials: Number,
  packages: [
    {
      ecoscoreMaterialScore: Number,
      material: String,
      weightMeasured: Number,
      numberOfUnits: String,
      nonRecyclableAndNonBiodegradable: String,
      recycling: String,
      shape: String,
    },
  ],
});
exports.ingredientSchema = ingredientSchema;
