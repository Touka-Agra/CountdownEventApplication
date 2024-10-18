import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'event.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> appointments) {
    this.appointments = appointments;
  }

  Event getEvent(int index) => appointments![index] as Event;

  @override
  DateTime getStartTime(int index) => getEvent(index).dateTime;

  @override
  DateTime getEndTime(int index) {
    // If your event doesn't have an explicit end time, default to +1 hour
    return getEvent(index).endDateTime?? getEvent(index).dateTime.add(Duration(hours: 1));
  }

  @override
  String getSubject(int index) => getEvent(index).title;

  @override
  Color getColor(int index) => getEvent(index).backgroundColor;
}
