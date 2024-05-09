import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> saveOrderToDatabase(
      String receipt, String restaurantUid) async {
    try {
      User? user = _auth.currentUser;
      String? userId = user?.uid;
      String? userEmail = user?.email;

      if (userId != null) {
        // Retrieve the user's data from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection("Users").doc(userId).get();
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>? ?? {};

        // Retrieve name and phone number from Firestore
        String? userName = userData['name'] as String?;
        String? userPhoneNumber = userData['phoneNumber'] as String?;

        // If name or phone number is missing, fetch from SharedPreferences
        if (userName == null || userPhoneNumber == null) {
          final prefs = await SharedPreferences.getInstance();
          userName = prefs.getString('name');
          userPhoneNumber = prefs.getString('phoneNumber');
        }

        // Generate a random receipt number
        int receiptNumber = 10000 + Random().nextInt(90000);

        // Add the order data to Firestore
        Map<String, dynamic> orderData = {
          'date': DateTime.now(),
          'order': receipt,
          'receiptNumber': receiptNumber,
          'userId': userId,
          'userEmail': userEmail,
          'userName': userName,
          'userPhoneNumber': userPhoneNumber,
          'restaurantUid': restaurantUid,
          // Add more fields as necessary
        };

        await orders.add(orderData);

        // Return the generated receipt number
        return receiptNumber.toString();
      } else {
        // Handle case where user is not authenticated
        // Retrieve name and phone number from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? userName = prefs.getString('name');
        String? userPhoneNumber = prefs.getString('phoneNumber');

        // Generate a random receipt number
        int receiptNumber = 100000 + Random().nextInt(900000);

        // Add the order data to Firestore
        Map<String, dynamic> orderData = {
          'date': DateTime.now(),
          'order': receipt,
          'receiptNumber': receiptNumber,
          'userName': userName,
          'userPhoneNumber': userPhoneNumber,
          'restaurantUid': restaurantUid,
          // Add more fields as necessary
        };

        await orders.add(orderData);

        // Return the generated receipt number
        return receiptNumber.toString();
      }
    } catch (e) {
      print('Error saving order: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllOrdersForCurrentUser(
      String searchText) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        // If user is not logged in, only retrieve orders matching the typed receipt number
        if (searchText.isNotEmpty) {
          print('Searching orders by receipt number: $searchText');
          QuerySnapshot querySnapshot = await _firestore
              .collection('orders')
              .where('orderId', isEqualTo: searchText)
              .get();

          return querySnapshot.docs
              .where((document) =>
                  (document.data() as Map<String, dynamic>?)
                      ?.containsKey('userEmail') ??
                  false)
              .map((document) => document.data() as Map<String, dynamic>)
              .toList();
        } else {
          print('No search query provided');
          return []; // Return an empty list if no search query provided
        }
      } else {
        // If user is logged in, retrieve all orders belonging to the current user
        print('Fetching orders for logged-in user: ${user.uid}');
        QuerySnapshot querySnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();

        return querySnapshot.docs
            .map((document) => document.data() as Map<String, dynamic>)
            .toList();
      }
    } catch (e, stackTrace) {
      print('Error fetching orders: $e');
      print(stackTrace); // Print stack trace for debugging
      throw e;
    }
  }
}
