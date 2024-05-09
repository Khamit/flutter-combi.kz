import 'package:combi/models/food.dart'; // Make sure to import the necessary dependencies
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryDropdown extends StatelessWidget {
  final FoodCategory? selectedFoodCategory;
  final List<FoodCategory> categories;
  final Function(FoodCategory?) onChanged;

  const CategoryDropdown({
    Key? key,
    required this.selectedFoodCategory,
    required this.categories,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical padding
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary,), // Border color
            borderRadius: BorderRadius.circular(8.0), // Border radius
          ),
          child: Container(
            child: Row(
              children: [
                Expanded( // Wrap Text with Expanded
                  child: Text(
                    "  Category",
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                DropdownButton<FoodCategory>(
                  value: selectedFoodCategory,
                  onChanged: onChanged,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
