// settings_page.dart

import 'package:combi/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const SettingsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"
          //context.l10n.settings
          ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Dark mode container (Assuming you have already implemented this part)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Тёмный режим",
                  //context.l10n.dark_mode
                  ),
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                  onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                ),
              ],
            ),
          ),
          // Language container with three language selection widgets
          /*
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(25),
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to Column
                  children: [
                    Text(context.l10n.language),
                    const SizedBox(height: 10),
                    LanguageSelectionWidget(),
                  ],
                ),
              );
            },
          ),
          Consumer(
            builder: (context, languageProvider, _) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(25),
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to Column
                  children: [
                    Text(context.l10n.location),
                    const SizedBox(height: 10),
                    const CitySelectionWidget(cityNames:[],),
                  ],
                ),
              );
            },
          ),
          */ // City container with city selection widget
        ],
      ),
    );
  }
}