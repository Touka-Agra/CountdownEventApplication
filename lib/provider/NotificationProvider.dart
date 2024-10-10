import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  List<DateTime> notifications = [];
  bool wantNotify = true;

  addNotification(DateTime notification) {
    notifications.add(notification);
    notifyListeners();
  }

  removeNotification(DateTime notification) {
    notifications.remove(notification);
    notifyListeners();
  }

}
