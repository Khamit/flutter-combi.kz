import 'package:combi/firebase_options.dart';
import 'package:combi/models/restaurant.dart';
import 'package:combi/providers/role_data_provider.dart';
import 'package:combi/services/auth/auth_gate.dart';
import 'package:combi/themes/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'package:provider/provider.dart';

// Credits:
// YoutubeChannel: Mitch Koko,

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the RoleDataProvider
  RoleDataProvider roleDataProvider = RoleDataProvider();

  // Create an instance of ThemeProvider
  ThemeProvider themeProvider = ThemeProvider();

  runApp(
    MultiProvider(
      providers: [
        // user image and role provider
        ChangeNotifierProvider<RoleDataProvider>(
          create: (_) => roleDataProvider,
        ),
        // theme provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
        ),
        // restaurant provider
        ChangeNotifierProvider(
          create: (context) =>
              Restaurant(name: '', auth: FirebaseAuth.instance),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of my application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      builder: FlutterEasyDialogs.builder(),
    );
  }
}
