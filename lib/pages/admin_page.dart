// admin_page.dart
import 'package:combi/pages/home_page.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }, // Navigate back to previous page
          
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to Admin Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}