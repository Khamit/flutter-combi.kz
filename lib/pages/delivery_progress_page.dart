import 'dart:async';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_receipt.dart';
import 'package:combi/models/restaurant.dart';
import 'package:combi/pages/home_page.dart';
import 'package:combi/pages/order_page.dart';
import 'package:combi/services/database/firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class DeliveryProgressPage extends StatefulWidget {
  const DeliveryProgressPage({Key? key}) : super(key: key);

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  final FirestoreService db = FirestoreService();
  late Timer _timer;
  bool _orderAdded = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkOrderAdded();
    });
    // Assuming restaurantUid is available here
    String restaurantUid = ''; // Replace with actual value
    submitOrderToFirestore(restaurantUid);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void submitOrderToFirestore(String restaurantUid) async {
    String receipt = await context.read<Restaurant>().displayCartReceipt();
    String? restaurantUid = context
        .read<Restaurant>()
        .menu
        .first
        .restaurantUid; // Get restaurantUid from Restaurant object
    String? receiptNumber =
        await db.saveOrderToDatabase(receipt, restaurantUid);
    if (receiptNumber != null) {
      _showSuccessDialog(receiptNumber);
    }
  }

  void _navigateToHomePage() {
    // Navigate to OrderPage
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            HomePage(), // Replace OrderPage with your actual OrderPage
      ),
      (Route<dynamic> route) => false,
    );
  }

  void checkOrderAdded() async {
    try {
      List<Map<String, dynamic>> orders =
          await db.getAllOrdersForCurrentUser('');
      String receipt = await context.read<Restaurant>().displayCartReceipt();
      bool orderExists = orders.any((order) => order['order'] == receipt);
      if (orderExists) {
        _timer.cancel();
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            _orderAdded = true;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showSuccessDialog(String receiptNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ваш заказ принят!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Номер вашего заказа: $receiptNumber',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Вы можете сохранить этот номер для отслеживания заказа.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _orderAdded = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

//
  void navigateToHomePage() {
    // Navigate to HomePage and remove all the routes below it
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ принят: ожидайте..'),
        leading: IconButton(
          icon: Icon(Icons.home), // Use the home icon
          onPressed:
              _navigateToHomePage, // Call _navigateToHomePage when the button is pressed
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Show loading animation if order is not added
            if (!_orderAdded)
              Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 100,
                ),
              ),
            if (_orderAdded) // Render MyReceipt only if order is added
              MyReceipt(),
            SizedBox(
                height:
                    20), // Add some spacing between MyReceipt and other content
            // Your other content here

            MyButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderPage(),
                  ),
                );
              },
              text: 'Статус заказа',
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(
          context), // Add this line to include the bottom navigation bar
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
      ),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(CarbonIcons.person),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "NAME",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              Text(
                "Ресепшн/Менеджер",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(CarbonIcons.chat),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(CarbonIcons.phone_voice_filled),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
