import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/pages/admin_page.dart'; // Import AdminPage
import 'package:combi/pages/home_page.dart';
import 'package:combi/pages/manager_control_page.dart'; // Import ManagerControlPage
import 'package:combi/pages/manager_page.dart'; // Import ManagerPage
import 'package:combi/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  AuthGate({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User? user = snapshot.data as User?;
            if (user != null) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;

                    if (userData != null && userData.containsKey('role')) {
                      switch (userData['role']) {
                        case 'manager':
                          if (userData.containsKey('restaurant')) {
                            // If user is a manager and has restaurant data, redirect to ManagerControlPage
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('restaurant').doc(user.uid).get(),
                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  return ManagerControlPage();
                                } else {
                                  // If user is a manager but restaurant data is missing, return ManagerPage
                                  return ManagerPage(firestore: FirebaseFirestore.instance);
                                }
                              },
                            );
                          } else {
                            // If user is a manager but doesn't have restaurant data, return ManagerPage
                            return ManagerPage(firestore: FirebaseFirestore.instance);
                          }
                        // Other cases...
                        case 'admin':
                          return AdminPage();
                        default :
                          return HomePage();
                      }
                    } else {
                      return HomePage();
                    }
                  }
                  return Center(child: CircularProgressIndicator());
                },
              );
            }
          }
          return LoginOrRegister();
        },
      ),
    );
  }
}
