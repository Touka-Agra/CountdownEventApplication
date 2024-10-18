import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_event/models/EventHistory.dart';
import 'package:flutter/material.dart';

import 'NotificationId.dart';

class Event {
  final Color backgroundColor;
  String title;
  String details;
  bool needEndDate;
  DateTime dateTime;
  DateTime? endDateTime = DateTime(0);
  List<NotificationId> notifications = [];
  bool needNotify;
  bool isEnd = false;

  String id;

  EventHistory eventHistory;

  Event(
      {
      this.backgroundColor = Colors.blue,
      this.endDateTime,
      required this.title,
      required this.details,
      required this.dateTime,
      required this.needEndDate,
      required this.needNotify,
      required this.notifications,
      required this.id,
      required this.eventHistory});
}
