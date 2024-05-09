import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/components/my_textfield.dart';
import 'package:combi/pages/my_account_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountChangePage extends StatefulWidget {
  const MyAccountChangePage({Key? key}) : super(key: key);

  @override
  _MyAccountChangePageState createState() => _MyAccountChangePageState();
}

class _MyAccountChangePageState extends State<MyAccountChangePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _currentUser;
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _getUserData();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userData =
        await _firestore.collection('Users').doc(_currentUser.uid).get();
    setState(() {
      _userData = userData.data() as Map<String, dynamic>;
      _emailController.text = _currentUser.email!;
      _phoneNumberController.text = _userData['phoneNumber'];
      _ageController.text = _userData['age'].toString();
    });
  }

  Future<void> _updateEmail() async {
    try {
      await _currentUser.updateEmail(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update email: $e')),
      );
    }
  }

  Future<void> _updatePassword() async {
    try {
      await _currentUser.updatePassword(_newPwController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      _pwController.clear();
      _newPwController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: $e')),
      );
    }
  }

  Future<void> _updateAllChanges() async {
    await _updateEmail();
    await _updatePassword();
    await _firestore.collection('Users').doc(_currentUser.uid).update({
      'phoneNumber': _phoneNumberController.text,
      'age': int.parse(_ageController.text),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Все изменения успешно внесены в базу')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мой Аккаунт'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // Back button icon
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MyAccountPage())),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyTextField(
              hintText: 'почта',
              obscureText: false,
              age: false,
              gender: false,
              phoneNumber: false,
              isAuthorized: false,
              validator: (p0) {
                return null;
              },
              controller: _emailController,
            ),
            const SizedBox(height: 16.0),
            MyTextField(
              hintText: 'введите текущий пароль',
              controller: _pwController,
              obscureText: true,
              age: false,
              gender: false,
              phoneNumber: false,
              isAuthorized: false,
              validator: (p0) {
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            MyTextField(
              hintText: 'Новый пароль',
              controller: _newPwController,
              age: false,
              gender: false,
              phoneNumber: false,
              isAuthorized: false,
              validator: (p0) {
                return null;
              },
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            MyTextField(
              hintText: 'номер телефона',
              obscureText: false,
              age: false,
              gender: false,
              phoneNumber: false,
              isAuthorized: false,
              validator: (p0) {
                return null;
              },
              controller: _phoneNumberController,
            ),
            const SizedBox(height: 16.0),
            MyTextField(
              hintText: 'Возраст',
              obscureText: false,
              age: false,
              gender: false,
              phoneNumber: false,
              isAuthorized: false,
              validator: (p0) {
                return null;
              },
              controller: _ageController,
            ),
            const SizedBox(height: 16.0),
            MyButton(
              text: 'Изменить',
              onTap: _updateAllChanges,
            ),
          ],
        ),
      ),
    );
  }
}
