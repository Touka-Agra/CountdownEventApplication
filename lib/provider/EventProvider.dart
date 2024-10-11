import 'package:flutter/material.dart';

import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> events = [];
  List<String> eventsTitle = [];

  bool addEvent(Event newEvent) {
    bool response = false;
    if (!eventsTitle.contains(newEvent.title)) {
      events.add(newEvent);
      eventsTitle.add(newEvent.title);
      response = true;
      notifyListeners();
    }

    return response;
  }

  removeEvent(Event event) {
    events.remove(event);
    eventsTitle.remove((event.title));
    notifyListeners();
  }

  bool checkTitle(String title) {
    return !eventsTitle.contains(title);
  }

  setNotifications({required int eventIdx, required List<DateTime> notifications}) {
  print('Setting notifications for event: $eventIdx');

  // Ensure you're updating the same list in the event object
  events[eventIdx].notifications.clear();  // Clear the existing list
  events[eventIdx].notifications.addAll(notifications);  // Add all new notifications

  notifyListeners();
}


  List<DateTime> getNotifications({required int eventIdx}) {
    return events[eventIdx].notifications;
  }

  setNeedEndDate() {
    notifyListeners();
  }
}
