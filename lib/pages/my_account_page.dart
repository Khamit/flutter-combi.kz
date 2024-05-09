import 'package:avatar_view/avatar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:combi/components/my_button.dart';
import 'package:combi/pages/home_page.dart';
import 'package:combi/pages/my_account_change_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  // Image
  
  // Поддержка файрбейс
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _currentUser;
  Map<String, dynamic> _userData = {}; // Initialize with an empty map
  String _userRole = ''; // Initialize user role

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _getUserData();
    _updateImageAssetPath(); // Call _updateImageAssetPath here
    _imageAssetPath = ValueNotifier<String>(''); // Initialize _imageAssetPath
    
  }



Future<void> _getUserData() async {
  DocumentSnapshot userData =
      await _firestore.collection('Users').doc(_currentUser.uid).get();
  setState(() {
    _userData = userData.data() as Map<String, dynamic>;
     _userRole = _userData['role'] ?? ''; // Assuming 'role' is the key for user role
    // Call _updateImageAssetPath here
    _updateImageAssetPath();
  });
}


  Future<void> _updateUserData() async {
    // Navigate to the update page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyAccountPage()),
    );
  }

Future<void> _updateImageAssetPath() async {
  String gender = _userData['gender'] ?? '';
  int age = _userData['age'] ?? 0;
  

  String imagePath = ''; // Initialize imagePath with a default value

  if (age > 30) {
    if (gender.toLowerCase() == 'мужчина') {
      imagePath = 'assets/images/users/oldMan1.png';
    } else if (gender.toLowerCase() == 'женщина') {
      imagePath = 'assets/images/users/oldWoman2.png';
    }
  } else {
    if (gender.toLowerCase() == 'мужчина') {
      imagePath = 'assets/images/users/youngBoy1.png';
    } else if (gender.toLowerCase() == 'женщина') {
      imagePath = 'assets/images/users/youngGirl2.png';
    }
  }

  // Update _imageAssetPath value
  _imageAssetPath.value = imagePath;


  return Future.value(); // Return a completed future
}

  // Remaining methods...
Color getBorderColor(String userRole) {
  switch (userRole) {
    case 'user':
      return Colors.green;
    case 'manager':
      return Colors.blue;
    case 'admin':
      return Colors.red;
    default:
      return Colors.black; // Default color if role is unknown
  }
}


  ValueNotifier<String> _imageAssetPath = ValueNotifier<String>('');
  
  // Тело Страницы здесь тут и картинки

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      title: Text('Мой Аккаунт'),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.home),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage())),
      ),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          alignment: Alignment.center,
          child: ValueListenableBuilder<String>(
            valueListenable: _imageAssetPath,
            builder: (context, imageAssetPath, child) {
              if (imageAssetPath.isNotEmpty) {
                // Ensure that the imageAssetPath is correctly set
                return AvatarView(
                  radius: 60,
                  borderWidth: 8,
                  borderColor:  getBorderColor(_userRole), // Use user role for border color // Use the function to get the border color
                  avatarType: AvatarType.CIRCLE,
                  backgroundColor: Colors.black,
                  imagePath: imageAssetPath,
                  placeHolder: Container(
                    child: Icon(Icons.person, size: 10,),
                  ),
                  errorWidget: Container(
                    child: Icon(Icons.error, size: 10,),
                  ),
                );
              } else if (_userData.isEmpty) {
                // Display an icon when _userData is empty
                return CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey, // Customize the color as needed
                  child: Icon(Icons.person, size: 50, color: Colors.white), // Icon to display
                );
              } else {
                // Display a message when no profile picture is found
                return Text(
                  'Picture cant displayed',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                );
              }
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoTile('Имя', _userData['name'] ?? ''),
                  SizedBox(height: 16.0),
                  _buildInfoTile('Почта', _currentUser.email ?? ''),
                  SizedBox(height: 16.0),
                  _buildInfoTile('Номер телефона', _userData['phoneNumber'] ?? ''),
                  SizedBox(height: 16.0),
                  _buildInfoTile('Возраст', _userData['age'].toString()),
                  SizedBox(height: 16.0),
                  _buildInfoTile('Пол', _userData['gender'] ?? ''),
                  
                  
                  // Conditionally display additional information for manager role
                  if (_userRole == 'manager') ...[
                    SizedBox(height: 16.0),
                    _buildInfoTile('Роль', _userData['role'] ?? ''),
                  ],
                  SizedBox(height: 30.0),
                  MyButton(
                    text: 'Изменить',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyAccountChangePage()));
                    },
                  ),
                  SizedBox(height: 16.0),
                  MyButton(
                    text: 'Обновить',
                    onTap: _updateUserData,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildInfoTile(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}