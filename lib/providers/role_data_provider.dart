import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleDataProvider extends ChangeNotifier {
  String _imagePath = '';
  Color _borderColor = Colors.black;
  String _userRole = '';
  int _userAge = 0;
  String _userGender = '';

  String get imagePath => _imagePath;
  Color get borderColor => _borderColor;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RoleDataProvider() {
    // Call initialize method in the constructor
    initialize();
  }

  Future<void> initialize() async {
    // Check if the user is authenticated
    final User? user = _auth.currentUser;
    if (user != null) {
      // Get user document from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      _userRole = userData['role'] ?? '';
      _userAge = userData['age'] ?? 0;
      _userGender = userData['gender'] ?? '';

      // Update image path based on user's age and gender
      await _updateImageAssetPath(); // Call the method to update the image asset path

      // Update border color based on user's role
      _borderColor = _getBorderColor(_userRole);

      // Save new values to shared preferences
      await _saveToSharedPreferences();

      // Notify listeners about the change
      notifyListeners();
    }
  }

  Future<void> _updateImageAssetPath() async {
    String gender = _userGender;
    int age = _userAge;

    if (age > 30) {
      if (gender.toLowerCase() == 'мужчина') {
        _imagePath = 'assets/images/users/oldMan1.png';
      } else if (gender.toLowerCase() == 'женщина') {
        _imagePath = 'assets/images/users/oldWoman2.png';
      }
    } else {
      if (gender.toLowerCase() == 'мужчина') {
        _imagePath = 'assets/images/users/youngBoy1.png';
      } else if (gender.toLowerCase() == 'женщина') {
        _imagePath = 'assets/images/users/youngGirl2.png';
      }
    }

    return Future.value(); // Return a completed future
  }

  Color _getBorderColor(String userRole) {
    switch (userRole) {
      case 'user':
        return Colors.green.shade700;
      case 'manager':
        return Colors.blue.shade400;
      case 'admin':
        return Colors.red.shade600;
      default:
        return Colors.black; // Default color if role is unknown
    }
  }

  Future<void> _saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagePath', _imagePath);
    await prefs.setInt('borderColor', _borderColor.value);
  }

  Future<void> _loadFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _imagePath = prefs.getString('imagePath') ?? '';
    _borderColor = Color(prefs.getInt('borderColor') ?? Colors.black.value);
    // Check if the user is anonymous and set the image path accordingly
    notifyListeners(); // Notify listeners after setting the values
  }
}
