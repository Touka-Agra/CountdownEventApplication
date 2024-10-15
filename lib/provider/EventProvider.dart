import 'package:flutter/material.dart';

import '../models/NotificationId.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> events = [];

  addEvent(Event newEvent) {
    events.add(newEvent);
    notifyListeners();
  }

  removeEvent(Event event) {
    events.remove(event);
    notifyListeners();
  }

  addNotification(
      {required int eventIdx,
      required DateTime notificationDate,
      required int uniqueId}) {
    events[eventIdx]
        .notifications
        .add(NotificationId(dateTime: notificationDate, id: uniqueId));
    notifyListeners();
  }

  removeNotification(
      {required int eventIdx, required NotificationId notification}) {
    events[eventIdx].notifications.remove(notification);
    notifyListeners();
  }

  List<NotificationId> getNotifications({required int eventIdx}) {
    return events[eventIdx].notifications;
  }

  needNotifyToggle({required int eventIdx}) {
    events[eventIdx].needNotify = !events[eventIdx].needNotify;
    notifyListeners();
  }

  setIsEnd(int eventIdx) {
    events[eventIdx].isEnd = (events[eventIdx].needEndDate &&
       events[eventIdx].dateTime.isBefore(DateTime.now()) &&
      events[eventIdx].endDateTime.isAfter(DateTime.now()));
    notifyListeners();
  }

  setNeedEndDate() {
    notifyListeners();
  }
}
