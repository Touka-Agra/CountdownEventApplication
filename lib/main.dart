import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart'; // Import the package

import 'Customs/BottomNavBar.dart';
import 'provider/event_provider.dart';
import 'provider/EventProvider.dart';
import 'provider/DateTimeProvider.dart';
import 'provider/NotesProvider.dart';

void main() {
  AwesomeNotifications().initialize(
    null, // Default icon (if you have one, provide the icon path here)
    [
      NotificationChannel(
        channelKey: 'countdown_channel',
        channelName: 'Countdown Notification',
        channelDescription: 'Notification channel for countdown tests',
        defaultColor:  Colors.purple ,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true, 
        vibrationPattern: highVibrationPattern,
      )
    ],
    debug: true,
  );
  runApp(const CalendarApp());
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  _CalendarAppState createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  Future<void> requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => EventtProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
            ChangeNotifierProvider(create: (_) => DateTimeProvider()),
            ChangeNotifierProvider(create: (_) => NotesProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.transparent,
              hintColor: Colors.white,
            ),
            home: const BottomNavBar(),
          ));
}
