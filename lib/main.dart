import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Customs/BottomNavBar.dart';
import 'pages/SignUpScreen.dart';
import 'provider/EventProvider.dart';
import 'provider/DateTimeProvider.dart';
import 'provider/NotesProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'countdown_channel',
        channelName: 'Countdown Notification',
        channelDescription: 'Notification channel for countdown tests',
        defaultColor: Colors.purple,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: highVibrationPattern,
      ),
    ],
    debug: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => DateTimeProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: const CalendarApp(),
    ),
  );
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
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<EventProvider>(context, listen: false).fetchEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.transparent,
            hintColor: Colors.white,
          ),
          home: BottomNavBar(),
        );
      },
    );
  }
}
