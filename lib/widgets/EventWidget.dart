import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/NotificationId.dart';
import '../models/event.dart';
import '../pages/EventDetailsScreen.dart';
import '../provider/EventProvider.dart';

class EventWidget extends StatelessWidget {
  final int eventIdx;

  EventWidget({super.key, required this.eventIdx});

  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  @override
  Widget build(BuildContext context) {
    Event event =
        Provider.of<EventProvider>(context, listen: false).events[eventIdx];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<EventProvider>(builder: (context, eventProvider, child) {
        return Dismissible(
          key: Key(eventIdx.toString()),
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
                      color: Colors.amber,
                      blurRadius: 10,
                      offset: Offset(0, 3)),
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
            _cancelNotificationsForEvent(event);
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
              padding: const EdgeInsets.all(15),
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
                        children: [
                          IconButton(
                            onPressed: () {
                              eventProvider.needNotifyToggle(
                                  eventIdx: eventIdx);
                              if (eventProvider.events[eventIdx].needNotify) {
                                _scheduleNotificationsForEvent(event);
                              } else {
                                _cancelNotificationsForEvent(event);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.white24),
                              shape:
                                  WidgetStateProperty.all(const CircleBorder()),
                            ),
                            icon: Icon(
                              event.needNotify
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: Colors.purple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 5),
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
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: const VerticalDivider(
                              color: Colors.black,
                              thickness: 2,
                            )),
                      ),
                      Column(
                        children: [
                          Text(
                              "${(event.dateTime.difference(DateTime.now())).inDays}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                          const Text("days left",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

Future<void> _scheduleNotificationsForEvent(Event event) async {
  for (NotificationId notification in event.notifications) {
    Duration duration = event.dateTime.difference(DateTime.now());

    late String timeRemaining;

    if (duration.inDays > 0) {
      timeRemaining = 'in ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
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
