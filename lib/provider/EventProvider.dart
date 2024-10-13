import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/NotificationId.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> events = [];
  bool needEndDate = false;
  bool addEvent(Event newEvent) {
    bool response = false;
    if (!events.any((event) => event.title == newEvent.title)) {
      events.add(newEvent);
      response = true;
      notifyListeners();

      FirebaseFirestore.instance.collection('events').add({
        'title': newEvent.title,
        'description': newEvent.details,
        'date': newEvent.dateTime.toIso8601String(),
      }).then((value) {
        print("Event Added to Firestore");
      }).catchError((error) {
        print("Failed to add event: $error");
      });
    }
    return response;
  }

  void removeEvent(Event event) {
    events.remove(event);
    notifyListeners();

    FirebaseFirestore.instance
        .collection('events')
        .where('title', isEqualTo: event.title)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete().then((_) {
          print("Event deleted from Firestore");
        }).catchError((error) {
          print("Error deleting event: $error");
        });
      }
    });

    void addNotification({
      required int eventIdx,
      required DateTime notificationDate,
      required int uniqueId,
    }) {
      events[eventIdx]
          .notifications
          .add(NotificationId(dateTime: notificationDate, id: uniqueId));
      notifyListeners();

      FirebaseFirestore.instance
          .collection('events')
          .doc(events[eventIdx].title)
          .update({
        'notifications': FieldValue.arrayUnion([
          {
            'dateTime': notificationDate.toIso8601String(),
            'id': uniqueId,
          }
        ])
      }).then((_) {
        print("Notification added");
      }).catchError((error) {
        print("Failed to add notification: $error");
      });
    }

    void removeNotification({
      required int eventIdx,
      required NotificationId notification,
    }) {
      events[eventIdx].notifications.remove(notification);
      notifyListeners();

      FirebaseFirestore.instance
          .collection('events')
          .doc(events[eventIdx].title)
          .update({
        'notifications': FieldValue.arrayRemove([
          {
            'dateTime': notification.dateTime.toIso8601String(),
            'id': notification.id,
          }
        ])
      }).then((_) {
        print("Notification removed from Firestore");
      }).catchError((error) {
        print("Failed to remove notification: $error");
      });
    }

    List<NotificationId> getNotifications({required int eventIdx}) {
      return events[eventIdx].notifications;
    }

    needNotifyToggle({required int eventIdx}) {
      events[eventIdx].needNotify = !events[eventIdx].needNotify;
      notifyListeners();
    }

    void toggleNeedEndDate(int eventIndex) {
      events[eventIndex].needEndDate = !events[eventIndex].needEndDate;
      notifyListeners();

      FirebaseFirestore.instance
          .collection('events')
          .doc(events[eventIndex].title)
          .update({
        'needEndDate': events[eventIndex].needEndDate,
      }).then((_) {
        print("needEndDate toggled in Firestore");
      }).catchError((error) {
        print("Failed to toggle needEndDate: $error");
      });
    }
  }
}
