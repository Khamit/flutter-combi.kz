// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:combi/models/cart_item.dart';
import 'package:combi/models/favorite_item.dart';
import 'package:combi/models/rating_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'food.dart';

class Restaurant extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth;

  final List<Food> _menu = [];
  final String name;
  int popularity;
  final List<Food> _favoriteItems = []; // Add list of favorite foods

  Restaurant({
    required this.name,
    this.popularity = 0,
    required FirebaseAuth auth, // Pass FirebaseAuth instance as a parameter
  }) : _auth = auth {
    _loadMenu();
  }

  // Load menu from Firestore
  Future<void> _loadMenu() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('foods').get();
      List<Food> loadedMenu =
          querySnapshot.docs.map((doc) => _foodFromSnapshot(doc)).toList();
      _menu.addAll(loadedMenu);
      notifyListeners();

      // Check if the user is authenticated
      if (_auth.currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection("Users")
            .doc(_auth.currentUser!.uid)
            .get();
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>? ?? {};
        String? userName = userData['name'];
        String? userPhoneNumber = userData['phoneNumber'];
        String? restaurantUid = userData['restaurantUid'];
        // Update SharedPreferences with user's name and phone number if available
        if (userName != null &&
            userPhoneNumber != null &&
            restaurantUid != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', userName);
          await prefs.setString('phoneNumber', userPhoneNumber);
          await prefs.setString('restaurantUid', restaurantUid);
        }
      }
    } catch (e) {
      print('Error loading menu: $e');
    }
  }

// Getter for favorite items
  List<FavoriteItem> get favoriteItems {
    // Convert favorite foods to FavoriteItem objects with selected addons
    return _favoriteItems
        .map((food) => FavoriteItem(food: food, selectedAddons: []))
        .toList();
  }

  void updatePopularity(int rating, int restaurantWeight) {
    // Calculate the new popularity score
    popularity = RatingManager.calculatePopularity(
      popularity,
      rating,
      0, // Placeholder for food weight, as it's not provided in this method
      restaurantWeight,
      0, // Placeholder for position index, as it's not provided in this method
    );
  }

  Food _foodFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    String categoryString = data['category'] ?? '';
    FoodCategory category =
        _getFoodCategory(categoryString); // Convert string to enum
    return Food(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      price: (data['price'] ?? 0).toInt(), // Convert double to int
      category: category,
      availableAddons: _addonsFromMapList(data['availableAddons'] ?? []),
      restaurantName: data['restaurantName'] ?? '',
      restaurantUid: data['restaurantUid'] ?? '', // Initialize restaurantUid
      popularity: (data['popularity'] ?? 0).toInt(), // Convert double to int
      favorites: data['favorites'] ?? false,
    );
  }

// Helper method to convert string to FoodCategory enum
  FoodCategory _getFoodCategory(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'combo':
        return FoodCategory.combo;
      case 'doner':
        return FoodCategory.doner;
      case 'pizza':
        return FoodCategory.pizza;
      case 'chicken':
        return FoodCategory.chicken;
      default:
        return FoodCategory.combo; // Default to combo if category is unknown
    }
  }

  // Helper method to convert list of maps to list of Addon objects
  List<Addon> _addonsFromMapList(List<dynamic> mapList) {
    return mapList
        .map((addon) => Addon(
              name: addon['name'] ?? '',
              price: addon['price'] ?? 0,
            ))
        .toList();
  }

  // user cart - real quic))
  final List<CartItem> _cart = [];

  // delivery address (can update/change)
  String _deliveryAddress = 'город: Актобе';

  // G E T T E R S
  List<Food> get menu => _menu;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;

  // O P E R A T I O N S
  // add to cart
  void addToCart(Food food, List<Addon> selectedAddons) {
    // see if there is a cart item already with the same food and selected addons
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      // check if the food items are the same
      bool isSameFood = item.food == food;

      // check if the List of selected addons are the same
      bool isSameAddons =
          const ListEquality().equals(item.selectedAddons, selectedAddons);

      return isSameFood && isSameAddons;
    });
    // if item already exist, increase it`s quantity
    if (cartItem != null) {
      cartItem.quantity++;
    }
    // otherwise, add a new cart item to the cart
    else {
      _cart.add(
        CartItem(
          food: food,
          selectedAddons: selectedAddons,
        ),
      );
    }
    notifyListeners();
  }

