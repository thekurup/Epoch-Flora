// Import the foundation library from Flutter, which provides basic classes like ChangeNotifier
import 'package:flutter/foundation.dart';

// Define a Plant class to represent individual plants in the store
class Plant {
  // Unique identifier for each plant
  final int id;
  // Name of the plant
  final String name;
  // Category the plant belongs to (e.g., Indoor, Outdoor, Flowering)
  final String category;
  // Price of the plant
  final double price;

  // Constructor for creating a Plant object
  // The 'required' keyword ensures that all these fields must be provided when creating a Plant
  Plant({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });
}

// PlantStore class to manage the collection of plants
// 'with ChangeNotifier' allows this class to notify listeners when data changes
class PlantStore with ChangeNotifier {
  // Private list of Plant objects representing the store's inventory
  List<Plant> _plants = [
    // Each line creates a new Plant object with specific details
    Plant(id: 1, name: 'Fern', category: 'Indoor Plants', price: 500),
    Plant(id: 2, name: 'Palm Tree', category: 'Indoor Plants', price: 900),
    Plant(id: 3, name: 'Peace Lilly', category: 'Indoor Plants', price: 550),
    Plant(id: 4, name: 'Rubber Fig', category: 'Indoor Plants', price: 750),
    Plant(id: 5, name: 'Monstera', category: 'Indoor Plants', price: 800),
    Plant(id: 6, name: 'Peperomia', category: 'Indoor Plants', price: 600),
    Plant(id: 7, name: 'AloeVera', category: 'Outdoor Plants', price: 600),
    Plant(id: 8, name: 'GrassPot', category: 'Outdoor Plants', price: 550),
    Plant(id: 9, name: 'Crocous', category: 'Flowering Plants', price: 450),
    Plant(id: 10, name: 'Daisy Flower', category: 'Flowering Plants', price: 400),
  ];

  // Method to get plants by category
  List<Plant> getPlantsByCategory(String category) {
    // Use the 'where' method to filter plants based on the given category
    // 'toList()' converts the result back to a list
    return _plants.where((plant) => plant.category == category).toList();
  }

  // Method to get a plant by its index
  Plant getPlantByIndex(int index) {
    // Use the modulo operator to ensure the index wraps around if it's out of bounds
    return _plants[index % _plants.length];
  }

  // Method to get the category name based on an index
  String getCategoryName(int index) {
    // Use a switch statement to return the appropriate category name
    switch (index) {
      case 0:
        return 'Indoor Plants';
      case 1:
        return 'Outdoor Plants';
      case 2:
        return 'Flowering Plants';
      default:
        // If an unknown index is provided, default to 'Indoor Plants'
        return 'Indoor Plants';
    }
  }
}