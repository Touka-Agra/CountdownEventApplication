import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/NotificationId.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> events = [];
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool needEndDate = false;

  // Add event and save to Firestore
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

  // Remove event and delete from Firestore
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
  }

  // Add notification to event and Firestore
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

  // Remove notification from event and Firestore
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

  // Get notifications for an event
  List<NotificationId> getNotifications({required int eventIdx}) {
    return events[eventIdx].notifications;
  }

  // Toggle needNotify for event
  void needNotifyToggle({required int eventIdx}) {
    events[eventIdx].needNotify = !events[eventIdx].needNotify!;
    notifyListeners();
  }

  // Toggle needEndDate and update in Firestore
  void toggleNeedEndDate(int eventIndex) {
    events[eventIndex].needEndDate = !events[eventIndex].needEndDate!;
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

  // Set selected date
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Get events of selected date
  List<Event> get eventsOfSelectedDate =>
      events.where((event) => event.dateTime.day == _selectedDate.day).toList();

  // Edit event details
  void editEvent(Event newEvent, Event oldEvent) {
    final index = events.indexWhere((event) => event == oldEvent);
    if (index != -1) {
      events[index] = newEvent;
      notifyListeners();

      FirebaseFirestore.instance
          .collection('events')
          .doc(oldEvent.title)
          .update({
        'title': newEvent.title,
        'description': newEvent.details,
        'date': newEvent.dateTime.toIso8601String(),
      }).then((_) {
        print("Event updated in Firestore");
      }).catchError((error) {
        print("Failed to update event: $error");
      });
    }
  }

  void fetchEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    events = snapshot.docs.map((doc) {
      return Event(
        needEndDate: doc['needEndDate'],
        needNotify: doc['needNotify'],
        title: doc['title'],
        details: doc['description'],
        dateTime: DateTime.parse(doc['date']),
        notifications: (doc['notifications'] ?? []).map<NotificationId>((n) {
          return NotificationId(
            dateTime: DateTime.parse(n['dateTime']),
            id: n['id'],
          );
        }).toList(),
      );
    }).toList();
    notifyListeners();
  }
}
