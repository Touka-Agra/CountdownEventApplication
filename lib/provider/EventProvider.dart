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
 Future<void> addEvent(Event event) {
  return FirebaseFirestore.instance.collection('events').add({
    'title': event.title,
    'description': event.details,
    'date': event.dateTime,  
    'endDate': event.endDateTime,  
    'needEndDate': event.needEndDate, 
    'needNotify': event.needNotify,   
    'notifications': event.notifications.map((notification) => {
      'dateTime': notification.dateTime, 
      'id': notification.id,
    }).toList(),
  }).then((value) {
    print("Event Added");
    fetchEvents();  
  }).catchError((error) {
    print("Failed to add event: $error");
  });
}


 
  void removeEvent(Event event) {
    events.remove(event);
    notifyListeners();
  }

  addNotification({required int eventIdx, required DateTime notificationDate, required int uniqueId}) {
    events[eventIdx].notifications.add(NotificationId(dateTime: notificationDate, id:uniqueId));
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

  
  void needNotifyToggle({required int eventIdx}) {
    events[eventIdx].needNotify = !events[eventIdx].needNotify!;
    notifyListeners();
  }

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

  
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  setIsEnd(int eventIdx) {
    events[eventIdx].isEnd = (events[eventIdx].needEndDate &&
       events[eventIdx].dateTime.isBefore(DateTime.now()) &&
      events[eventIdx].endDateTime!.isAfter(DateTime.now()));
    notifyListeners();
  }

  
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

Future fetchEvents() async {
  try {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    
    events = snapshot.docs.map((doc) {
    
      return Event(
        needEndDate: doc['needEndDate'],
        needNotify: doc['needNotify'],
        title: doc['title'],
        details: doc['description'],
        dateTime: (doc['date'] as Timestamp).toDate(), 
        notifications: (doc['notifications'] ?? []).map<NotificationId>((n) {
          return NotificationId(
            dateTime: (n['dateTime'] as Timestamp).toDate(),
            id: n['id'],
          );
        }).toList(),
      );
    }).toList();
    
   
    notifyListeners();
  } catch (e) {
    print('Error fetching events: $e');
  }
}


  void setNeedEndDate(bool needEndDate) {}
}
