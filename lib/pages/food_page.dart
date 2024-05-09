import 'package:carbon_icons/carbon_icons.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food.dart';

// ignore: must_be_immutable
class FoodPage extends StatefulWidget {
  Food food; // Marked as final
  final Map<Addon, bool> selectedAddons = {};
  final Function(Food) onAddToCart;
  final Function(Food) onAddToFavorites;

  FoodPage({
    Key? key,
    required this.food,
    required this.onAddToCart,
    required this.onAddToFavorites,
  }) {
    // Initialize selected addons to be false
    for (Addon addon in food.availableAddons) {
      selectedAddons[addon] = false;
    }
  }

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  // Method to add the selected food item to the cart
  void addToCart(Food food, Map<Addon, bool> selectedAddons) {
    // Close the FoodPage and go back to the menu
    Navigator.pop(context);

    // Format the selected addons
    List<Addon> currentlySelectedAddons = [];
    for (Addon addon in widget.food.availableAddons) {
      if (widget.selectedAddons[addon] == true) {
        currentlySelectedAddons.add(addon);
      }
    }

    // Add the food item to the cart
    context.read<Restaurant>().addToCart(food, currentlySelectedAddons);

    // Call the callback function to notify the parent widget (HomePage)
    widget.onAddToCart(food);
  }

  void addToFavorite(Food food, Map<Addon, bool> selectedAddons) {
    // Format the selected addons
    List<Addon> currentlySelectedAddons = [];
    for (Addon addon in food.availableAddons) {
      if (selectedAddons[addon] == true) {
        currentlySelectedAddons.add(addon);
      }
    }

    // Add the food item to the favorites
    context.read<Restaurant>().addToFavorites(food, currentlySelectedAddons);
  }

  void _toggleFavorite() {
    setState(() {
      // Toggle the favorite status of the food item
      if (!widget.food.favorites) {
        addToFavorite(widget.food, widget.selectedAddons);
      } else {
        // Remove from favorites if already added
        // You need to implement the removeFromFavorites method in your Restaurant class
        context.read<Restaurant>().removeFromFavorites(widget.food);
      }

      // Update the icon color based on the favorite status
      widget.food = widget.food.toggleFavorite();
      // Call the callback function to notify the parent widget (FavoritesPage)
      widget.onAddToFavorites(widget.food);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 600;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: isLargeScreen
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                // Display image and details for large screens
                if (isLargeScreen)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Food Image with Stack
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 400,
                              height: 400,
                              child: widget.food.imagePath.isNotEmpty &&
                                      widget.food.imagePath.startsWith('http')
                                  ? Image.network(
                                      widget.food.imagePath,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      widget.food
                                          .imagePath, // Placeholder image path
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            // ===============================================================================
                            top: 240,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withOpacity(0.7), // White background color
                              ),
                              child: IconButton(
                                icon: Icon(
                                    widget.food.favorites
                                        ? CarbonIcons.favorite_filled
                                        : CarbonIcons.favorite,
                                    color: widget.food.favorites
                                        ? Colors.red
                                        : Colors
                                            .red // Red when favorite, grey when not
                                    ),
                                onPressed: _toggleFavorite,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 50, right: 50, left: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.food.name, // FOOD NAME
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                  color: Color.fromARGB(255, 180, 96, 96),
                                ),
                              ),
                              Text(
                                '${widget.food.price}₸',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                widget.food.description,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 32),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Ресторан: ${widget.food.restaurantName}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Divider(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              const SizedBox(height: 15),
                              Text(
                                "Add-ons",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  physics:
                                      NeverScrollableScrollPhysics(), // Add this line
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: widget.food.availableAddons.length,
                                  itemBuilder: (context, index) {
                                    Addon addon =
                                        widget.food.availableAddons[index];
                                    return CheckboxListTile(
                                      title: Text(
                                        addon.name,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${addon.price}₸',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      value: widget.selectedAddons[addon],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          widget.selectedAddons[addon] = value!;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
// Display image and details for small screens
                if (!isLargeScreen)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Food Image with Stack
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: widget.food.imagePath.isNotEmpty &&
                                      widget.food.imagePath.startsWith('http')
                                  ? Image.network(
                                      widget.food.imagePath,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      widget.food
                                          .imagePath, // Placeholder image path
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            // ===============================================================================
                            top: 240,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withOpacity(0.7), // White background color
                              ),
                              child: IconButton(
                                icon: Icon(
                                    widget.food.favorites
                                        ? CarbonIcons.favorite_filled
                                        : CarbonIcons.favorite,
                                    color: widget.food.favorites
                                        ? Colors.red
                                        : Colors
                                            .red // Red when favorite, grey when not
                                    ),
                                onPressed: _toggleFavorite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

// Text details (common for both large and small screens)
                if (!isLargeScreen)
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.food.name, // FOOD NAME
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isLargeScreen ? 48 : 42,
                            color: Color.fromARGB(255, 180, 96, 96),
                          ),
                        ),
                        Text(
                          '${widget.food.price} ₸',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.food.description,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: isLargeScreen ? 32 : 18),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Ресторан: ${widget.food.restaurantName}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: isLargeScreen ? 24 : 22,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Divider(color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(height: 15),
                        Text(
                          "Add-ons",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            physics:
                                NeverScrollableScrollPhysics(), // Add this line
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: widget.food.availableAddons.length,
                            itemBuilder: (context, index) {
                              Addon addon = widget.food.availableAddons[index];
                              return CheckboxListTile(
                                title: Text(
                                  addon.name,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${addon.price}₸',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                value: widget.selectedAddons[addon],
                                onChanged: (bool? value) {
                                  setState(() {
                                    widget.selectedAddons[addon] = value!;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment:
                      isLargeScreen ? Alignment.centerRight : Alignment.center,
                  child: SizedBox(
                    height: 90,
                    width: 600,
                    child: MyButton(
                      text: "Add to cart",
                      onTap: () =>
                          addToCart(widget.food, widget.selectedAddons),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CarbonIcons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
