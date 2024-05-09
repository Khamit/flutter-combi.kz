import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/pages/home_page.dart'; // Import your HomePage here
import 'package:combi/pages/order_details_page.dart';
import 'package:combi/services/database/firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late TextEditingController _searchController;
  Timer? _debounceTimer; // Declare a Timer variable

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ваши Заказы'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по номеру заказа...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
              ),
              onChanged: (value) {
                // Call the debounce function when text changes
                _debounceTimer?.cancel(); // Cancel the previous timer
                _debounceTimer = Timer(Duration(milliseconds: 500), () {
                  // Set a new timer
                  _performSearch(value); // Perform search after debounce time
                });
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: FirestoreService()
                    .getAllOrdersForCurrentUser(_searchController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    List<Map<String, dynamic>>? orders = snapshot.data;
                    if (orders == null || orders.isEmpty) {
                      return const Center(
                        child: Text('История заказов отсутствует...'),
                      );
                    } else {
                      if (_searchController.text.isNotEmpty) {
                        orders = orders
                            .where((order) => order['receiptNumber']
                                .toString()
                                .contains(_searchController.text))
                            .toList();
                      }
                      orders.sort((a, b) => b['date'].compareTo(a['date']));
                      // orders in firestore how much tou need
                      orders = orders.take(20).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(orders![index]);
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String searchText) {
    if (searchText.length <= 4) {
      // If search text has less than or equal to 4 characters, do not perform search
      setState(() {
        // Update UI to clear the search results or indicate waiting state
      });
    } else {
      // Otherwise, perform the search
      _debounceTimer?.cancel(); // Cancel the debounce timer if it's active
      _debounceTimer = Timer(Duration(milliseconds: 600), () {
        // Set a new debounce timer to wait for user input
        setState(() {
          // Update UI to indicate loading state while searching
        });
        // Perform the actual search operation with searchText
        FirestoreService()
            .getAllOrdersForCurrentUser(searchText)
            .then((orders) {
          setState(() {
            // Update UI with search results
            // Update UI to display search results based on the returned orders
          });
        }).catchError((error) {
          setState(() {
            // Update UI to indicate error state
          });
          print('Error searching orders: $error');
        });
      });
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    DateTime orderDate = (order['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(orderDate);

    Duration age = DateTime.now().difference(orderDate);
    Color tileColor =
        age.inDays < 1 ? Colors.purple.shade400 : Colors.transparent;

    return Card(
      color: tileColor,
      child: ListTile(
        title: Text('№ ${order['receiptNumber']}'),
        subtitle: Text(formattedDate),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        },
      ),
    );
  }
}
