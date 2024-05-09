import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon; // Nullable IconData for the icon
  final bool obscureText;
  final bool age;
  final bool gender;
  final bool phoneNumber;
  final bool isAuthorized;
  final String? Function(String?)? validator; // Nullable validator function
  final void Function(String)? onChanged; // Nullable onChanged function
  final void Function(String)?
      onDateSelected; // Nullable onDateSelected function

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.icon, // Add icon parameter
    required this.obscureText,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.isAuthorized,
    this.validator, // Make the validator function nullable
    this.onChanged, // Make the onChanged function nullable
    this.onDateSelected, // Make the onDateSelected function nullable
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? inputFormatters;

    if (phoneNumber) {
      inputFormatters = <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11), // Limit to 11 digits
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Stack(
        children: [
          TextField(
            obscureText: obscureText,
            readOnly: age || gender,
            inputFormatters: inputFormatters,
            onTap: () {
              if (age) {
                _showDateTimePicker(context);
              } else if (gender) {
                _showGenderDialog(context);
              }
              if (age || gender) {
                FocusScope.of(context).unfocus();
              }
            },
            onChanged: onChanged, // Call the onChanged callback
            decoration: InputDecoration(
              // Optional: Add leading icon
              prefixIcon: icon != null ? Icon(icon) : null,
              // Optional: Add border around TextField
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            controller: controller, // Assign controller here
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) {
    picker.DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900),
      maxTime: DateTime.now(),
      onChanged: (date) {},
      onConfirm: (date) {
        // Format the selected date to display only the date component
        String formattedDate = DateFormat('dd-MM-yyyy').format(date);
        // Call the callback function to pass the selected date to the parent widget
        if (onDateSelected != null) {
          onDateSelected!(formattedDate);
        }
        // Update the text field's value with the formatted date
        controller.text = formattedDate;
      },
      currentTime: DateTime.now(),
      locale: picker.LocaleType.ru,
    );
  }

  void _showGenderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Укажите пол'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Мужчина'),
                onTap: () {
                  // Update the text field with "Man" when tapped
                  controller.text = 'Мужчина';
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                title: Text('Женщина'),
                onTap: () {
                  // Update the text field with "Woman" when tapped
                  controller.text = 'Женщина';
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
