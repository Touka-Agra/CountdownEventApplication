import 'package:countdown_event/provider/EventProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../provider/DateTimeProvider.dart';
import '../provider/NotificationProvider.dart';
import 'AddNotification_dialog.dart';

class NotificationWidget extends StatefulWidget {
  int? eventIdx;
  NotificationWidget({super.key, this.eventIdx});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  bool wantNotify = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Opacity(
        opacity: wantNotify ? 1.0 : 0.5,
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
                      value: (wantNotify),
                      onChanged: (value) {
                        setState(() {
                          wantNotify = value;
                        });
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
                ignoring: !wantNotify,
                child: Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                  if (widget.eventIdx != null) {
                    List<DateTime> eventNotifications =
                        Provider.of<EventProvider>(context, listen: false)
                            .getNotifications(eventIdx: widget.eventIdx!);
                    notificationProvider.setNotifications(eventNotifications);
                  }

                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notificationProvider.notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotification(
                            notificationProvider.notifications[index]);
                      });
                }),
              ),
            ),

            //add Notification Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: IgnorePointer(
                ignoring: !wantNotify,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AddNotificationDialog(
                              eventDate: widget.eventIdx!=null?Provider.of<EventProvider>(context, listen: false).events[widget.eventIdx!].dateTime:Provider.of<DateTimeProvider>(context, listen: false).dateTime
                            ));
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                      backgroundColor: WidgetStateProperty.all(Colors.purple)),
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
      ),
    );
  }
}

Widget _buildNotification(DateTime notificationDate) {
  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
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
                format.format(notificationDate),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: () {
                notificationProvider.removeNotification(notificationDate);
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
