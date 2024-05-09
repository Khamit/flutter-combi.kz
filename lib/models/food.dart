import 'package:combi/models/rating_manager.dart';

class Food {
  final String name;
  final String restaurantName;
  final String restaurantUid; // Add restaurantUid property
  final String description;
  final String imagePath;

  final FoodCategory category;
  final int price;
  int popularity;
  final bool favorites;

  List<Addon> availableAddons;

  Food({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.availableAddons,
    required this.restaurantName,
    required this.restaurantUid, // Initialize restaurantUid when creating Food objects
    this.popularity = 0,
    this.favorites = false,
    required this.category,
  });

  // Method to update popularity based on user rating
  void updatePopularity(
      int rating, int foodWeight, int restaurantWeight, int positionIndex) {
    // Calculate the new popularity score
    popularity = RatingManager.calculatePopularity(
      popularity,
      rating,
      foodWeight,
      restaurantWeight,
      positionIndex,
    );
  }

  // Method to toggle favorites
  Food toggleFavorite() {
    return Food(
      name: name,
      restaurantName: restaurantName,
      restaurantUid:
          restaurantUid, // Handle null value by providing a default value
      description: description,
      imagePath: imagePath,
      category: category,
      price: price,
      popularity: popularity,
      availableAddons: availableAddons,
      favorites: !favorites, // Toggle the value
    );
  }
}

enum FoodCategory {
  combo,
  doner,
  pizza,
  chicken,
}

class Addon {
  String name;
  int price;

  Addon({
    required this.name,
    required this.price,
  });
}
