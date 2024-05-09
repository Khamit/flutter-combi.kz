import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManager {
  // Method to fetch orders for the current user's restaurant UID
  static Future<List<Order>> fetchOrdersForCurrentUser(
      String restaurantUid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('restaurantUid', isEqualTo: restaurantUid)
          .get();

      List<Order> orders =
          querySnapshot.docs.map((doc) => Order.fromSnapshot(doc)).toList();
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}

class Order {
  final String orderId;
  final String userId;
  final String restaurantUid;
  final String status;
  // Add more fields as required

  Order({
    required this.orderId,
    required this.userId,
    required this.restaurantUid,
    required this.status,
    // Initialize other fields here
  });

  // Method to create an Order object from a Firestore snapshot
  factory Order.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Order(
      orderId: snapshot.id,
      userId: data['userId'] ?? '',
      restaurantUid: data['restaurantUid'] ?? '',
      status: data['status'] ?? '',
      // Initialize other fields from the snapshot here
    );
  }
}
