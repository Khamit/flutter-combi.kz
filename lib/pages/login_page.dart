// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_textfield.dart';
import 'package:combi/pages/home_page.dart';
import 'package:combi/pages/register_page.dart';
import 'package:combi/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({
    super.key,
    this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

// ignore: use_super_parameters

  void login(BuildContext context) async {
    final authService = AuthService();
    try {
      // Sign in with email and password
      await authService.signInWithEmailPassword(
          emailController.text, pwController.text);

      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } catch (e) {
      // Handle login errors
      String errorMessage = e.toString();
      if (errorMessage.contains('password is invalid')) {
        errorMessage = 'Неверный email или пароль';
      } else if (errorMessage.contains('no user record')) {
        errorMessage = 'Пользователь с таким email не найден';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка входа'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, minHeight: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo/LOGO2.webp',
                  width: 300, // Set the desired width
                  height: 300, // Set the desired height
                ),
                // Welcome
                Text(
                  "combi.kz",
                  style: GoogleFonts.rubik(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: 10),
                // Email textfield
                MyTextField(
                  hintText: "почта..",
                  age: false,
                  gender: false,
                  phoneNumber: false,
                  isAuthorized: false,
                  obscureText: false,
                  validator: (p0) {
                    return null;
                  },
                  controller: emailController,
                ),
                const SizedBox(height: 10),
                // Password
                MyTextField(
                  hintText: "пароль..",
                  age: false,
                  gender: false,
                  phoneNumber: false,
                  isAuthorized: false,
                  obscureText: true,
                  controller: pwController,
                  validator: (p0) {
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                // Login button
                MyButton(
                  text: "Войти",
                  onTap: () {
                    login(context);
                  },
                ),
                const SizedBox(height: 8),
                MyButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  text: 'Пропустить',
                ),
                const SizedBox(height: 10),
                // Register - Not a member?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Нет аккаунта?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterPage()));
                            },
                            child: Text(
                              "Создать аккаунт",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
