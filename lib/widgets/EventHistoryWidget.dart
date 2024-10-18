import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../models/EventHistory.dart';
import '../models/event.dart';
import '../pages/EventDetailsScreen.dart';
import '../provider/EventProvider.dart';
import 'EditEventSheet.dart';

// ignore: must_be_immutable
class EventHistoryWidget extends StatelessWidget {
  final int eventIdx;

  EventHistoryWidget({super.key, required this.eventIdx});

  DateFormat format = DateFormat('MMM d, y - hh:mm a');

  @override
  Widget build(BuildContext context) {
    Event event =
        Provider.of<EventProvider>(context, listen: false).events[eventIdx];

    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<EventProvider>(builder: (context, eventProvider, child) {
        return Dismissible(
          key: Key(event.id),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.red[800]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.amber,
                      blurRadius: 10,
                      offset: Offset(0, 3)),
                ]),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onDismissed: (direction) {
            eventProvider.removeEvent(event);
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(
                            eventIdx: eventIdx,
                          )));
            },
            onDoubleTap: () {
              bool isPassed = eventProvider.checkDateTime(eventIdx);
              if (isPassed) {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EditEventSheet(
                          eventIdx: eventIdx,
                          isRestore: true,
                        ));
              } else {
                EventHistory eventHistoryUpdate = EventHistory(
                    inHistory: false, isPassed: isPassed, reason: "");

                Provider.of<EventProvider>(context, listen: false)
                    .updateHistoryState(
                        eventIdx: eventIdx,
                        eventHistoryUpdate: eventHistoryUpdate);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              foregroundDecoration: RotatedCornerDecoration.withColor(
                  color: event.eventHistory.reason != "Deleted"
                      ? Colors.grey[500]!
                      : Colors.grey[600]!,
                  spanBaselineShift: 4,
                  badgeSize: Size(h * 0.075, h * 0.075),
                  badgeCornerRadius: const Radius.circular(15),
                  badgeShadow:
                      BadgeShadow(color: Colors.grey[300]!, elevation: 10),
                  textSpan: TextSpan(
                    text: event.eventHistory.reason,
                    style: const TextStyle(
                      fontSize: 8,
                    ),
                  )),
              decoration: BoxDecoration(
                  color: event.backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                    color: Colors.white54,
                                    offset: Offset(0.5, 0.5))
                              ]),
                          overflow: TextOverflow.ellipsis, // Handle overflow
                          maxLines: 1, // Allow up to 2 lines
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              format.format(event.dateTime),
                              style: TextStyle(
                                  //fontWeight: FontWeight.bold,
                                  color: Colors.grey[100],
                                  fontSize: 12,
                                  shadows: const [
                                    Shadow(
                                        color: Colors.white54,
                                        offset: Offset(0.5, 0.5))
                                  ]),
                            ),
                            if (event.needEndDate)
                              Text(
                                format.format(event.endDateTime!),
                                style: TextStyle(
                                  //fontWeight: FontWeight.bold,
                                  color: Colors.grey[100],
                                  fontSize: 12,
                                  shadows: const [
                                    Shadow(
                                        color: Colors.white54,
                                        offset: Offset(0.5, 0.5))
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Removed empty Flexible widget
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
