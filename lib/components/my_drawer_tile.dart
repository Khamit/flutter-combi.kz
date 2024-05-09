// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? iconColor; // New parameter for icon color
  final void Function()? onTap;

  const MyDrawerTile({
    Key? key,
    required this.text,
    required this.icon,
    this.iconColor, // Initialize iconColor parameter
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        leading: Icon(
          icon,
          color: iconColor ??
              Theme.of(context)
                  .colorScheme
                  .onPrimary, // Use iconColor if provided, otherwise use the default color
        ),
        onTap: onTap,
      ),
    );
  }
}
