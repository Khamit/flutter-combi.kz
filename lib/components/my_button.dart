// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:combi/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyButton extends StatefulWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    // light & dark
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return GestureDetector(
      onTap: () {
        setState(() {
          isTapped = true;
        });

        widget.onTap?.call();

        // Timer to revert the color after 3 milliseconds
        Timer(const Duration(milliseconds: 200), () {
          setState(() {
            isTapped = false;
          });
        });
      },
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          color: isTapped
              ? Colors.grey.shade100
              : isDarkMode
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Text(
            widget.text,
            style: GoogleFonts.rubik(
              color: Theme.of(context).colorScheme.background,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
