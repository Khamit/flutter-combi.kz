import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date
    DateTime orderDate = (order['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(orderDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Детали заказа'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Номер заказа #${order['receiptNumber']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Дата: $formattedDate',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Ваш чек:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Display order details here
              Text(order['order'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
              // Add more fields as necessary
            ],
          ),
        ),
      ),
    );
  }
}
