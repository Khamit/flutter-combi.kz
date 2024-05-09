import 'package:avatar_view/avatar_view.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/components/my_drawer_tile.dart';
import 'package:combi/pages/admin_page.dart';
import 'package:combi/pages/favorites_page.dart';
import 'package:combi/pages/login_page.dart';
import 'package:combi/pages/manager_control_page.dart';
import 'package:combi/pages/manager_page.dart';
import 'package:combi/pages/my_account_page.dart';
import 'package:combi/pages/order_page.dart';
import 'package:combi/pages/register_page.dart';
import 'package:combi/pages/setting_page.dart';
import 'package:combi/pages/support_page.dart';
import 'package:combi/providers/role_data_provider.dart';
import 'package:combi/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logout(BuildContext context) {
    // Get auth service
    final authService = AuthService();
    authService.signOut();
    // Redirect to LoginPage
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('У вас нет аккаунта'),
        content: Text('Хотите создать аккаунт?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterPage())),
            child: Text('Да'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService().getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.tertiary,
              size: 100,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final String? userRole = snapshot.data;
          final bool isAdmin = userRole == 'admin';
          final bool isManager = userRole == 'manager';
          final bool isAuthenticated = _auth.currentUser != null;

          if (isAuthenticated) {
            return Drawer(
              backgroundColor: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  SizedBox(height: 60),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child: Consumer<RoleDataProvider>(
                      builder: (context, roleDataProvider, _) {
                        return AvatarView(
                          radius: 50,
                          borderWidth: 2,
                          borderColor: roleDataProvider.borderColor,
                          avatarType: AvatarType.CIRCLE,
                          backgroundColor: Colors.white,
                          imagePath: roleDataProvider.imagePath,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Other authenticated user UI elements...
                  //    Padding(
                  //      padding: const EdgeInsets.only(top: 5),
                  //      child: Divider(
                  //        color: Theme.of(context).colorScheme.primary,
                  //      ),
                  //    ),
                  MyDrawerTile(
                    text: "Г Л А В Н А Я",
                    icon: CarbonIcons.home,
                    onTap: () => Navigator.pop(context),
                  ),
                  MyDrawerTile(
                    text: "З А К А З Ы",
                    icon: CarbonIcons.delivery_truck,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderPage())),
                  ),
                  MyDrawerTile(
                    text: "А К К А У Н Т",
                    icon: CarbonIcons.user,
                    onTap: () {
                      if (isAuthenticated) {
                        // User is authenticated, navigate to MyAccountPage
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyAccountPage()));
                      } else {
                        // User is not authenticated, show account creation dialog
                        showAccountDialog(context);
                      }
                    },
                  ),

                  //MyDrawerTile(
                  //  text: "P A G E",
                  //  icon: CarbonIcons.user,
                  //  onTap: () {
                  //    Navigator.push(
                  //        context,
                  //        MaterialPageRoute(
                  //            builder: (context) => const ProfileScreen()));
                  //  },
                  //),

                  // Other tiles...
                  MyDrawerTile(
                    text: "И З Б Р А Н Н О Е",
                    icon: CarbonIcons.favorite_filled,
                    iconColor: Colors.red,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavoritesPage())),
                  ),
                  MyDrawerTile(
                    text: "Н А С Т Р О Й К И",
                    icon: CarbonIcons.settings,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage())),
                  ),
                  if (isAdmin)
                    MyDrawerTile(
                      text: "А Д М И Н",
                      icon: CarbonIcons.user_admin,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AdminPage())), // Handle admin specific functionality
                    ),
                  if (isManager)
                    MyDrawerTile(
                      text: "М Е Н Е Д Ж Е Р",
                      icon: CarbonIcons.account,
                      iconColor: Colors.blue,
                      onTap: () async {
                        // Check if the manager has restaurant data
                        final restaurantSnapshot = await FirebaseFirestore
                            .instance
                            .collection('restaurant')
                            .where('uid',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .get();
                        if (restaurantSnapshot.docs.isNotEmpty) {
                          // If restaurant data exists, navigate to ManagerControlPage
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManagerControlPage()));
                        } else {
                          // If restaurant data doesn't exist, navigate to ManagerPage
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManagerPage(
                                      firestore: FirebaseFirestore.instance)));
                        }
                      },
                    ),
                  if (!isAdmin &&
                      !isManager) // Display support button for normal users
                    MyDrawerTile(
                      text: "Поддержка",
                      icon: Icons.support,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SupportPage())),
                    ),
                  const Spacer(),
                  MyDrawerTile(
                    text: "В Ы Х О Д",
                    icon: CarbonIcons.logout,
                    onTap: () => logout(context),
                  ),
                  const SizedBox(height: 45),
                ],
              ),
            );
          } else {
            return Drawer(
              backgroundColor: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Image.asset(
                      'assets/images/users/ghost.png',
                      scale: 6,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'User not authorized',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  //Padding(
                  //  padding: const EdgeInsets.only(top: 5),
                  //  child: Divider(
                  //    color: Theme.of(context).colorScheme.primary,
                  //  ),
                  //),
                  // Other tiles...

                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Divider(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  MyDrawerTile(
                    text: "Г Л А В Н А Я",
                    icon: CarbonIcons.home,
                    onTap: () => Navigator.pop(context),
                  ),
                  MyDrawerTile(
                    text: "З А К А З Ы",
                    icon: CarbonIcons.delivery_truck,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderPage())),
                  ),
                  MyDrawerTile(
                    text: "А К К А У Н Т",
                    icon: CarbonIcons.user,
                    onTap: () {
                      if (isAuthenticated) {
                        // User is authenticated, navigate to MyAccountPage
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyAccountPage()));
                      } else {
                        // User is not authenticated, show account creation dialog
                        showAccountDialog(context);
                      }
                    },
                  ),
                  // if user not authorized

                  //  MyDrawerTile(
                  //    text: "P A G E",
                  //    icon: CarbonIcons.user,
                  //    onTap: () {
                  //      Navigator.push(
                  //          context,
                  //          MaterialPageRoute(
                  //              builder: (context) => const ProfileScreen()));
                  //    },
                  //  ),

                  // Other tiles...
                  MyDrawerTile(
                    text: "И З Б Р А Н Н О Е",
                    icon: CarbonIcons.favorite_filled,
                    iconColor: Colors.red,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavoritesPage())),
                  ),
                  MyDrawerTile(
                    text: "Н А С Т Р О Й К И",
                    icon: CarbonIcons.settings,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage())),
                  ),
                  if (isAdmin)
                    MyDrawerTile(
                      text: "А Д М И Н",
                      icon: CarbonIcons.user_admin,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AdminPage())), // Handle admin specific functionality
                    ),
                  if (isManager)
                    MyDrawerTile(
                      text: "М Е Н Е Д Ж Е Р",
                      icon: CarbonIcons.account,
                      iconColor: Colors.blue,
                      onTap: () async {
                        // Check if the manager has restaurant data
                        final restaurantSnapshot = await FirebaseFirestore
                            .instance
                            .collection('restaurant')
                            .where('uid',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .get();
                        if (restaurantSnapshot.docs.isNotEmpty) {
                          // If restaurant data exists, navigate to ManagerControlPage
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManagerControlPage()));
                        } else {
                          // If restaurant data doesn't exist, navigate to ManagerPage
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManagerPage(
                                      firestore: FirebaseFirestore.instance)));
                        }
                      },
                    ),
                  if (!isAdmin &&
                      !isManager) // Display support button for normal users
                    MyDrawerTile(
                      text: "Поддержка",
                      icon: Icons.support,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SupportPage())),
                    ),
                  const Spacer(),
                  MyDrawerTile(
                    text: "В Ы Х О Д",
                    icon: CarbonIcons.logout,
                    onTap: () => logout(context),
                  ),
                  const SizedBox(height: 45),
                ],
              ),
            );
          }
        }
      },
    );
  }
}
