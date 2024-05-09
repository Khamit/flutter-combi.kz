import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantDataList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('restaurant')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No restaurant data found.'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Название ресторана: ${data['restaurantName']}', style: TextStyle(fontSize: 18,)),
                Text('Город: ${data['city']}', style: TextStyle(fontSize: 18,)),
                Text('Адрес: ${data['address']}', style: TextStyle(fontSize: 18,)),
                //Text('Почта менеджера: ${data['managerEmail']}', style: TextStyle(fontSize: 18,)),
                //Text('Номер телефона менеджера: ${data['managerPhoneNumber']}', style: TextStyle(fontSize: 18,)),
                //Text('Номер телефона ресепшн: ${data['restaurantPhoneNumber']}', style: TextStyle(fontSize: 18,)),
                //Text('Instagram: ${data['instagram']}', style: TextStyle(fontSize: 18,)),
                //Text('WhatsApp номер: ${data['whatsAppNumber']}', style: TextStyle(fontSize: 18,)),
                Divider(), // Add divider between each set of data
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
