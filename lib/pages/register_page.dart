import 'package:carbon_icons/carbon_icons.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_textfield.dart';
import 'package:combi/pages/home_page.dart';
import 'package:combi/pages/login_page.dart';
// Import the custom controllers and enums
import 'package:combi/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();

// Inside _RegisterPageState class
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

// Inside _RegisterPageState class
  final TextEditingController _nameController = TextEditingController();

  void register(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 200, // Adjust the height as needed
          width: 200,
          child: Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.tertiary,
              size: 100,
            ),
          ),
        ),
      ),
    );

    final auth = AuthService();
    final dateOfBirth = _ageController.text;
    final String email = _emailController.text.trim();

    // Regular expression for validating email format
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    int calculateAge(String dateOfBirth) {
      List<String> dateParts = dateOfBirth.split('-');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);
      DateTime now = DateTime.now();
      int age = now.year - year;
      if (now.month < month || (now.month == month && now.day < day)) {
        age--;
      }
      return age;
    }

    if (!emailRegex.hasMatch(email)) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error dialog if email format is invalid
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Неправильный адрес почты'),
          content: Text(
              'Пожалуйста введите корректный адрес вашей почты. Например : example@gmail.com.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return; // Exit the function if email is invalid
    }

    final age = calculateAge(dateOfBirth);

    try {
      await auth.signUpWithEmailPassword(
        _emailController.text,
        _pwController.text,
        _confirmpwController,
        _phoneNumberController.text,
        age,
        _genderController.text,
        _nameController.text,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success dialog after successful account creation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Успех'),
          content: Text('Ваш аккаунт успешно создан!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomePage())); // Navigate to HomePage
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      String errorMessage = 'An error occurred.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Invalid email address format.';
            break;
          case 'email-already-in-use':
            errorMessage = 'This email is already registered.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email & Password accounts are not enabled.';
            break;
          default:
            errorMessage = 'An unknown error occurred.';
        }
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    Icon(
                      CarbonIcons.region_analysis_area,
                      size: 75,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    Text(
                      "создать аккаунт",
                      style: GoogleFonts.rubik(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      hintText: "введите почту",
                      obscureText: false,
                      icon: CarbonIcons.mail_all,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      controller: _emailController,
                      validator: (p0) {
                        return null;
                      },
                      isAuthorized: false,
                    ),
                    const SizedBox(height: 5),
                    MyTextField(
                      hintText: "введите пароль",
                      obscureText: true,
                      icon: CarbonIcons.password,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      controller: _pwController,
                      validator: (p0) {
                        return null;
                      },
                      isAuthorized: false,
                    ),
                    const SizedBox(height: 5),
                    MyTextField(
                      hintText: "подтвердите пароль",
                      obscureText: true,
                      icon: CarbonIcons.password,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      controller: _confirmpwController,
                      validator: (p0) {
                        return null;
                      },
                      isAuthorized: false,
                    ),
                    const SizedBox(height: 5),
                    // MY NAME IS JOHN CENA!!!
                    MyTextField(
                      hintText: "введите имя",
                      obscureText: false,
                      icon: CarbonIcons.identification,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      controller: _nameController,
                      validator: (p0) {
                        return null;
                      },
                      isAuthorized: false,
                    ),
                    const SizedBox(height: 5),

                    // New text field for age
                    MyTextField(
                      hintText: "Укажите возраст",
                      icon: CarbonIcons.calendar,
                      obscureText: false,
                      age: true,
                      gender: false,
                      phoneNumber: false,
                      controller: _ageController,
                      validator: (date) {
                        setState(() {
                          if (date != null) {
                            _ageController.text =
                                date; // Update text field with selected date
                          }
                        });
                        return null;
                      },
                      isAuthorized: false,
                    ),

                    const SizedBox(height: 5),
                    MyTextField(
                      hintText: "введите ваш номер",
                      obscureText: false,
                      icon: CarbonIcons.phone,
                      age: false,
                      gender: false,
                      phoneNumber: true,
                      controller: _phoneNumberController,
                      validator: (p0) {
                        return null;
                      },
                      isAuthorized: false,
                    ),
                    const SizedBox(height: 5),
                    MyTextField(
                      // Handle the selected gender here
                      hintText: "Укажите пол (Мужчина или Женщина)",
                      obscureText: false,
                      icon: CarbonIcons.gender_male,
                      age: false,
                      gender: true,
                      phoneNumber: false,
                      controller: _genderController,
                      validator: (p0) {
                        return null;
                      },
                      isAuthorized: false,
                    ),

                    const SizedBox(height: 20),

                    MyButton(
                      onTap: () {
                        register(context);
                      },
                      text: 'Создать аккаунт',
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "у вас есть аккаунт?",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            },
                            child: Text(
                              "Авторизоваться",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
