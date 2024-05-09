import 'package:combi/components/my_current_location.dart';
import 'package:combi/components/my_description_box.dart';
import 'package:combi/components/my_drawer.dart';
import 'package:combi/components/my_food_tile.dart';
import 'package:combi/components/my_sliver_app_bar.dart';
import 'package:combi/components/my_tab_bar.dart';
import 'package:combi/models/food.dart';
import 'package:combi/models/restaurant.dart';
import 'package:combi/pages/food_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true; // Variable to track if data is loading

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCustomDialog(String foodName) {
    FlutterEasyDialogs.show(
      EasyDialog.positioned(
        autoHideDuration: const Duration(milliseconds: 500),
        decoration: EasyDialogDecoration.combine([
          const EasyDialogAnimation.slideVertical(),
          const EasyDialogAnimation.fade(),
          EasyDialogAnimation.blurBackground(
            backgroundColor: Colors.black.withOpacity(0.2),
          )
        ]),
        content: Container(
          height: 150.0,
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Добавлен в корзину:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Text(
                '$foodName!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 26.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simulate loading data for demonstration purposes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  Widget getFoodInThisCategory(List<Food> fullMenu) {
    if (MediaQuery.of(context).size.width > 700) {
      return Wrap(
        children: FoodCategory.values.map((category) {
          List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);

          // Sort the food items in this category by popularity (descending order)
          categoryMenu.sort((a, b) => b.popularity.compareTo(a.popularity));

          return Wrap(
            children: categoryMenu.map((food) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: FoodTile(
                  food: food,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodPage(
                        food: food,
                        onAddToCart: (_) {
                          _showCustomDialog(food.name);
                        },
                        onAddToFavorites: (Food) {},
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      );
    } else {
      return ListView.builder(
        itemCount: fullMenu.length,
        itemBuilder: (context, index) {
          final food = fullMenu[index];
          return FoodTile(
            food: food,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodPage(
                  food: food,
                  onAddToCart: (_) {
                    _showCustomDialog(food.name);
                  },
                  onAddToFavorites: (Food) {},
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      drawer: MyDrawer(),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.tertiary,
                size: 100,
              ),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                MySliverAppBar(
                  title: MyTabBar(tabController: _tabController),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 44),
                      Divider(
                        indent: 25,
                        endIndent: 25,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      MyCurrentLocation(),
                      const MyDescriptionBox(),
                    ],
                  ),
                ),
              ],
              body: Consumer<Restaurant>(
                builder: (context, restaurant, child) => TabBarView(
                  controller: _tabController,
                  children: [
                    for (var category in FoodCategory.values)
                      getFoodInThisCategory(
                        _filterMenuByCategory(
                          category,
                          restaurant.menu,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
