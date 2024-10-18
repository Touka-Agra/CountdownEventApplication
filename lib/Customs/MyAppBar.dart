import 'package:countdown_event/pages/SignUpScreen.dart';
import 'package:flutter/material.dart';

import '../pages/home_page.dart';

PreferredSizeWidget getAppBar(
    {required BuildContext context, required String title, TabBar? tabBar}) {
  Color c = Colors.purple[400]!;
  return AppBar(
    backgroundColor: Colors.white,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    centerTitle: true,
    leading: title != "TimeVesta"
        ? IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            icon: const Icon(Icons.calendar_month),
            color: c,
          )
        : null,
    actions: [
      IconButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignUpScreen()));
        },
        icon: const Icon(Icons.logout),
        color: c,
      ),
    ],
    bottom: tabBar,
  );
}
