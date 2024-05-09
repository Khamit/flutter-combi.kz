import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

class MyDescriptionBox extends StatelessWidget {
  const MyDescriptionBox({super.key});
  @override
  Widget build(BuildContext context) {
    // textStyle
    var myPrimaryTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );
    var mySecondaryTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.only(
        left: 25,
        right: 25,
        bottom: 25,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // delivery fee
          Column(
            children: [
              Icon(
                CarbonIcons.delivery,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              // Стоймость доставки
              Text(
                '700₸ - 1700₸',
                style: myPrimaryTextStyle,
              ),
              const SizedBox(height: 5),
              Text(
                'Стоимость доставки',
                style: mySecondaryTextStyle,
              ),
            ],
          ),
          // delivery time
          Column(
            children: [
              Icon(
                CarbonIcons.time,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              // Время доставки
              Text(
                '30 - 60 мин',
                style: myPrimaryTextStyle,
              ),
              const SizedBox(height: 5),
              Text(
                'Время доставки',
                style: mySecondaryTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
