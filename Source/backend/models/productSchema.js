const mongoose = require("mongoose");

// MongoDB Schema
const productSchema = new mongoose.Schema({
  _id: String,
  _keywords: [String],
  abbreviated_product_name: String,
  brands: String,
  brands_tags: [String],
  // Other fields as per your requirement
});
exports.productSchema = productSchema;
