import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  //Instance of Auth firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Method to check if the user is authenticated

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseFirestore _firebaseAuth = FirebaseFirestore.instance;

  get isAuthenticated => _auth.currentUser != null;
  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
    // return _firebaseAuth.currentUser;
  }

  // Google Sign In
/*
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    // begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // create new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    try {
      // finally sign in
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // Handle sign-in errors here
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar (
          content: Text('Google Sign-In Failed'),
        ),
      );
      return null;
    }
  }
  
*/

// Sign in with email and password for Users, Managers, and Admins
  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check the role of the signed-in user
      DocumentSnapshot userSnapshot = await _firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get();

      if (userSnapshot.exists) {
        String role = userSnapshot.get("role");
        if (role == "user" || role == "manager" || role == "admin") {
          return userCredential;
        } else {
          throw Exception("Invalid user role");
        }
      } else {
        // If the user document doesn't exist, create a default one
        await _firestore.collection("Users").doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'role': 'user', // Default role for Users
        });
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    TextEditingController confirmpwController,
    String phoneNumber,
    int age,
    String gender,
    String name,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
          'role': 'user', // Default role
          'phoneNumber': phoneNumber,
          'age': age,
          'gender': gender,
          'name': name,
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'The account already exists for that email.';
      } else {
        throw 'Error signing up with email and password: ${e.message}';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  // Roles inside firebase
  Future<String?> getCurrentUserRole() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final docSnapshot =
        await _firestore.collection('Users').doc(currentUser.uid).get();
    if (!docSnapshot.exists) return null;

    final userData = docSnapshot.data();
    return userData?[
        'role']; // Assuming 'role' is the field containing the user's role
  }

  // Sign Out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
