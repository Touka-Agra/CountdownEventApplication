import 'package:flutter/cupertino.dart';

class DateTimeProvider extends ChangeNotifier{
  DateTime dateTime=DateTime.now();

  setDate(DateTime newDate){
    dateTime = DateTime(
        newDate.year,
        newDate.month,
        newDate.day);

    notifyListeners();
  }

  setTime(DateTime newTime){
    dateTime = DateTime(
        newTime.hour,
        newTime.minute);
    notifyListeners();
  }


}