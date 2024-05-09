import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/pages/my_account_change_page.dart';
import 'package:combi/providers/role_data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Consumer<RoleDataProvider>(
      builder: (context, roleDataProvider, _) {
        // Return the Container widget inside the builder function
        return Container(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 190,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        ClipPath(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 35,
                          left: 20,
                          right: 225,
                          child: Container(
                            child: AvatarView(
                              radius: 60,
                              borderWidth: 8,
                              borderColor: roleDataProvider.borderColor,
                              avatarType: AvatarType.CIRCLE,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              imagePath: roleDataProvider.imagePath,
                            ),
                          ),
                        ),
                        // User Name is only top
                        Positioned(
                          top: 30,
                          left: 155,
                          right: 30,
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Users')
                                .doc(user?.uid)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text("Error fetching data");
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return Text(
                                  data['name'],
                                  style: GoogleFonts.rubik(
                                    fontSize: 32,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                );
                              }

                              return Text(
                                "Загрузка...",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              );
                            },
                          ),
                        ),
                        // White Side user information there we can add all user info.
                        Positioned(
                          top: 110,
                          left: 155,
                          right: 10,
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Users')
                                .doc(user?.uid)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text("Ошибка загрузки");
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['email'],
                                      style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    Divider(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      thickness:
                                          1, // Adjust thickness as needed
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Возраст: ${data['age']}",
                                      style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    Divider(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      thickness:
                                          1, // Adjust thickness as needed
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      " ${data['phoneNumber']}",
                                      style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    Divider(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      thickness:
                                          1, // Adjust thickness as needed
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Роль: ${data['role']}",
                                      style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Text("Загрузка...");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                MyButton(
                  text: 'Изменить',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyAccountChangePage()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
