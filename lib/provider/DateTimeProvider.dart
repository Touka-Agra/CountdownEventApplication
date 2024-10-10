import 'package:flutter/material.dart';

class DateTimeProvider extends ChangeNotifier {
  DateTime dateTime = DateTime.now();
  late DateTime endDateTime;

  bool isValidEndDate = true;
  DateTimeProvider() {
    endDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        dateTime.hour, dateTime.minute);
  }
  setDate(DateTime newDate) {
    dateTime = DateTime(newDate.year, newDate.month, newDate.day, dateTime.hour,
        dateTime.minute);

    if (dateTime.isAfter(endDateTime)) setEndDate(dateTime);

    notifyListeners();
  }

  setTime(TimeOfDay newTime) {
    dateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      newTime.hour,
      newTime.minute,
    );

    if (dateTime.isAfter(endDateTime)) setEndTime(newTime);
    notifyListeners();
  }

  setEndDate(DateTime newDate) {
    endDateTime = DateTime(newDate.year, newDate.month, newDate.day,
        endDateTime.hour, endDateTime.minute);

    notifyListeners();
  }

  setEndTime(TimeOfDay newTime) {
    endDateTime = DateTime(
      endDateTime.year,
      endDateTime.month,
      endDateTime.day,
      newTime.hour,
      newTime.minute,
    );

    if (dateTime.isAfter(endDateTime)) {
      isValidEndDate = false;
      return;
    }
    isValidEndDate = true;
    notifyListeners();
  }

  restartDate() {
    dateTime = DateTime.now();
    endDateTime = DateTime.now();
    notifyListeners();
  }
}
