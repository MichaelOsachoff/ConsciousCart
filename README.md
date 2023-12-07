# ConsciousCart

## UN SDG(s)
SDG's: 12. Responsible Consumption and Production, 13. Climate Action

## Project idea 
An application that allows home cooks to track, measure, and compare waste created in the recipes that they cook

## Project background/Business Opportunity
There lacks an easy-to-use application for tracking and reducing a home cook’s waste based upon the recipes that they create.

## Vlogs
Vlog 1 - [https://youtu.be/d-cPDdV7aPg](https://youtu.be/d-cPDdV7aPg)


## Technical Documentation
Products are used from the Open Food Facts Project - [Link](https://world.openfoodfacts.org/)

It is free and open to use database under the Open Database License (OBDL) - [More information](https://wiki.openfoodfacts.org/Reusing_Open_Food_Facts_Data)

Products for this project are contained to only Canada and the United States instead of the full database set provided by Open Food Facts. This includes roughly 83760 canadian products within a MongoDB database, with a fetch and creation time of up 1.5 hours. The United States has about 612118 products, with estimates of 20 hours to create. See the dbFetch.js file for implementation of this process.

## Installation Requirements
Mongo, Node, Express, Mongoose, Cors, Flutter

## Install Guide

**Reliable installation has only been verified on Windows, and may require a different process on Linux and Mac. Windows installation shown below:**

First, ensure all of the required above components of the tech stack are downloaded.
1. [Install MongoDb](https://www.mongodb.com/try/download/community)
2. [Install NodeJS](https://nodejs.org/en/download/)
3. [Install Flutter](https://docs.flutter.dev/get-started/install/windows)

Clone this repo:

```$ git clone https://github.com/MichaelOsachoff/ConsciousCart.git```

Install the other necessary javascript packages:

```$ npm install```

```$ npm install cors```

```$ npm install mongoose```

```$ npm install express```

```$ npm install axios```

```$ npm install mongodb```

Run the program:
1. In one terminal run:

    ```$ mongod```

2. In another terminal under ConsciousCart\Source\backend, run:

    ```$ node dbFetch.js Canada```

3. Now in the same terminal, start the backend:

    ```$ node server.js```

4. Now in a third terminal, under ConsciousCart\Source\frontend\conscious_cart_ui, start the frontend:

    ```$ flutter run```

5. Note: the above command may create cache errors,in that case here is how to clear the cache:

    ```$ flutter pub cache clean```

    ```$ flutter clean```

    ```$ flutter pub get```

    ```$ flutter run```

6. You can now run and use the application, recipes can be created with searched products in the new recipe tab, previous recipes can be view in the history tab, and some basic user data can be viewed and edited in the profile tab.
