import 'package:countdown_event/pages/EventDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../models/event_data_source.dart';
import '../provider/EventProvider.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({Key? key}) : super(key: key);

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final selectedEvents = provider.eventsOfSelectedDate;

    // Show message if there are no events
    if (selectedEvents.isEmpty) {
      return const Center(
        child: Text(
          "No Events",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return SfCalendarTheme(
      data: const SfCalendarThemeData(
        timeTextStyle: TextStyle(fontSize: 16, color: Colors.white),
      ),
      child: SfCalendar(
        view: CalendarView.timelineDay,
        dataSource: EventDataSource(selectedEvents), 
        headerHeight: 0,
        todayHighlightColor: Colors.white,
        initialDisplayDate: provider.selectedDate,
        appointmentBuilder: appointmentBuilder,
        selectionDecoration: BoxDecoration(
          color: const Color.fromARGB(255, 56, 9, 149).withOpacity(0.3),
        ),
        onTap: (details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            // Get the first event and pass it to EventDetailsScreen
            final event = details.appointments!.first;
            int eventId = int.tryParse(event.id) ?? 0; 
            Navigator.of(context).push(
              MaterialPageRoute(
                
                builder: (context) => EventDetailsScreen(eventIdx: eventId), // Pass the actual event ID or any identifier
              ),
            );
          }
        },
      ),
    );
  }

  Widget appointmentBuilder(BuildContext context, CalendarAppointmentDetails details) {
    final event = details.appointments.first;
    return Container(
      decoration: BoxDecoration(
        color: event.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      width: details.bounds.width,
      height: details.bounds.height,
      child: Center(
        child: Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
