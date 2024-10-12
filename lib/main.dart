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
      null,
      [
        NotificationChannel(
            channelKey: 'countdown_channel',
            channelName: 'countdown_notofocation',
            channelDescription: 'Notification channel for countdown tests')
      ],
      debug: true);
  runApp(const CalendarApp());
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  // This widget is the root of your application.
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
