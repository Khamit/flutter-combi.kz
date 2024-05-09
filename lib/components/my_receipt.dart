import 'package:combi/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyReceipt extends StatelessWidget {
  const MyReceipt({Key? key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 65),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Спасибо за покупку!"),
            const SizedBox(height: 25),
            // Use FutureBuilder to wait for receipt generation
            FutureBuilder<String?>(
              future: context.read<Restaurant>().displayCartReceipt(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while waiting for the receipt
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Handle error if receipt generation fails
                  return Text("Ошибка: ${snapshot.error}");
                } else {
                  // Display the receipt once it's generated
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Text(snapshot.data ?? ''),
                  );
                }
              },
            ),
            const SizedBox(height: 25),
            const Text("Расчетное время доставки — 16:10"),
          ],
        ),
      ),
    );
  }
}