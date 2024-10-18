import 'package:countdown_event/provider/EventProvider.dart';
import 'package:countdown_event/widgets/tasks_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/event_data_source.dart';

class CalendarWidget extends StatelessWidget {
  CalendarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;

    return SfCalendar(
      view: CalendarView.month,
      dataSource: EventDataSource(events),
      initialSelectedDate: DateTime.now(),

      cellBorderColor: Colors.grey[300],
      backgroundColor: Colors.white,

      headerStyle: CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Color.fromARGB(255, 247, 238, 248),
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.purple[400],
        ),
      ),

      todayHighlightColor: Colors.purple[400],

      selectionDecoration: BoxDecoration(
        border: Border.all(color: Colors.purple[400]!, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: Colors.transparent,
      ),

      monthViewSettings: MonthViewSettings(
        showAgenda: true,
        dayFormat: 'EEE',
        agendaStyle:
            AgendaStyle(backgroundColor: Color.fromARGB(255, 247, 238, 248)),
        numberOfWeeksInView: 5,
        monthCellStyle: const MonthCellStyle(
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),

      // Handle long press on calendar cells to show task widget
      onLongPress: (details) {
        final provider = Provider.of<EventProvider>(context, listen: false);
        provider.setDate(details.date!);
        showModalBottomSheet(
          context: context,
          builder: (context) => const TasksWidget(),
        );
      },
    );
  }
}
