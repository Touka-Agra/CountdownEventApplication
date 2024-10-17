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
  // Add the event locally to your list and notify listeners
  events.add(event);
  notifyListeners();

  print(event.endDateTime);

  // Add the event to Firestore, and store the document reference to get the generated ID
  return FirebaseFirestore.instance.collection('events').add({
    // Initially, no event ID since Firestore will generate it
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
  }).then((docRef) async {
    // Firestore generated document ID
    String generatedId = docRef.id;
    print("Event Added with ID: $generatedId");

    // Update the event ID locally
    event.id = generatedId;

    // Optionally, update the event in Firestore with the generated event ID
    await docRef.update({'id': generatedId});

    // Call fetchEvents to update the local list of events
    fetchEvents();
  }).catchError((error) {
    print("Failed to add event: $error");
  });
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

 Future fetchEvents() async {
    try {
      if (events.isEmpty) {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('events').get();

        events = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print(data['title']);
          Event event = Event(
            title: data['title'],
            details: data['description'],
            dateTime: (data['date'] as Timestamp).toDate(),
            notifications:
                (data['notifications'] ?? []).map<NotificationId>((n) {
              return NotificationId(
                dateTime: (n['dateTime'] as Timestamp).toDate(),
                id: n['id'],
              );
            }).toList(),
            needEndDate: data['needEndDate'],
            needNotify: data['needNotify'],
            id: doc.id, 
          );
          if (event.needEndDate) {
            event.endDateTime = (data['endDate'] as Timestamp).toDate();
          }
          return event;
        }).toList();
        print(events.length);

        notifyListeners();
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
 }

  void setNeedEndDate(bool needEndDate) {}
    List<NotificationId> getNotifications({required int eventIdx}) {
    return events[eventIdx].notifications;
  }
}
