import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:countdown_event/provider/EventProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/NotificationId.dart';
import '../models/event.dart';
import 'AddNotification_dialog.dart';

// ignore: must_be_immutable
class NotificationWidget extends StatelessWidget {
  int eventIdx;
  NotificationWidget({super.key, required this.eventIdx});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          return Opacity(
            opacity: (eventIdx >= 0 && eventIdx < eventProvider.events.length && eventProvider.events[eventIdx].needNotify != null) 
  ? (eventProvider.events[eventIdx].needNotify ? 1.0 : 0.5)
  : 0.5,  // Default opacity if invalid index or null

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //notification and icon
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Set Notification",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Switch(
                          value: (eventProvider.events[eventIdx].needNotify),
                          onChanged: (value) {
                            eventProvider.needNotifyToggle(eventIdx: eventIdx);

                            if (value) {
                              _scheduleNotificationsForEvent(
                                  eventProvider.events[eventIdx]);
                            } else {
                              _cancelNotificationsForEvent(
                                  eventProvider.events[eventIdx]);
                            }
                          },
                          activeColor: Colors.purple,
                          thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Icon(Icons.notifications_active);
                            }
                            return null;
                          }))
                    ],
                  ),
                ),

                //notifyList
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IgnorePointer(
                    ignoring: !eventProvider.events[eventIdx].needNotify,
                    child: Consumer<EventProvider>(
                        builder: (context, eventProvider, child) {
                      List<NotificationId> notifications =
                          eventProvider.getNotifications(eventIdx: eventIdx);
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotification(
                                notifications[index], eventIdx);
                          });
                    }),
                  ),
                ),

                //add Notification Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: IgnorePointer(
                    ignoring: !eventProvider.events[eventIdx].needNotify,
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AddNotificationDialog(
                                  eventDate: Provider.of<EventProvider>(context,
                                          listen: false)
                                      .events[eventIdx]
                                      .dateTime,
                                  eventIdx: eventIdx,
                                ));
                      },
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                          backgroundColor:
                              WidgetStateProperty.all(Colors.purple)),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Add Notification",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  )),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _buildNotification(NotificationId notification, int eventIdx) {
  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  return Consumer<EventProvider>(builder: (context, eventProvider, child) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(15),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                format.format(notification.dateTime),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: () {
                int notificationIdx = eventProvider
                    .events[eventIdx].notifications
                    .indexOf(notification);
                AwesomeNotifications().cancel(eventProvider
                    .events[eventIdx].notifications[notificationIdx].id);
                eventProvider.removeNotification(
                    eventIdx: eventIdx, notification: notification);
              },
              icon: const Icon(
                Icons.cancel,
                color: Colors.white,
                size: 25,
              ),
            ),
          ]),
        ));
  });
}

Future<void> _scheduleNotificationsForEvent(Event event) async {
  for (NotificationId notification in event.notifications) {

    Duration duration = event.dateTime.difference(DateTime.now());
    
    late String timeRemaining;

      if (duration.inDays > 0) {
        timeRemaining = 'in ${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
      } else if (duration.inHours > 0) {
        timeRemaining = 'in ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
      } else if (duration.inMinutes > 0) {
        timeRemaining = 'in ${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
      } else {
        timeRemaining = 'now';
      }
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notification.id,
        channelKey: 'countdown_channel',
        title: 'Reminder for ${event.title}',
        body: 'Your event "${event.title}" starts $timeRemaining!',
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
