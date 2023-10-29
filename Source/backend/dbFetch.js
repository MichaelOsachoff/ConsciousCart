const axios = require('axios');
const { MongoClient } = require('mongodb');

const country = 'canada';
const openFoodFactsBaseURL = 'https://world.openfoodfacts.net/api/v2/search';
const mongoURI = 'mongodb://localhost:27017/tempdb';

async function fetchAndStoreData() {
  const client = new MongoClient(mongoURI, { useUnifiedTopology: true });

  try {
    await client.connect();
    const database = client.db('tempdb');
    const collection = database.collection('Products');

    let page = 1;
    let pageSize = 0;
    let totalProductsCount = 0;
    let totalPages = 0;

    do {
      const response = await axios.get(`${openFoodFactsBaseURL}?countries_tags_en=${country}&page=${page}`);
      const { products, count, page_size } = response.data;
      pageSize = page_size;

      if (page === 1) {
        totalProductsCount = count;
        console.log(`Total number of products: ${totalProductsCount}`);
        totalPages = Math.ceil(totalProductsCount / pageSize);
      }

      console.log(`Processing page ${page}/${totalPages}`);

      if (products && products.length > 0) {
        // Insert products into MongoDB
        await collection.insertMany(products);
      }

      page++;
    } while (page <= totalPages);

    console.log('Data inserted into MongoDB.');
  } catch (error) {
    console.error('Error:', error);
  } finally {
    client.close();
  }
}

fetchAndStoreData();
