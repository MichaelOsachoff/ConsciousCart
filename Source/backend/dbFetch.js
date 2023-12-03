const axios = require("axios");
const { MongoClient } = require("mongodb");

const openFoodFactsBaseURL = "https://world.openfoodfacts.org/api/v2/search";
const mongoURI = "mongodb://localhost:27017/ConsciousCart";

const validCountries = ["canada", "united-states", "another-country"]; // Add more countries as needed

const PAGES_TO_SHOW_PROGRESS = 10;

async function fetchAndStoreData(country) {
  if (!validCountries.includes(country)) {
    console.error("Invalid country. Please provide a valid country.");
    return;
  }

  const client = new MongoClient(mongoURI, { useUnifiedTopology: true });

  try {
    await client.connect();
    const database = client.db("ConsciousCart");
    const collection = database.collection("products");

    let page = 1;
    let pageSize = 0;
    let totalProductsCount = 0;
    let startTime = new Date();

    // Fetch data from the first page to get the total number of products
    const firstPageResponse = await axios.get(
      `${openFoodFactsBaseURL}?countries_tags_en=${country}&page=${page}`
    );
    const { page_size, count } = firstPageResponse.data;
    pageSize = page_size;
    totalProductsCount = count;
    const totalPages = Math.ceil(totalProductsCount / pageSize);

    console.log(
      `Total number of products for ${country}: ${totalProductsCount}\n`
    );

    do {
      const response = await axios.get(
        `${openFoodFactsBaseURL}?countries_tags_en=${country}&page=${page}`
      );
      const { products, page_size } = response.data;
      pageSize = page_size;

      if (page % PAGES_TO_SHOW_PROGRESS === 0 || page === totalPages) {
        // Calculate elapsed time and provide time estimate after every 50 pages or on the last page
        const elapsedTime = (new Date() - startTime) / 1000 / 60; // Convert milliseconds to minutes
        const elapsedTimeMinutesInteger = parseInt(elapsedTime, 10);
        const estimatedTime = parseInt(elapsedTime * (totalPages / page), 10);

        // ANSI escape codes for moving cursor up one line and clearing the line
        const clearLine = "\x1b[1A\x1b[2K";

        console.log(
          `${clearLine}Estimated time remaining: ${
            estimatedTime - elapsedTimeMinutesInteger
          } minutes (Page ${page}/${totalPages})`
        );
      }

      if (products && products.length > 0) {
        // Check for existing products in the collection
        const existingProductIds = await collection.distinct("_id");
        const newProducts = products.filter(
          (product) => !existingProductIds.includes(product._id)
        );

        // Insert new products into MongoDB
        if (newProducts.length > 0) {
          await collection.insertMany(newProducts, { ordered: false });
        }
      }

      page++;
    } while (page <= totalPages);

    console.log(`Data inserted into MongoDB for ${country}.`);
  } catch (error) {
    console.error("Error:", error);
  } finally {
    client.close();
  }
}

// Get the country argument from the command line
const country = process.argv[2];

if (!country) {
  console.error("Please provide a country as a command-line argument.");
} else {
  fetchAndStoreData(country.toLowerCase()); // Convert to lowercase for case-insensitivity
}
