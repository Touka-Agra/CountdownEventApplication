import 'package:countdown_event/provider/EventProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/event_data_source.dart';

import 'tasks_widget.dart';

class CalendarWidget extends StatelessWidget {
  CalendarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
     Provider.of<EventProvider>(context).fetchEvents();
    

    return SfCalendar(
        view: CalendarView.month,
        dataSource: EventDataSource(events),
        initialSelectedDate: DateTime.now(),
        cellBorderColor: Colors.transparent,
        onLongPress: (details) {
          final provider = Provider.of<EventProvider>(context, listen: false);
          provider.setDate(details.date!);
          showModalBottomSheet(
            context: context,
            builder: (context) => TasksWidget(),
          );
        });
  }
}
