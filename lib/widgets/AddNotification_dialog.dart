import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/DateTimeProvider.dart';
import '../provider/EventProvider.dart';

class AddNotificationDialog extends StatefulWidget {
  late DateTime eventDate;
  int eventIdx;
  AddNotificationDialog({super.key, required this.eventDate, required this.eventIdx});

  @override
  State<AddNotificationDialog> createState() => _AddNotificationDialogState();
}

class _AddNotificationDialogState extends State<AddNotificationDialog> {
  final List<String> _unitList = ["Months", "Weeks", "Days", "Hours"];

  late DateTime date;
  late DateTime notificationDate;

  @override
  void initState() {
    super.initState();
    date = widget.eventDate;
    notificationDate = date;
  }

  String _selectedUnit = "Months";
  int _selectedTime = 1;

  List<int> _generateTimeList(String unit) {
    int timeDiff = 0;

    final dateNow = DateTime.now();
    switch (unit) {
      case "Months":
        timeDiff = date.month - dateNow.month + 12 * (date.year - dateNow.year);
        break;
      case "Weeks":
        timeDiff = date.difference(dateNow).inDays ~/ 7;
        break;
      case "Days":
        timeDiff = date.difference(dateNow).inDays;
        break;
      case "Hours":
        timeDiff = date.difference(dateNow).inHours;
        break;
    }

    return List<int>.generate(timeDiff, (i) => i + 1); // Start from 1
  }

  DateFormat f = DateFormat('MMM d, y - hh:mm a');

  _calculateNotifyDate() {
    final dateNow = DateTime.now(); // Current date

    // Reset notification date to the event date before calculating again
    notificationDate = date;

    switch (_selectedUnit) {
      case "Months":
        notificationDate = DateTime(
          date.year,
          date.month - _selectedTime,
          date.day,
          date.hour,
          date.minute,
        );
        break;
      case "Weeks":
        notificationDate = date.subtract(Duration(days: _selectedTime * 7));
        break;
      case "Days":
        notificationDate = date.subtract(Duration(days: _selectedTime));
        break;
      case "Hours":
        notificationDate = date.subtract(Duration(hours: _selectedTime));
        break;
    }

    // Ensure the notification date is not in the past
    if (notificationDate.isBefore(dateNow)) {
      notificationDate = dateNow;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<int>> notifyDates = {
      "Months": _generateTimeList("Months"),
      "Weeks": _generateTimeList("Weeks"),
      "Days": _generateTimeList("Days"),
      "Hours": _generateTimeList("Hours"),
    };
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 15),
              child: Text(
                "Event Date: ${f.format(date)}",
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                          itemExtent: 50.0,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedTime = notifyDates[_selectedUnit]![
                                  index]; // Fix here
                              _calculateNotifyDate();
                            });
                          },
                          children: notifyDates[_selectedUnit]!.map((int time) {
                            return Center(
                              child: Text("$time"),
                            );
                          }).toList()),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                          itemExtent: 50.0,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedUnit = _unitList[index];
                              _calculateNotifyDate();
                            });
                          },
                          children: notifyDates.keys.map((String unit) {
                            return Center(
                              child: Text(unit),
                            );
                          }).toList()),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    "Notify on: ${f.format(notificationDate)}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Provider.of<EventProvider>(context, listen: false)
                      .addNotification(
                          eventIdx: widget.eventIdx,
                          notificationDate: notificationDate);
                },
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                    backgroundColor: WidgetStateProperty.all(Colors.purple)),
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
