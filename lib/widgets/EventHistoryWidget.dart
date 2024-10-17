import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../models/EventHistory.dart';
import '../models/NotificationId.dart';
import '../models/event.dart';
import '../pages/EventDetailsScreen.dart';
import '../provider/EventProvider.dart';
import 'DateTimeSetterWidget.dart';
import 'EditEventSheet.dart';

class EventHistoryWidget extends StatelessWidget {
  final int eventIdx;

  EventHistoryWidget({super.key, required this.eventIdx});

  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  @override
  Widget build(BuildContext context) {
    Event event =
        Provider.of<EventProvider>(context, listen: false).events[eventIdx];

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Consumer<EventProvider>(builder: (context, eventProvider, child) {
      return Dismissible(
        key: Key(event.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.red[800]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.amber, blurRadius: 10, offset: Offset(0, 3)),
              ]),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        onDismissed: (direction) {
          eventProvider.removeEvent(event);
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(
                          eventIdx: eventIdx,
                        )));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
            foregroundDecoration: RotatedCornerDecoration.withColor(
                color: Colors.purple,
                spanBaselineShift: 4,
                badgeSize: Size(h * 0.075, h * 0.075),
                badgeCornerRadius: const Radius.circular(15),
                badgeShadow:
                    BadgeShadow(color: Colors.grey[300]!, elevation: 10),
                textSpan: const TextSpan(
                  text: "Passed",
                  style: TextStyle(fontSize: 8),
                )),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blueGrey[700]!, Colors.blueGrey[400]!]),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                  color: Colors.white54,
                                  offset: Offset(0.5, 0.5))
                            ])),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(format.format(event.dateTime),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    shadows: const [
                                      Shadow(
                                          color: Colors.white54,
                                          offset: Offset(0.5, 0.5))
                                    ])),
                            (event.needEndDate)
                                ? Text(
                                    format.format(event.endDateTime!),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                      shadows: const [
                                        Shadow(
                                            color: Colors.white54,
                                            offset: Offset(0.5, 0.5))
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        IconButton(
                            icon: const Icon(
                              Icons.restore,
                              color: Color.fromARGB(255, 249, 250, 249),
                            ),
                            onPressed: () {
                              bool isPassed =
                                  eventProvider.checkDateTime(eventIdx);
                              if (isPassed) {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => EditEventSheet(
                                          eventIdx: eventIdx,
                                        ));
                              }
                            }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

List<String> getBiggestNonZeroUnit(DateTime dateTime) {
  List<String> result = ["", ""];
  Duration duration = dateTime.difference(DateTime.now());
  late int timeRemaining;

  if (duration.inDays > 0) {
    timeRemaining = duration.inDays;
    result[0] = timeRemaining.toString();
    result[1] = 'days left';
  } else if (duration.inHours > 0) {
    timeRemaining = duration.inHours;
    result[0] = timeRemaining.toString();
    result[1] = 'hours left';
  } else if (duration.inMinutes > 0) {
    timeRemaining = duration.inMinutes;
    result[0] = timeRemaining.toString();
    result[1] = 'min left';
  } else if (duration.inSeconds > 0) {
    timeRemaining = duration.inSeconds;
    result[0] = timeRemaining.toString();
    result[1] = 'sec left';
  } else {
    result[0] = '0';
    result[1] = "Passed";
  }
  return result;
}

Future<void> _scheduleNotificationsForEvent(Event event) async {
  for (NotificationId notification in event.notifications) {
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
        id: notification.id,
        channelKey: 'countdown_channel',
        title: 'Reminder for ${event.title}',
        body: 'Your event "${event.title}" starts $timeRemaining !',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar.fromDate(date: notification.dateTime),
    );
  }
}

_cancelNotificationsForEvent(Event event) {
  for (NotificationId notification in event.notifications) {
    AwesomeNotifications().cancel(notification.id);
  }
}
