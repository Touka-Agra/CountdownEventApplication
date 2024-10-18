import 'dart:async'; // Import the Timer class
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:countdown_event/models/EventHistory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../models/NotificationId.dart';
import '../models/event.dart';
import '../pages/EventDetailsScreen.dart';
import '../provider/EventProvider.dart';

// ignore: must_be_immutable
class EventWidget extends StatefulWidget {
  // Change to StatefulWidget
  final int eventIdx;

  EventWidget({super.key, required this.eventIdx});

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  Timer? _timer;

  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        Provider.of<EventProvider>(context, listen: false)
            .setIsEnd(widget.eventIdx);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Event event = Provider.of<EventProvider>(context, listen: false)
        .events[widget.eventIdx];

    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          return Dismissible(
            key: Key(event.id),
            direction: DismissDirection.startToEnd,
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

              bool isPassed = eventProvider.checkDateTime(widget.eventIdx);

              EventHistory eventHistoryUpdate = EventHistory(
                  inHistory: true, isPassed: isPassed, reason: "Deleted");
              eventProvider.updateHistoryState(
                  eventIdx: widget.eventIdx,
                  eventHistoryUpdate: eventHistoryUpdate);
            },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EventDetailsScreen(eventIdx: widget.eventIdx)));
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                foregroundDecoration: event.needEndDate
                    ? RotatedCornerDecoration.withColor(
                        color: Colors.purple[400]!,
                        spanBaselineShift: 4,
                        badgeSize: Size(h * 0.075, h * 0.075),
                        badgeCornerRadius: const Radius.circular(15),
                        badgeShadow: BadgeShadow(
                            color: Colors.grey[300]!, elevation: 10),
                        textSpan: TextSpan(
                          text: !eventProvider.events[widget.eventIdx].isEnd
                              ? "Before Start"
                              : "Before End",
                          style: const TextStyle(fontSize: 8),
                        ))
                    : null,
                decoration: BoxDecoration(
                    color: event.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 3)),
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                shadows: [
                                  Shadow(
                                      color: Colors.white54,
                                      offset: Offset(0.5, 0.5))
                                ]),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  eventProvider.needNotifyToggle(
                                      eventIdx: widget.eventIdx);
                                  if (eventProvider
                                      .events[widget.eventIdx].needNotify) {
                                    _scheduleNotificationsForEvent(event);
                                  } else {
                                    _cancelNotificationsForEvent(event);
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.white24),
                                  shape: WidgetStateProperty.all(
                                      const CircleBorder()),
                                ),
                                icon: Icon(
                                  event.needNotify
                                      ? Icons.notifications_active
                                      : Icons.notifications_off,
                                  color: Colors.purple[300],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(format.format(event.dateTime),
                                      style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          color: Colors.grey[100],
                                          fontSize: 12,
                                          shadows: const [
                                            Shadow(
                                                color: Colors.white54,
                                                offset: Offset(0.5, 0.5))
                                          ])),
                                  (event.needEndDate)
                                      ? Text(
                                          "to: ${format.format(event.endDateTime!)}",
                                          style: TextStyle(
                                            //fontWeight: FontWeight.bold,
                                            color: Colors.grey[100],
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
                            ],
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: VerticalDivider(
                                      color: Colors.white70, thickness: 2)),
                            ),
                            Consumer<EventProvider>(
                              builder: (context, eventProvider, child) {
                                DateTime? countdownDateTime =
                                    !eventProvider.events[widget.eventIdx].isEnd
                                        ? event.dateTime
                                        : event.endDateTime;

                                if (eventProvider
                                    .checkDateTime(widget.eventIdx)) {
                                  EventHistory eventHistoryUpdate =
                                      EventHistory(
                                          inHistory: true,
                                          isPassed: true,
                                          reason: "Passed");

                                  Provider.of<EventProvider>(context,
                                          listen: false)
                                      .updateHistoryState(
                                          eventIdx: widget.eventIdx,
                                          eventHistoryUpdate:
                                              eventHistoryUpdate);

                                  return const Column(
                                    children: [
                                      Text("0",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25)),
                                      Text("Passed",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ],
                                  );
                                }

                                List<String> remainingTime =
                                    getBiggestNonZeroUnit(countdownDateTime!);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(remainingTime[0],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25)),
                                    Text(remainingTime[1],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

void _cancelNotificationsForEvent(Event event) {
  for (NotificationId notification in event.notifications) {
    AwesomeNotifications().cancel(notification.id);
  }
}
