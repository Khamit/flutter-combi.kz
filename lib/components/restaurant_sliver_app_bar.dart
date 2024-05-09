import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/providers/role_data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class RestaurantSliverAppBar extends StatelessWidget {
  final String restaurantName;

  const RestaurantSliverAppBar({
    Key? key,
    required this.restaurantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Consumer<RoleDataProvider>(
      builder: (
        context,
        roleDataProvider,
        _,
      ) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Users')
              .doc(user?.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverAppBar(
                pinned: false,
                floating: false,
                title: Text(
                  restaurantName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 22,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 100,
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return SliverAppBar(
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Error loading data'),
                ),
              );
            } else {
              final userName = snapshot.data?.get('name') ?? '';
              return SliverAppBar(
                expandedHeight: 200,
                backgroundColor: Theme.of(context).colorScheme.primary,
                surfaceTintColor: Theme.of(context).colorScheme.onPrimary,
                foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color: Color.fromARGB(117, 0, 0, 0),
                        width: 150,
                        height: 80,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                "manager: $userName",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                "restaurant:\n$restaurantName",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      AvatarView(
                        radius: 28,
                        borderWidth: 2,
                        borderColor: roleDataProvider.borderColor,
                        avatarType: AvatarType.CIRCLE,
                        backgroundColor: Colors.transparent,
                        imagePath: roleDataProvider.imagePath,
                      ),
                    ],
                  ),
                  background: Image.asset(
                    'assets/images/background/chef.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
