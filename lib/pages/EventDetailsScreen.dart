import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../models/event.dart';
import '../widgets/NotificationWidget.dart';

class EventDetailsScreen extends StatelessWidget {
  late Event event;
  EventDetailsScreen({super.key, required this.event});

  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  double timerSize = 35;
  FontWeight timerWeight = FontWeight.w900;
  Color timerColor = Colors.purple;

  final dateTimeNow = DateTime.now();

  bool wantNotify = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple, // Set AppBar color to purple
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
                      offset: Offset(0, 3),
                    ),
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
                          Text(format.format(event.dateTime),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400],
                                  fontSize: 15)),
                          const Icon(Icons.edit_rounded,
                              size: 20, color: Colors.white),
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
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.blueGrey.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                    ]
                  ),
                  child: RawSlideCountdown(
                      streamDuration: StreamDuration(
                        config: StreamDurationConfig(
                          countDownConfig: CountDownConfig(
                              duration: Duration(
                                  days: event.dateTime.day - dateTimeNow.day,
                                  hours: event.dateTime.hour  - dateTimeNow.hour,
                                  minutes: event.dateTime.minute  - dateTimeNow.minute,
                                  )),
                        ),
                      ),
                      builder: (context, duration, countUp) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Day
                            _buildTimer(
                                first: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.days,
                                  digitType: DigitType.first,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                second: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.days,
                                  digitType: DigitType.second,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                title: 'Days'),

                            // Hours
                            _buildTimer(
                                first: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.hours,
                                  digitType: DigitType.first,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                second: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.hours,
                                  digitType: DigitType.second,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                title: 'Hours'),

                            // Minutes
                            _buildTimer(
                                first: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.minutes,
                                  digitType: DigitType.first,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                second: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.minutes,
                                  digitType: DigitType.second,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                title: 'Minutes'),

                            // Seconds
                            _buildTimer(
                                first: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.seconds,
                                  digitType: DigitType.first,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                second: RawDigitItem(
                                  duration: duration,
                                  timeUnit: TimeUnit.seconds,
                                  digitType: DigitType.second,
                                  countUp: countUp,
                                  style: TextStyle(
                                      fontSize: timerSize,
                                      fontWeight: timerWeight,
                                      color: timerColor),
                                ),
                                title: 'Seconds'),
                          ],
                        );
                      }),
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Details",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700], // Grey-blue background
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              event.details.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No Details",
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                    )
                                  : Text(
                                      event.details,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notification
              NotificationWidget(event: event,)
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTitle(String title) {
  return (Text(
    title,
    style: TextStyle(
        fontWeight: FontWeight.bold, color: Colors.grey[400], fontSize: 10),
  ));
}

Widget _buildTimer(
    {required Widget first, required Widget second, required String title}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white54, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [first, second],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildTitle(title),
      ],
    ),
  );
}

Widget _buildNotification(String time) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            time,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.cancel,
            color: Colors.white,
            size: 25,
          ),
        ),
      ]),
    ),
  );
}
