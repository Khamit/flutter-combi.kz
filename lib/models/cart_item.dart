import 'package:combi/models/food.dart';

class CartItem {
  Food food;
  
  List<Addon> selectedAddons;
  int quantity;

  CartItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1,
    });

    int get totalPrice {
      int addonsPrice = selectedAddons.fold(0, (sum, addon) => sum + addon.price);
      return (food.price + addonsPrice) * quantity;
    }

}