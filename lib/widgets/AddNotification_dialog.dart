import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../provider/EventProvider.dart';

// ignore: must_be_immutable
class AddNotificationDialog extends StatefulWidget {
  late DateTime eventDate;
  int eventIdx;
  AddNotificationDialog(
      {super.key, required this.eventDate, required this.eventIdx});

  @override
  State<AddNotificationDialog> createState() => _AddNotificationDialogState();
}

class _AddNotificationDialogState extends State<AddNotificationDialog> {
  final List<String> _unitList = [
    "Months",
    "Weeks",
    "Days",
    "Hours",
    "Minutes"
  ];

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
      case "Minutes":
        timeDiff = date.difference(dateNow).inMinutes;
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
      case "Minutes":
        notificationDate = date.subtract(Duration(minutes: _selectedTime));
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
      "Minutes": _generateTimeList("Minutes"),
    };
    return Dialog(
      backgroundColor: Colors.white,
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
                    color: Colors.black),
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
                      color: Provider.of<EventProvider>(context, listen: false)
                          .events[widget.eventIdx]
                          .backgroundColor,
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
                onPressed: () async {
                  Navigator.pop(context);

                  int uniqueId =
                      DateTime.now().millisecondsSinceEpoch.remainder(100000);

                  Provider.of<EventProvider>(context, listen: false)
                      .addNotification(
                          eventIdx: widget.eventIdx,
                          notificationDate: notificationDate,
                          uniqueId: uniqueId);

                  Event event =
                      Provider.of<EventProvider>(context, listen: false)
                          .events[widget.eventIdx];

                  _scheduleNotification(
                      uniqueId: uniqueId,
                      notificationDate: notificationDate,
                      event: event);
                },
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                    backgroundColor:
                        WidgetStateProperty.all(Colors.purple[400])),
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

Future<void> _scheduleNotification(
    {required DateTime notificationDate,
    required int uniqueId,
    required Event event}) async {
  Duration duration = event.dateTime.difference(DateTime.now());

  late String timeRemaining;

  if (duration.inDays > 0) {
    timeRemaining =
        'in ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
  } else if (duration.inHours > 0) {
    timeRemaining =
        'in ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
  } else if (duration.inMinutes > 0) {
    timeRemaining =
        'in ${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
  } else {
    timeRemaining = 'now';
  }

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: uniqueId,
      channelKey: 'countdown_channel',
      title: 'Reminder for ${event.title}',
      body: 'Your event "${event.title}" starts $timeRemaining!',
      notificationLayout: NotificationLayout.Default,
      wakeUpScreen: true,
    ),
    schedule: NotificationCalendar(
      year: notificationDate.year,
      month: notificationDate.month,
      day: notificationDate.day,
      hour: notificationDate.hour,
      minute: notificationDate.minute,
    ),
  );
}
