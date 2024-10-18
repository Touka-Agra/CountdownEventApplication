import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Customs/MyAppBar.dart';
import '../models/event.dart';
import '../provider/EventProvider.dart';
import '../widgets/EventHistoryWidget.dart';
import '../widgets/EventWidget.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with SingleTickerProviderStateMixin {
  Color bgc = Colors.white;
  Color c = Colors.purple;
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();

    Provider.of<EventProvider>(context, listen: false).fetchEvents();
    print('Calling fetchEvents...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        title: "Your Events",
        tabBar: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple[400]!,
          labelColor: Colors.purple[400]!,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "History"),
          ],
        ),
        context: context,
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Events List
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                final events = eventProvider.events
                    .where((event) => !event.eventHistory.inHistory)
                    .toList();
                if (events.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You Have No Events Yet",
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Click Add",
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.add,
                            color: Colors.grey[500],
                            size: 25,
                          )
                        ],
                      )
                    ],
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    Event upCommingEvent = events[index];
                    int eventIdx = eventProvider.events.indexOf(upCommingEvent);
                    return EventWidget(eventIdx: eventIdx);
                  },
                );
              },
            ),
          ),

          // History Events List
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                final pastEvents = eventProvider.events
                    .where((event) => event.eventHistory.inHistory)
                    .toList();

                if (pastEvents.isEmpty) {
                  return Center(
                    child: Text(
                      "No past events.",
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return ListView.builder(
                    itemCount: pastEvents.length,
                    itemBuilder: (context, index) {
                      Event pastEvent = pastEvents[index];
                      int eventIdx = eventProvider.events.indexOf(pastEvent);
                      return EventHistoryWidget(
                        eventIdx: eventIdx,
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
