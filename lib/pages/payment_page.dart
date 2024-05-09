import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_textfield.dart';
import 'package:combi/pages/delivery_progress_page.dart';
import 'package:combi/providers/role_data_provider.dart';
import 'package:combi/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String phoneNumber = '';
  String name = '';
  bool agreedToPaymentRules = false;
  bool isAuthorized = false;

  late TextEditingController phoneNumberController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
//    clearSharedPreferences(); // Call method to clear SharedPreferences
    phoneNumberController = TextEditingController();
    nameController = TextEditingController();
    Provider.of<RoleDataProvider>(context, listen: false).initialize();
    checkAuthorization();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    nameController.dispose();
    super.dispose();
  }

//  Future<void> clearSharedPreferences() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.clear(); // Clear all stored data in SharedPreferences
//  }

  Future<void> checkAuthorization() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? userData = snapshot.data();
        if (userData != null) {
          if (mounted) {
            setState(() {
              isAuthorized = true;
              phoneNumber = userData['phoneNumber'] ?? '';
              name = userData['name'] ?? '';
              agreedToPaymentRules = true;
            });
            phoneNumberController.text = phoneNumber;
            nameController.text = name;

            // Save phone number and name to shared preferences
            savePhoneNumberAndNameToPrefs(phoneNumber, name);
          }
        }
      }
    } else {
      // If user is not authorized, get stored values from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      phoneNumber = prefs.getString('phoneNumber') ?? '';
      name = prefs.getString('name') ?? '';
      phoneNumberController.text = phoneNumber;
      nameController.text = name;
    }
  }

  void savePhoneNumberAndNameToPrefs(String phoneNumber, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('name', name);
  }

  void userTappedProceed() async {
    if (isAuthorized) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DeliveryProgressPage(),
        ),
      );
    } else {
      if (phoneNumber.isEmpty && name.isEmpty && !agreedToPaymentRules) {
        showDialog(
          context: scaffoldKey.currentState!.context,
          builder: (context) => AlertDialog(
            title: Text(
              'Ошибка',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            content: Text(
              'Пожалуйста, заполните все поля и согласитесь с правилами оплаты.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      if (phoneNumber.length < 11) {
        showDialog(
          context: scaffoldKey.currentState!.context,
          builder: (context) => AlertDialog(
            title: Text(
              'Ошибка',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            content: Text(
              'Пожалуйста, убедитесь, что номер телефона содержит не менее 11 символов.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      // Save phone number and name to shared preferences
      savePhoneNumberAndNameToPrefs(phoneNumber, name);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DeliveryProgressPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 104, 14, 14),
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Оплата"),
      ),
      body: FutureBuilder<String?>(
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
            final bool isAuthorized = snapshot.data != null;

            return SingleChildScrollView(
              child: Column(
                children: [
                  if (isAuthorized) SizedBox(height: 40),
                  if (isAuthorized)
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
                  if (!isAuthorized)
                    SizedBox(
                      height: 20,
                    ),
                  if (!isAuthorized)
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Image.asset(
                        'assets/images/users/ghost.png',
                        scale: 6,
                      ),
                    ),
                  if (!isAuthorized) SizedBox(height: 20),
                  if (!isAuthorized)
                    Text(
                      'User not authorized',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  if (!isAuthorized)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Divider(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  // Phone number and name form
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        MyTextField(
                          controller:
                              phoneNumberController, // Add controller argument here
                          hintText: 'Номер Телефона',
                          obscureText: false,
                          age: false,
                          gender: false,
                          phoneNumber: true,
                          isAuthorized:
                              isAuthorized, // Enable only if user is authorized
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите номер телефона';
                            }
                            if (value.length < 11) {
                              return 'Номер телефона должен содержать не менее 11 символов';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            phoneNumber = value;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MyTextField(
                          controller: nameController,
                          hintText: 'Имя',
                          obscureText: false,
                          age: false,
                          gender: false,
                          phoneNumber: false,
                          isAuthorized: isAuthorized,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите имя';
                            }
                            if (value.length < 2) {
                              return 'Имя должно содержать не менее 2 символов';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            name = value;
                          },
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: agreedToPaymentRules,
                              onChanged: (value) {
                                setState(() {
                                  agreedToPaymentRules = value ?? false;
                                });
                              },
                            ),
                            Text(
                              'Я согласен/согласна с правилами оплаты',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary, // Background color
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Правила оплаты и пользователя:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '1. Согласен/Согласна на сбор данных: Имя, Номер телефона. для выставления счёта на оплату товара через интернет приложение Kaspi.kz',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          '2. Поставив галочку пользователь автоматически согласен на 1 пункт, далее приложение обязуется хранить эти данные только для выставление счёта и не вправе распространять информацию третьим лицам.',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          '3. Соглашение действует в течение всего времени пользования приложением, до момента удаления аккаунта.',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          '4. Приложение не контролирует транзакций и не выставляет счёт от имени Combi.kz, Счёт выстовляется "Менеджером" зарегистрированного ресторана в приложений.',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          '5. Приложение не собирает такие данные как: номер карты, банковских счётов итд',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          '6. Приложение использует такие данные как: имя, возраст, почта, пол. В целях обеспечения качественной услуги',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          '7. Если у вас есть вопросы или вы не согласны с правилами вы можете вернуться на главную страницу или обратиться в службу поддержки',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(
                    text: "Продолжить",
                    onTap: userTappedProceed,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
