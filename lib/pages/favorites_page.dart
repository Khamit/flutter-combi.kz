import 'package:carbon_icons/carbon_icons.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_favorite_tile.dart';
import 'package:combi/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) {
        final favoriteItems = restaurant.favoriteItems;

        return Scaffold(
          appBar: AppBar(
            title: Text('Избранное'),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                onPressed: () {
                  // Clear favorites
                  restaurant.clearFavorites();
                },
                icon: Icon(CarbonIcons.delete),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: favoriteItems.isEmpty
                        ? Center(
                            child: Text('Добавьте товар в избранное...'),
                          )
                        : ListView.builder(
                            itemCount: favoriteItems.length,
                            itemBuilder: (context, index) {
                              return MyFavoriteTile(
                                favoriteItem: favoriteItems[index],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    width: 600,
                    child: MyButton(
                      text: "Sort by",
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
