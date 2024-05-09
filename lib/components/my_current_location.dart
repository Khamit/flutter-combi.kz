import 'package:carbon_icons/carbon_icons.dart';
import 'package:combi/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyCurrentLocation extends StatelessWidget {
  MyCurrentLocation({super.key});

  final textController = TextEditingController();

  void openLocationSearchBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Ваше адресс"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: "Адресс доставки.."),
        ),
        actions: [
          // cancel button
          MaterialButton(
          onPressed: () {
            Navigator.pop(context);
            textController.clear();
            },
          child: const Text('Отмена'),
          ),
          // save button
          MaterialButton(
            // update delivery address
          onPressed: () {
            String newAddress = textController.text;
            context.read<Restaurant>().updateDeliveryAddress(newAddress);
            Navigator.pop(context);
            textController.clear();
            },
          child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Укажите адрес доставки:",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary,
          ),
        ),
            GestureDetector(
              onTap: () => openLocationSearchBox(context),
              child: Row(
                children: [
                
                Consumer<Restaurant>(
                  builder: (context, restaurant, child) =>Text(
                    // address
                    restaurant.deliveryAddress,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                    
                // drop down menu
                Icon(
                  CarbonIcons.location_heart_filled,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimary
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}