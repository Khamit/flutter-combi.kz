import 'package:combi/models/food.dart';

class FavoriteItem {
  final Food food;

  List<Addon> selectedAddons;
  final int quantity; // Provide a default value for quantity

  FavoriteItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1, // Default value is 1
  });

  int get totalPrice {
    int addonsPrice = selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (food.price + addonsPrice) * quantity;
  }
}
