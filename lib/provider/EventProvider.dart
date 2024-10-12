import 'package:flutter/material.dart';

import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> events = [];
  List<DateTime> notifications = [];

  addEvent(Event newEvent) {
    events.add(newEvent);
    notifyListeners();
  }

  removeEvent(Event event) {
    events.remove(event);
    notifyListeners();
  }

  setNotifications(
      {required int eventIdx, required List<DateTime> notifications}) {
    events[eventIdx].notifications.clear();
    events[eventIdx].notifications.addAll(notifications);

    notifyListeners();
  }

  addNotification({required int eventIdx, required DateTime notificationDate}) {
    events[eventIdx].notifications.add(notificationDate);
    notifyListeners();
  }

  removeNotification(
      {required int eventIdx, required DateTime notificationDate}) {
    events[eventIdx].notifications.remove(notificationDate);
    notifyListeners();
  }

  clearNotification({required int eventIdx}) {
    events[eventIdx].notifications.clear();
    notifyListeners();
  }

  List<DateTime> getNotifications({required int eventIdx}) {
    return events[eventIdx].notifications;
  }

  setNeedEndDate() {
    notifyListeners();
  }
}