// add to favorites
  void addToFavorites(Food food, List<Addon> selectedAddons) {
    // Check if the food with the same addons already exists in favorites
    FavoriteItem? existingFavorite = _favoriteItems
        .map((food) => FavoriteItem(food: food, selectedAddons: []))
        .firstWhereOrNull((favoriteItem) {
      // Check if the food items are the same
      bool isSameFood = favoriteItem.food == food;

      // Check if the list of selected addons are the same
      bool isSameAddons = const ListEquality()
          .equals(favoriteItem.selectedAddons, selectedAddons);

      return isSameFood && isSameAddons;
    });

    // If the item already exists, do nothing
    if (existingFavorite != null) {
      return;
    }

    // Otherwise, add a new favorite item to the favorites list
    _favoriteItems.add(food);

    // Toggle favorite status
    food.toggleFavorite();

    // Notify listeners
    notifyListeners();
  }

  // remove from cart
  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);

    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

// Remove from favorites
  void removeFromFavorites(Food food) {
    int favoriteIndex = _favoriteItems.indexOf(food);

    if (favoriteIndex != -1) {
      _favoriteItems.removeAt(favoriteIndex);
    }

    // Toggle favorite status
    food.toggleFavorite();

    notifyListeners();
  }

  // get total price
  int getTotalPrice() {
    int total = 0;

    for (CartItem cartItem in _cart) {
      int itemTotal = cartItem.food.price;

      for (Addon addon in cartItem.selectedAddons) {
        itemTotal += addon.price;
      }
      total += itemTotal * cartItem.quantity;
    }
    return total;
  }

  // get total number of items in cart
  int getTotalItemCount() {
    int totalItemCount = 0;

    for (CartItem cartItem in _cart) {
      totalItemCount += cartItem.quantity;
    }
    return totalItemCount;
  }

  // clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // clear favorites
  void clearFavorites() {
    _cart.clear();
    notifyListeners();
  }

  // update delivery address
  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }

  // H E L P E R S
  // Update displayCartReceipt method
  Future<String> displayCartReceipt() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final receipt = StringBuffer();
      receipt.writeln("Статус оплаты: "); //$paymentStatus
      // Format the date to include up to seconds only
      String formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Append the formatted date to the receipt
      receipt.writeln("Дата: $formattedDate");
      receipt.writeln();
      receipt.writeln(
          "Restaurant Name: ${_menu.isNotEmpty ? _menu.first.restaurantName : 'Unknown'}"); // Fetch restaurantName from any item in the menu
      // receipt.writeln(
      //     "Restaurant Uid: ${_menu.isNotEmpty ? _menu.first.restaurantUid : 'Unknown'}"); // Fetch restaurantUid from any item in the menu
      receipt.writeln(
          "<<-------------------------------------------------------------------------------------------->>");

      // Add cart items details
      for (final cartItem in _cart) {
        receipt.writeln(
            "${cartItem.quantity} x ${cartItem.food.name} - ${_formatPrice(cartItem.food.price)}");

        if (cartItem.selectedAddons.isNotEmpty) {
          receipt.writeln(
              "      Дополнения: ${_formatAddons(cartItem.selectedAddons)}");
        }
        receipt.writeln();
      }

      // Add total items and total price
      receipt.writeln(
          "<<-------------------------------------------------------------------------------------------->>");
      receipt.writeln();
      receipt.writeln("Общее количество: ${getTotalItemCount()}");
      receipt.writeln("Общая сумма: ${_formatPrice(getTotalPrice())}");
      receipt.writeln(
          "<<-------------------------------------------------------------------------------------------->>");
      receipt.writeln("Доставка по адресу: $deliveryAddress");

      // Add saved name and phone number to the receipt
      receipt.writeln();
      receipt.writeln("Имя: ${prefs.getString('name') ?? 'Unknown'}");
      receipt.writeln(
          "Номер телефона: ${prefs.getString('phoneNumber') ?? 'Unknown'}");

      return receipt.toString();
    } catch (e) {
      print('Error displaying cart receipt: $e');
      return "Ошибка при отображении квитанции.";
    }
  }

  // format double/int value into money
  String _formatPrice(int price) {
    return '${price.toStringAsFixed(2)}₸';
  }

// format list of addons into a string summary
  String _formatAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }

  Restaurant copyWith({
    String? name,
    int? popularity,
  }) {
    return Restaurant(
      name: name ?? this.name,
      popularity: popularity ?? this.popularity,
      auth: FirebaseAuth.instance,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'popularity': popularity,
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      name: map['name'] as String,
      popularity: map['popularity'] as int,
      auth: FirebaseAuth.instance,
    );
  }

  String toJson() => json.encode(toMap());

  factory Restaurant.fromJson(String source) =>
      Restaurant.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Restaurant(name: $name, popularity: $popularity)';

  @override
  bool operator ==(covariant Restaurant other) {
    if (identical(this, other)) return true;

    return other.name == name && other.popularity == popularity;
  }

  @override
  int get hashCode => name.hashCode ^ popularity.hashCode;
}
