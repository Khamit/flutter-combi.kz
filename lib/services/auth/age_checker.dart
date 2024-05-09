import 'package:intl/intl.dart';

class AgeChecker {
  static bool isAdult(String dob) {
    final dateOfBirth = DateFormat("MM-dd-yyyy").parse(dob);
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(
      now.year - 18,
      now.month,
      now.day + 1, // add day to return true on birthday
    );
    return dateOfBirth.isBefore(eighteenYearsAgo);
  }
}