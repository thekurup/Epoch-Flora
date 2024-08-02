import 'package:flutter/foundation.dart';

class Plant {
  final int id;
  final String name;
  final String category;
  final double price;

  Plant({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });
}

class PlantStore with ChangeNotifier {
  List<Plant> _plants = [
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

  List<Plant> getPlantsByCategory(String category) {
    return _plants.where((plant) => plant.category == category).toList();
  }

  Plant getPlantByIndex(int index) {
    return _plants[index % _plants.length];
  }

  String getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'Indoor Plants';
      case 1:
        return 'Outdoor Plants';
      case 2:
        return 'Flowering Plants';
      default:
        return 'Indoor Plants';
    }
  }
}