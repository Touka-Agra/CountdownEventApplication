import 'dart:ui';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'event.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> appointments) {
    this.appointments = appointments;
  }
  Event getEvent(int index) => appointments![index] as Event;

  @override
  DateTime getDate(int index) => getEvent(index).dateTime;

  @override
  String getSubject(int index) => getEvent(index).title;
}
