import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_textfield.dart';
import 'package:combi/pages/home_page.dart';
import 'package:combi/pages/manager_control_page.dart';
import 'package:combi/providers/role_data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerPage extends StatefulWidget {
  final FirebaseFirestore firestore;

  const ManagerPage({Key? key, required this.firestore}) : super(key: key);

  @override
  _ManagerPageState createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _whatsAppNumberController =
      TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load user data when the page initializes
    _getCurrentUserData();
  }

  Future<void> _getCurrentUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
          .collection('restaurant')
          .where('uid', isEqualTo: user.uid)
          .get();
      if (restaurantSnapshot.docs.isNotEmpty) {
        // If restaurant data exists for the user, navigate to ManagerControlPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ManagerControlPage(),
          ),
        );
      } else {
        // If restaurant data doesn't exist, set isLoading to false
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Менеджер'),
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomePage())),
        ),
      ),
      body: Consumer<RoleDataProvider>(
        builder: (context, roleDataProvider, _) {
          if (!_isLoading) {
            // Load data from SharedPreferences if not already loaded
            if (roleDataProvider.imagePath.isEmpty ||
                roleDataProvider.borderColor == Colors.black) {
              roleDataProvider.initialize();
            }
          }
          return _isLoading
              ? Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 100,
                  ),
                )
              : _buildManagerPage(roleDataProvider);
        },
      ),
    );
  }

  Widget _buildManagerPage(RoleDataProvider roleDataProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            height: MediaQuery.of(context).size.height, // Set a fixed height
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // AvatarView Widget
                    Container(
                      alignment: Alignment.center,
                      child: AvatarView(
                        radius: 60,
                        borderWidth: 8,
                        borderColor: roleDataProvider.borderColor,
                        avatarType: AvatarType.CIRCLE,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        imagePath: roleDataProvider.imagePath,
                        placeHolder: Container(
                          child: Icon(
                            Icons.person,
                            size: 50,
                          ),
                        ),
                        errorWidget: Container(
                          child: Icon(
                            Icons.error,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    MyTextField(
                      controller: _cityController,
                      hintText: 'Город',
                      obscureText: false,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      isAuthorized: false,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: _restaurantNameController,
                      hintText: 'Название ресторана',
                      obscureText: false,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      isAuthorized: false,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: _addressController,
                      hintText: 'Адрес',
                      obscureText: false,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      isAuthorized: false,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: _phoneNumberController,
                      hintText: 'Номер ресепшена',
                      obscureText: false,
                      age: false,
                      gender: false,
                      phoneNumber: true,
                      isAuthorized: false,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: _whatsAppNumberController,
                      hintText: 'Номер WhatsApp',
                      obscureText: false,
                      age: false,
                      gender: false,
                      phoneNumber: true,
                      isAuthorized: false,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: _instagramController,
                      hintText: 'Instagram',
                      obscureText: false,
                      age: false,
                      gender: false,
                      phoneNumber: false,
                      isAuthorized: false,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: 'Сохранить',
                      onTap: () {
                        _saveRestaurantData(this);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveRestaurantData(_ManagerPageState state) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        Map<String, dynamic>? userData =
            userDataSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('phoneNumber')) {
          await state.widget.firestore.collection('restaurant').add({
            'city': state._cityController.text,
            'restaurantName': state._restaurantNameController.text,
            'address': state._addressController.text,
            'restaurantPhoneNumber': state._phoneNumberController.text,
            'whatsAppNumber': state._whatsAppNumberController.text,
            'instagram': state._instagramController.text,
            'uid': user.uid,
            'managerEmail': user.email,
            'managerPhoneNumber': userData['phoneNumber'],
          });
          state._showSuccessDialog(context);
        } else {
          throw 'User phone number not found';
        }
      } else {
        throw 'User not logged in';
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasRestaurantData', true);

      state._showSuccessDialog(context);
    } catch (e) {
      state._showErrorDialog();
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Успех'),
        content: Text('Данные ресторана сохранены успешно!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ошибка'),
        content: Text('Не удалось сохранить данные ресторана.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
