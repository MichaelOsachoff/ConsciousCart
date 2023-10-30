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

Products for this project are contained to only Canada instead of the full database set provided by Open Food Facts. This includes roughly 83760 products within a MongoDB database, with a fetch and creation time of up to an hour. See the dbFetch.js file for implementation of this process.

## Installation Requirements
Mongo, Node, Express, Mongoose, Cors