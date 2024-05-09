import 'package:combi/components/my_quantity_selector.dart';
import 'package:combi/models/favorite_item.dart';
import 'package:combi/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyFavoriteTile extends StatelessWidget {
  final FavoriteItem favoriteItem;

  const MyFavoriteTile({
    Key? key,
    required this.favoriteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant?>(
      builder: (context, restaurant, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isLargeScreen = constraints.maxWidth > 600;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: favoriteItem.food.imagePath.isNotEmpty &&
                                  favoriteItem.food.imagePath.startsWith('http')
                              ? Image.network(
                                  favoriteItem.food.imagePath,
                                  height: 150,
                                  width: 150,
                                  filterQuality: FilterQuality.low,
                                )
                              : Image.asset(
                                  favoriteItem.food
                                      .imagePath, // Provide the default image path here
                                  height: 150,
                                  width: 150,
                                  filterQuality: FilterQuality.low,
                                ),
                        ),
                        const SizedBox(width: 15),
                        // Name, Price, and Quantity Selector
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              // Food Name
                              Text(
                                favoriteItem.food.name,
                                style: GoogleFonts.rubik(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 28 : 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Food Price
                              Text(
                                '${favoriteItem.food.price}₸',
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 20 : 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Quantity Selector
                              QuantitySelector(
                                quantity: favoriteItem.quantity,
                                food: favoriteItem.food,
                                onDecrement: () {
                                  restaurant?.removeFromFavorites(favoriteItem
                                      .food); // Adjusted method call
                                },
                                onIncrement: () {
                                  restaurant?.addToCart(
                                    // Assuming addToCart adds to cart from favorites
                                    favoriteItem.food,
                                    favoriteItem.selectedAddons,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Addons
                  if (favoriteItem.selectedAddons.isNotEmpty)
                    SizedBox(
                      height: isLargeScreen ? 60 : 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 10, right: 10),
                        children: favoriteItem.selectedAddons
                            .map(
                              (addon) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Row(
                                    children: [
                                      // Addon Name
                                      Text(addon.name),
                                      // Addon Price
                                      Text(' (₸${addon.price})'),
                                    ],
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  onSelected: (value) {},
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontSize: isLargeScreen ? 12 : 10,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
