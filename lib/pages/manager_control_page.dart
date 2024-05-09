import 'package:carbon_icons/carbon_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_textfield.dart';
import 'package:combi/components/restaurant_sliver_app_bar.dart';
import 'package:combi/models/category_dropdown.dart';
import 'package:combi/models/food.dart';
import 'package:combi/models/rating_manager.dart';
import 'package:combi/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerControlPage extends StatefulWidget {
  @override
  _ManagerControlPageState createState() => _ManagerControlPageState();
}

// Delegate for SliverAppBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _ManagerControlPageState extends State<ManagerControlPage>
    with SingleTickerProviderStateMixin {
  // Define a variable to store the selected category
  //   String _selectedCategory = 'Add Food';
  late TabController _tabController;
  int _currentIndex = 0; // Index of the currently displayed image

  // Define a variable to store the selected category
  FoodCategory? _selectedFoodCategory;

  // Define a list of food categories
  List<FoodCategory> categories = [
    FoodCategory.combo,
    FoodCategory.doner,
    FoodCategory.pizza,
    FoodCategory.chicken,
  ];

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foodNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imagePathController;
  late TextEditingController _priceController;

  // For images
  List<String> categoryNames = [
    "combo",
    "doner",
    "pizza",
    "chicken",
  ];

  // Declare the addons list as a class member
  List<Map<String, dynamic>> newAddons = []; // List to store selected addons

  List<Map<String, dynamic>> availableAddons = [
    {"name": "Острый перец", "price": 200},
    {"name": "Морс - 0.5ml", "price": 500},
    {"name": "Лимонад - 0.5ml", "price": 500},
    {"name": "Кефир - 0.33ml", "price": 500},
    {"name": "Пепси - 1L", "price": 700},
    {"name": "Палочки для суши", "price": 10},
  ]; // List of available addons

  // Declare categoryImagePaths here
  List<List<String>> categoryImagePaths = [
    [
      "assets/images/food/combos/02.png",
      "assets/images/food/combos/07.png",
      "assets/images/food/combos/08.png",
      "assets/images/food/combos/09.png",
      "assets/images/food/combos/10.png",
      "assets/images/food/combos/11.png"
    ],
    [
      "assets/images/food/doners/0201.png",
      "assets/images/food/doners/0202.png",
      "assets/images/food/doners/0204.png",
    ],
    [
      "assets/images/food/pizzas/0304.png",
      "assets/images/food/pizzas/0302.png",
      "assets/images/food/pizzas/0303.png",
      "assets/images/food/pizzas/0304.png",
      "assets/images/food/pizzas/0305.png",
      "assets/images/food/pizzas/0306.png",
      "assets/images/food/pizzas/0307.png",
    ],
    [
      "assets/images/food/chicken/00101.png",
      "assets/images/food/chicken/00102.png",
      "assets/images/food/chicken/00103.png",
      "assets/images/food/chicken/00104.png",
      "assets/images/food/chicken/00105.png",
      "assets/images/food/chicken/00106.png",
      "assets/images/food/chicken/00107.png",
    ],
  ];

  // Define addonNames and categoryPrices here
  late List<String> addonNames;
  late List<String> categoryPrices;

  late TextEditingController _newAddonNameController;
  late TextEditingController _newAddonPriceController;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _imagePathController = TextEditingController();
    _priceController = TextEditingController();

    _newAddonNameController = TextEditingController();
    _newAddonPriceController = TextEditingController();

    _tabController = TabController(length: 2, vsync: this);

    // Initialize addonNames and categoryPrices here
    addonNames = List.filled(categories.length, '');
    categoryPrices = List.filled(categories.length, '');

    _fetchRestaurantName().then((restaurantName) {
      // Update the UI or trigger actions with the fetched restaurant name here
      print('Fetched restaurant name: $restaurantName');
    });
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _descriptionController.dispose();
    _imagePathController.dispose();
    _priceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _resetIndex() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _addNewAddon(String name, int price) {
    setState(() {
      availableAddons.add({"name": name, "price": price});
    });
  }

  String? _restaurantName;

  Future<String> _fetchRestaurantName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch the restaurant name from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurant')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      _restaurantName = snapshot.docs.first['restaurantName'];

      // Check if the fetched restaurant name matches the one in local storage
      final storedRestaurantName = prefs.getString('restaurantName');
      if (_restaurantName != storedRestaurantName) {
        // Update the stored restaurant name if they don't match
        prefs.setString('restaurantName', _restaurantName ?? '');
      }

      return _restaurantName!;
    } else {
      // If no restaurant data found, return the locally stored name if available
      if (prefs.containsKey('restaurantName')) {
        return prefs.getString('restaurantName') ?? '';
      } else {
        return ''; // Return an empty string if no restaurant data found
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Manager Control Page'),
        leading: IconButton(
          icon: Icon(CarbonIcons.home),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            FutureBuilder<String>(
              future: _fetchRestaurantName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 100,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                      child: Center(child: Text('Error: ${snapshot.error}')));
                } else {
                  return RestaurantSliverAppBar(
                    restaurantName: snapshot.data ?? '',
                  );
                }
              },
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Theme.of(context).colorScheme.onPrimary,
                  indicatorWeight: 4.0,
                  labelColor: Theme.of(context).colorScheme.background,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.create),
                      child: Text(
                        'Create Food',
                        style: TextStyle(
                          fontFamily: GoogleFonts.rubik().fontFamily,
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.shopping_cart),
                      child: Text(
                        'My Orders',
                        style: TextStyle(
                          fontFamily: GoogleFonts.rubik().fontFamily,
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pinned: false,
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // CREATE FOOD
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "    Chose food",
                                        style: GoogleFonts.rubik(
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: CategoryDropdown(
                                            selectedFoodCategory:
                                                _selectedFoodCategory,
                                            categories: categories,
                                            onChanged: (newValue) {
                                              setState(() {
                                                _selectedFoodCategory =
                                                    newValue;
                                              });
                                              _resetIndex();
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_selectedFoodCategory != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Select your image:',
                                            style: GoogleFonts.rubik(
                                              fontWeight: FontWeight.normal,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 19,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            width: double.infinity,
                                            height:
                                                400, // Change height as needed
                                            child: _getImageForCategory(
                                                _selectedFoodCategory!,
                                                _currentIndex, (index) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Create your food here : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  MyTextField(
                                    controller: _foodNameController,
                                    hintText: 'Name',
                                    obscureText: false,
                                    age: false,
                                    gender: false,
                                    phoneNumber: false,
                                    isAuthorized: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the name';
                                      }
                                      return null;
                                    },
                                  ),
                                  MyTextField(
                                    controller: _descriptionController,
                                    hintText: 'Description',
                                    obscureText: false,
                                    age: false,
                                    gender: false,
                                    phoneNumber: false,
                                    isAuthorized: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the description';
                                      }
                                      return null;
                                    },
                                  ),
                                  MyTextField(
                                    controller: _imagePathController,
                                    hintText: 'Image Path URL address',
                                    obscureText: false,
                                    age: false,
                                    gender: false,
                                    phoneNumber: false,
                                    isAuthorized: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the image path';
                                      }
                                      return null;
                                    },
                                  ),
                                  MyTextField(
                                    controller: _priceController,
                                    hintText: 'Price',
                                    obscureText: false,
                                    age: false,
                                    gender: false,
                                    phoneNumber: true,
                                    isAuthorized: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the price';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          'Addons for ${_selectedFoodCategory.toString().split('.').last}:',
                                          style: GoogleFonts.rubik(
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 18,
                                          ),
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: availableAddons.length,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    availableAddons[index]
                                                        ["name"],
                                                    style: GoogleFonts.rubik(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    '${availableAddons[index]["price"]}₸',
                                                    style: GoogleFonts.rubik(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () {
                                                    setState(() {
                                                      availableAddons
                                                          .removeAt(index);
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'Add new addon:',
                                          style: GoogleFonts.rubik(
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _newAddonNameController,
                                                onChanged: (value) {},
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'Addon Name',
                                                  labelStyle: GoogleFonts.rubik(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    _newAddonPriceController,
                                                onChanged: (value) {},
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'Addon Price',
                                                  labelStyle: GoogleFonts.rubik(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'[0-9]'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              onPressed: () {
                                                if (_newAddonNameController
                                                        .text.isNotEmpty &&
                                                    _newAddonPriceController
                                                        .text.isNotEmpty) {
                                                  int price = int.tryParse(
                                                          _newAddonPriceController
                                                              .text) ??
                                                      0;
                                                  _addNewAddon(
                                                    _newAddonNameController
                                                        .text,
                                                    price,
                                                  );
                                                  _newAddonNameController
                                                      .clear();
                                                  _newAddonPriceController
                                                      .clear();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  MyButton(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        _addFoodToFirestore();
                                      }
                                    },
                                    text: "Add food to menu",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "   Chose food",
                                    style: GoogleFonts.rubik(
                                      fontWeight: FontWeight.normal,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: CategoryDropdown(
                                        selectedFoodCategory:
                                            _selectedFoodCategory,
                                        categories: categories,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedFoodCategory = newValue;
                                          });
                                          _resetIndex();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedFoodCategory != null) ...[
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Select your image:',
                                        style: GoogleFonts.rubik(
                                          fontWeight: FontWeight.normal,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 19,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: double.infinity,
                                        height: 260,
                                        child: _getImageForCategory(
                                            _selectedFoodCategory!,
                                            _currentIndex, (index) {
                                          setState(() {
                                            _currentIndex = index;
                                          });
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Create your food here : ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        MyTextField(
                                          controller: _foodNameController,
                                          hintText: 'Name',
                                          obscureText: false,
                                          age: false,
                                          gender: false,
                                          phoneNumber: false,
                                          isAuthorized: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter the name';
                                            }
                                            return null;
                                          },
                                        ),
                                        MyTextField(
                                          controller: _descriptionController,
                                          hintText: 'Description',
                                          obscureText: false,
                                          age: false,
                                          gender: false,
                                          phoneNumber: false,
                                          isAuthorized: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter the description';
                                            }
                                            return null;
                                          },
                                        ),
                                        MyTextField(
                                          controller: _imagePathController,
                                          hintText: 'Image Path URL address',
                                          obscureText: false,
                                          age: false,
                                          gender: false,
                                          phoneNumber: false,
                                          isAuthorized: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter the image path';
                                            }
                                            return null;
                                          },
                                        ),
                                        MyTextField(
                                          controller: _priceController,
                                          hintText: 'Price',
                                          obscureText: false,
                                          age: false,
                                          gender: false,
                                          phoneNumber: true,
                                          isAuthorized: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter the price';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          padding: EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 30,
                                              ),
                                              Text(
                                                'Addons for ${_selectedFoodCategory.toString().split('.').last}:',
                                                style: GoogleFonts.rubik(
                                                  fontWeight: FontWeight.normal,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Container(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      availableAddons.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            availableAddons[
                                                                index]["name"],
                                                            style: GoogleFonts
                                                                .rubik(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            '${availableAddons[index]["price"]}₸',
                                                            style: GoogleFonts
                                                                .rubik(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.delete),
                                                          onPressed: () {
                                                            setState(() {
                                                              availableAddons
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                'Add new addon:',
                                                style: GoogleFonts.rubik(
                                                  fontWeight: FontWeight.normal,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller:
                                                          _newAddonNameController,
                                                      onChanged: (value) {},
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Addon Name',
                                                        labelStyle:
                                                            GoogleFonts.rubik(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller:
                                                          _newAddonPriceController,
                                                      onChanged: (value) {},
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Addon Price',
                                                        labelStyle:
                                                            GoogleFonts.rubik(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                          RegExp(r'[0-9]'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    onPressed: () {
                                                      if (_newAddonNameController
                                                              .text
                                                              .isNotEmpty &&
                                                          _newAddonPriceController
                                                              .text
                                                              .isNotEmpty) {
                                                        int price = int.tryParse(
                                                                _newAddonPriceController
                                                                    .text) ??
                                                            0;
                                                        _addNewAddon(
                                                          _newAddonNameController
                                                              .text,
                                                          price,
                                                        );
                                                        _newAddonNameController
                                                            .clear();
                                                        _newAddonPriceController
                                                            .clear();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        MyButton(
                                          onTap: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _addFoodToFirestore();
                                            }
                                          },
                                          text: "Add food to menu",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Your "Orders" tab content here MY ORDERS!
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImageForCategory(
      FoodCategory category, int currentIndex, Function(int) updateIndex) {
    void _nextImage() {
      int categoryIndex = category.index;
      List<String> images = categoryImagePaths[categoryIndex];
      if (images.isNotEmpty) {
        int newIndex = (currentIndex + 1) % images.length;
        updateIndex(newIndex);
      }
    }

    void _previousImage() {
      int categoryIndex = category.index;
      List<String> images = categoryImagePaths[categoryIndex];
      if (images.isNotEmpty) {
        int newIndex = (currentIndex - 1) % images.length;
        if (newIndex < 0) {
          newIndex = images.length - 1;
        }
        updateIndex(newIndex);
      }
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth > 600 ? 400.0 : 200.0; // Need fix image size

    return Column(
      children: [
        // Image display
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _previousImage,
              ),
              Padding(
                padding:
                    const EdgeInsets.all(8.0), // Add padding around the image
                child: Container(
                  width: imageSize, // Specify the desired width
                  height: imageSize, // Specify the desired height
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                    ), // Border color
                  ),
                  child: Image.asset(
                    categoryImagePaths[category.index][currentIndex],
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit
                        .contain, // Resize the image to fit within the container
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _nextImage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCustomDialog() {
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
                'Добавлен в Menu!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addFoodToFirestore() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if user is logged in
      if (user != null) {
        // Get the string value of the selected category
        String categoryString =
            _selectedFoodCategory.toString().split('.').last;

        // Get the currently selected image path
        String selectedImagePath = _imagePathController.text.trim().isNotEmpty
            ? _imagePathController.text
                .trim() // Use the user-provided URL if available
            : categoryImagePaths[_selectedFoodCategory!.index]
                [_currentIndex]; // Use the default image path

        // Construct the list of new addons with names and prices
        List<Map<String, dynamic>> newAddons = [];
        for (int i = 0; i < addonNames.length; i++) {
          if (addonNames[i].isNotEmpty && categoryPrices[i].isNotEmpty) {
            newAddons.add({
              "name": addonNames[i],
              "price": int.parse(categoryPrices[i]),
            });
          }
        }

        // Fetch the current popularity, rating, foodWeight, and positionIndex
        int currentPopularity =
            0; // fetch the current popularity from somewhere
        int rating = 0; // fetch the rating from somewhere
        int foodWeight = 0; // fetch the foodWeight from somewhere
        int positionIndex = 0; // fetch the positionIndex from somewhere
        int restaurantWeight = 0; // fetch the restaurantWeight from somewhere

        // Add the selected food item to Firestore
        await FirebaseFirestore.instance.collection('foods').add({
          'name': _foodNameController.text,
          'description': _descriptionController.text,
          'imagePath': selectedImagePath, // Use the selected image path
          'price': double.parse(_priceController.text),
          'category': categoryString, // Use the string value of the category
          'restaurantUid': FirebaseAuth.instance.currentUser!.uid,
          'restaurantName':
              await _fetchRestaurantName(), // Fetch the restaurant name
          'availableAddons':
              availableAddons, // Save both default and new addons
          'popularity': RatingManager.calculatePopularity(
            currentPopularity,
            rating,
            foodWeight,
            restaurantWeight, // restaurantWeight
            positionIndex,
          ),
        });

        // Reset the selected food category
        setState(() {
          _selectedFoodCategory = null;
        });

        // Reset the category index after adding food successfully
        _resetIndex();
        _showCustomDialog();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Food added successfully!'),
        ));
      } else {
        // If user is not logged in, show error dialog
        throw 'User not logged in';
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add food: $e'),
      ));
    }
  }
}
