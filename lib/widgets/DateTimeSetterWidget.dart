import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/DateTimeProvider.dart';

// ignore: must_be_immutable
class DateTimeSetterWidget extends StatelessWidget {
  late bool isStart;
  DateTimeSetterWidget({super.key, required this.isStart});

  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = isStart
        ? Provider.of<DateTimeProvider>(context, listen: false).dateTime
        : Provider.of<DateTimeProvider>(context, listen: false).endDateTime;

    Future<DateTime?> _pickDate() async => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: isStart
            ? DateTime.now()
            : Provider.of<DateTimeProvider>(context, listen: false).dateTime,
        lastDate: DateTime(2100));

    Future<TimeOfDay?> _pickTime() async => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));
    return Consumer<DateTimeProvider>(
        builder: (context, dateTimeProvider, child) {
      return Row(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () async {
                        final newDate = await _pickDate();
                        if (newDate == null) return;
                        isStart
                            ? dateTimeProvider.setDate(newDate)
                            : dateTimeProvider.setEndDate(newDate);
                      },
                      icon: const Icon(Icons.date_range)),
                  IconButton(
                      onPressed: () async {
                        final newTime = await _pickTime();
                        if (newTime == null) return;
                        isStart
                            ? dateTimeProvider.setTime(newTime)
                            : dateTimeProvider.setEndTime(newTime);
                      },
                      icon: const Icon(Icons.timer_outlined)),
                ],
              )),
          SizedBox(width: MediaQuery.of(context).size.width*0.03),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                  format.format(isStart
                      ? dateTimeProvider.dateTime
                      : dateTimeProvider.endDateTime),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                      fontSize: 15)),
            ),
          ),
        ],
      );
    });
  }
}
