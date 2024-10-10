import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  List<DateTime> notifications = [];

  addNotification(DateTime notification) {
    notifications.add(notification);
    notifyListeners();
  }

  removeNotification(DateTime notification) {
    notifications.remove(notification);
    notifyListeners();
  }

  bool wantNotifyToggle(bool eventWantNotify) {
    return !eventWantNotify;
  }

  setWantNotify() {
    notifyListeners();
  }


}
