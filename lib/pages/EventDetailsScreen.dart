import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/EventHistory.dart';
import '../models/event.dart';
import '../provider/EventProvider.dart';
import '../widgets/EditEventSheet.dart';
import '../widgets/NotificationWidget.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventIdx;

  EventDetailsScreen({super.key, required this.eventIdx});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  DateFormat format = DateFormat('MMM d, y - hh:mm a');
  FontWeight timerWeight = FontWeight.w900;
  Color timerColor = Colors.purple;
  final dateTimeNow = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        Provider.of<EventProvider>(context, listen: false)
            .setIsEnd(widget.eventIdx);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int eventIdx = widget.eventIdx;
    Event event =
        Provider.of<EventProvider>(context, listen: false).events[eventIdx];

    double _getTimerSize() {
      int remainingDays = event.dateTime.difference(dateTimeNow).inDays;
      int numberOfDigits = remainingDays.toString().length;
      return (MediaQuery.of(context).size.width / (numberOfDigits + 8)) - 1;
    }

    Widget _buildTimer({required String value, required String title}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  value,
                  style: TextStyle(
                      fontWeight: timerWeight,
                      color: timerColor,
                      fontSize: _getTimerSize()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildTitle(title),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and date container
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blueGrey[700]!, Colors.blueGrey[400]!]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 3))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25)),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(format.format(event.dateTime),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[400],
                                      fontSize: 15)),
                              (event.needEndDate)
                                  ? Text(
                                      "to: ${format.format(event.endDateTime!)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[400],
                                          fontSize: 15))
                                  : const SizedBox.shrink()
                            ],
                          ),
                          IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        EditEventSheet(eventIdx: eventIdx, isRestore: false,));
                              },
                              icon: const Icon(Icons.edit_rounded,
                                  size: 20, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Countdown container
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.purple.shade300,
                        Colors.blueGrey.shade700
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            offset: Offset(0, 3))
                      ]),
                  child: Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      DateTime countdownDateTime =
                          eventProvider.events[eventIdx].isEnd
                              ? event.endDateTime!
                              : event.dateTime;

                      if (eventProvider.checkDateTime(eventIdx)) {
                        EventHistory eventHistoryUpdate = EventHistory(
                            inHistory: true, isPassed: true, reason: "Passed");
                        Provider.of<EventProvider>(context, listen: false)
                            .updateHistoryState(
                                eventIdx: eventIdx,
                                eventHistoryUpdate: eventHistoryUpdate);

                                return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimer(value: '0', title: 'Days'),
                          _buildTimer(
                              value:'00', title: 'Hours'),
                          _buildTimer(
                              value: '00', title: 'Minutes'),
                          _buildTimer(
                              value: '00', title: 'Seconds'),
                        ],
                      );
                      }

                      Map<String, String> durations =
                          getDurationAndUnit(countdownDateTime);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimer(value: durations['Days']!, title: 'Days'),
                          _buildTimer(
                              value: durations['Hours']!, title: 'Hours'),
                          _buildTimer(
                              value: durations['Minutes']!, title: 'Minutes'),
                          _buildTimer(
                              value: durations['Seconds']!, title: 'Seconds'),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Details",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blueGrey[700],
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              event.details.isEmpty
                                  ? Center(
                                      child: Text("No Details",
                                          style: TextStyle(
                                              color: Colors.grey[400])))
                                  : Text(event.details,
                                      style:
                                          const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notification
              NotificationWidget(eventIdx: eventIdx),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTitle(String title) {
  return Text(title,
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.grey[400], fontSize: 10));
}

Map<String, String> getDurationAndUnit(DateTime dateTime) {
  Map<String, String> result = {};
  Duration duration = dateTime.difference(DateTime.now());

  result['Days'] = duration.inDays.toString();
  result['Hours'] = (duration.inHours % 24).toString().padLeft(2, '0');
  result['Minutes'] = (duration.inMinutes % 60).toString().padLeft(2, '0');
  result['Seconds'] = (duration.inSeconds % 60).toString().padLeft(2, '0');

  return result;
}
