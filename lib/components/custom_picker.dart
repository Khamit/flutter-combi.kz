import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
// Выбор даты как в айфоне
class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({required DateTime currentTime, required LocaleType locale})
      : super(locale: locale) {
    this.currentTime = currentTime;
    setLeftIndex(this.currentTime.day - 1);
    setMiddleIndex(this.currentTime.month - 1);
    setRightIndex(this.currentTime.year - 1900); // Adjust the year accordingly
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < 31) {
      return digits(index + 1, 2); // Day
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 12) {
      return digits(index + 1, 2); // Month
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    int year = 1900 + index; // Calculate the year based on the index
    return digits(year, 2); // Return the string representation of the year
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 2]; // Day, Month, Year
  }

  @override
  DateTime finalTime() {
    int year = currentRightIndex() + 1900;
    int month = currentMiddleIndex() + 1;
    int day = currentLeftIndex() + 1;
    return DateTime(year, month, day);
  }
}
