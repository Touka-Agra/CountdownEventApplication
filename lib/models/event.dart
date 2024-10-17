import 'package:cloud_firestore/cloud_firestore.dart';

import 'NotificationId.dart';

class Event {
  String title;
  String details;
  bool needEndDate;
  DateTime dateTime;
  DateTime ?endDateTime = DateTime(0);
  List<NotificationId> notifications = [];
  bool needNotify;
  bool isEnd = false;

  String id;

  Event(
      {
       this.endDateTime,
      required this.title,
      required this.details,
      required this.dateTime,
      required this.needEndDate,
      required this.needNotify,
      required this.notifications, 
      required this. id,
      });

 
}

