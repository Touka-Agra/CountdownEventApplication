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

  Event(
      {
       this.endDateTime,
      required this.title,
      required this.details,
      required this.dateTime,
      required this.needEndDate,
      required this.needNotify,
      required this.notifications,
      });

        // Factory constructor to create an Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Cast to Map
    return Event(
      title: data['title'] ?? '',
      details: data['details'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
      endDateTime: data['endDateTime'] != null
          ? (data['endDateTime'] as Timestamp).toDate()
          : null, // Handle optional end date
      needEndDate: data['needEndDate'] ?? false,
      needNotify: data['needNotify'] ?? false,
      notifications: List.from(data['notifications'] ?? []),
    );
  }
}

