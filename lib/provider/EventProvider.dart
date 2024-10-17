import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/NotificationId.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> events = [];
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool needEndDate = false;
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  EventProvider() {
    fetchEvents(); // Fetch events when the provider is created
  }

  // Add event and save to Firestore
  Future<void> addEvent(Event event) async {
    try {
      final docRef = await eventsCollection.add({
        'title': event.title,
        'description': event.details,
        'date': event.dateTime,
        'endDate': event.endDateTime,
        'needEndDate': event.needEndDate,
        'needNotify': event.needNotify,
        'notifications': event.notifications
            .map((notification) => {
                  'dateTime': notification.dateTime,
                  'id': notification.id,
                })
            .toList(),
      });

      events.add(event);
      notifyListeners();
      print("Event Added with ID: ${docRef.id}");
      fetchEvents();
    } catch (error) {
      print("Failed to add event: $error");
    }
  }

  // Remove event by document ID instead of title
  Future<void> removeEvent(Event event) async {
    try {
      await eventsCollection.doc(event.id).delete();
      events.remove(event);
      notifyListeners();
      print("Event removed");
    } catch (error) {
      print("Failed to remove event: $error");
    }
  }

  // Add notification to an event
  void addNotification(
      {required int eventIdx,
      required DateTime notificationDate,
      required int uniqueId}) {
    events[eventIdx]
        .notifications
        .add(NotificationId(dateTime: notificationDate, id: uniqueId));
    notifyListeners();

    FirebaseFirestore.instance
        .collection('events')
        .doc(events[eventIdx].id) // Use event ID instead of title
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

  // Remove notification from an event
  void removeNotification({
    required int eventIdx,
    required NotificationId notification,
  }) {
    events[eventIdx].notifications.remove(notification);
    notifyListeners();

    FirebaseFirestore.instance
        .collection('events')
        .doc(events[eventIdx].id) // Use event ID instead of title
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

  // Toggle needNotify property
  void needNotifyToggle({required int eventIdx}) {
    events[eventIdx].needNotify = !events[eventIdx].needNotify!;
    notifyListeners();
  }

  // Toggle needEndDate and update Firestore
  void toggleNeedEndDate(int eventIndex) {
    events[eventIndex].needEndDate = !events[eventIndex].needEndDate!;
    notifyListeners();

    FirebaseFirestore.instance
        .collection('events')
        .doc(events[eventIndex].id) // Use event ID instead of title
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

  // Set whether event has ended
  setIsEnd(int eventIdx) {
    events[eventIdx].isEnd = (events[eventIdx].needEndDate &&
        events[eventIdx].dateTime.isBefore(DateTime.now()) &&
        events[eventIdx].endDateTime!.isAfter(DateTime.now()));
    notifyListeners();
  }

  // Get events for the selected date
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
          .doc(oldEvent.id) // Use event ID instead of title
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

  // Fetch events from Firestore
  Future<void> fetchEvents() async {
    try {
      final snapshot = await eventsCollection.get();

      if (snapshot.docs.isEmpty) {
        events = [];
        notifyListeners();
        return;
      }

      events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event(
          id: doc.id, // Assign Firestore document ID to the event
          title: data['title'] ?? '',
          details: data['description'] ?? '',
          dateTime: (data['date'] as Timestamp).toDate(),
          endDateTime: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          needEndDate: data['needEndDate'] ?? false,
          needNotify: data['needNotify'] ?? false,
          notifications: List<NotificationId>.from(
            (data['notifications'] ?? []).map((notification) => NotificationId(
                  dateTime: (notification['dateTime'] as Timestamp).toDate(),
                  id: notification['id'] ?? '',
                )),
          ),
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      print("Failed to fetch events: $error");
    }
  }

  void setNeedEndDate(bool needEndDate) {}
    List<NotificationId> getNotifications({required int eventIdx}) {
    return events[eventIdx].notifications;
  }
}
