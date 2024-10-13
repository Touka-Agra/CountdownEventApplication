import 'package:flutter/material.dart';

import 'NotificationId.dart';

class Event {
  String title;
  String details;
  bool needEndDate;
  DateTime dateTime;
  DateTime endDateTime = DateTime(0);
  List<NotificationId> notifications = [];
  bool needNotify;

  Event({
    required this.title,
    required this.details,
    required this.dateTime,
    required this.needEndDate,
    required this.needNotify,
  });
}
