import 'package:carbon_icons/carbon_icons.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_cart_tile.dart';
import 'package:combi/models/restaurant.dart';
import 'package:combi/pages/home_page.dart';
import 'package:combi/pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const CartPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) {
        // cart
        final userCart = restaurant.cart;

        // Scaffold UI
        return Scaffold(
          appBar: AppBar(
            title: const Text("Корзина"),
            backgroundColor: Colors.transparent,
            foregroundColor:  Theme.of(context).colorScheme.inversePrimary, // Changed to onPrimary
            actions: [
              // clear cart Button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Вы уверены ?"),
                      actions: [
                        // cancel button
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Отмена"),
                        ),
                        // yes button
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            restaurant.clearCart();
                          },
                          child: const Text("Да"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(CarbonIcons.delete),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Button to PAY
              return Column(
                children: [
                  // list of cart
                  Expanded(
                    child: userCart.isEmpty
                        ? const Center(
                            child: Text("Пустая корзина.."),
                          )
                        : ListView.builder(
                            itemCount: userCart.length,
                            itemBuilder: (context, index) {
                              //get individual cart item
                              final cartItem = userCart[index];
                              // return cart tile UI
                              return MyCartTile(cartItem: cartItem);
                            },
                          ),
                  ),
                  const SizedBox(height: 25),
                  // Button to PAY
                  constraints.maxWidth > 600
                      ? SizedBox(
                          width: 600, // Set width as desired
                          child: MyButton(
                            text: "Оплатить",
                            onTap: () {
                              if (userCart.isEmpty) {
                                // Show dialog if cart is empty
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Вам нужно добавить в корзину товар"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                          context, MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                  ),
                                );  // Close the dialog
                                        },
                                        child: Center(child: const Text("Хорошо")),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // Navigate to payment page if cart is not empty
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaymentPage(),
                                  ),
                                );
                              }
                            },
                          ),
                        )
                      : MyButton(
                          text: "Оплатить", // => PAYMENT PAGE
                          onTap: () {
                            if (userCart.isEmpty) {
                              // Show dialog if cart is empty
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Вам нужно добавить в корзину товар"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context, MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                  ),
                                ); // Close the dialog
                                      },
                                      child: Center(child: const Text("Хорошо")),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Navigate to payment page if cart is not empty
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentPage(),
                                ),
                              );
                            }
                          },
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
