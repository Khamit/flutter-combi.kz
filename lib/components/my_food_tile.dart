import 'package:combi/models/food.dart';
import 'package:flutter/material.dart';

class FoodTile extends StatelessWidget {
  final Food food;
  final void Function()? onTap;

  const FoodTile({
    Key? key,
    required this.food,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Display as blocks if width is greater than 600
          return buildBlockLayout(context);
        } else {
          // Display as list otherwise
          return buildListLayout(context);
        }
      },
    );
  }

  // Container Block
  Widget buildBlockLayout(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          width: 200, // Fixed width for the container
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.background, // Set border color
            ),
            borderRadius: BorderRadius.circular(10), // Set border radius
            color: Theme.of(context).colorScheme.background, // Set fill color
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: food.imagePath.isNotEmpty &&
                        food.imagePath.startsWith('http')
                    ? Image.network(
                        food.imagePath,
                        height: 200,
                        width: 200,
                        filterQuality: FilterQuality.low,
                      )
                    : Image.asset(
                        food.imagePath, // Provide the default image path here
                        height: 200,
                        width: 200,
                        filterQuality: FilterQuality.low,
                      ),
              ),
              const SizedBox(height: 10),
              // Text food Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      '${food.price}₸',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      food.description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Container List
  Widget buildListLayout(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: 600, // Fixed width for the container
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .background, // Set border color
                ),
                borderRadius: BorderRadius.circular(10), // Set border radius
                color:
                    Theme.of(context).colorScheme.background, // Set fill color
              ),
              child: Row(
                children: [
                  // Text food Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            '${food.price}₸',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            food.description,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  // Food Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: food.imagePath.isNotEmpty &&
                            food.imagePath.startsWith('http')
                        ? Image.network(
                            food.imagePath,
                            height: 100,
                            width: 100,
                            filterQuality: FilterQuality.low,
                          )
                        : Image.asset(
                            food.imagePath, // Provide the default image path here
                            height: 100,
                            width: 100,
                            filterQuality: FilterQuality.low,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.background,
          endIndent: 25,
          indent: 25,
        ),
      ],
    );
  }
}
