import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/EventHistory.dart';
import '../models/event.dart';
import '../provider/DateTimeProvider.dart';
import '../provider/EventProvider.dart';
import '../widgets/DateTimeSetterWidget.dart';

// EditEventSheet class
// ignore: must_be_immutable
class EditEventSheet extends StatefulWidget {
  int eventIdx;
  EditEventSheet({super.key, required this.eventIdx});

  @override
  State<EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends State<EditEventSheet> {
  final _formKey = GlobalKey<FormState>();
  Color c = Colors.purple;

  @override
  Widget build(BuildContext context) {
    int eventIdx = widget.eventIdx;
    Event event =
        Provider.of<EventProvider>(context, listen: false).events[eventIdx];

    String typingTitle = event.title;

    final TextEditingController _titleController =
        TextEditingController(text: event.title);
    final TextEditingController _descriptionController =
        TextEditingController(text: event.details);

    Provider.of<DateTimeProvider>(context, listen: false).dateTime =
        event.dateTime;

    // if (event.needEndDate) {
    //   Provider.of<DateTimeProvider>(context, listen: false).endDateTime =
    //       event.endDateTime!??DateT;
    // }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(color: Colors.purple, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  const Text(
                    "Restore Passed Date Event",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              DateTime dateTime = Provider.of<DateTimeProvider>(
                                      context,
                                      listen: false)
                                  .dateTime;

                              Event newEvent = Event(
                                id: '',
                                title: _titleController.text,
                                details: _descriptionController.text,
                                dateTime: dateTime,
                                needEndDate: event.needEndDate,
                                needNotify: true,
                                notifications: [],
                                eventHistory: EventHistory(
                                    isPassed: false,
                                    reason: '',
                                    inHistory: false),
                              );

                              if (event.needEndDate) {
                                event.endDateTime =
                                    Provider.of<DateTimeProvider>(context,
                                            listen: false)
                                        .endDateTime;
                              }

                              if (Provider.of<DateTimeProvider>(context,
                                          listen: false)
                                      .isValidEndDate ||
                                  !event.needEndDate) {
                                Navigator.pop(context);
                                Provider.of<EventProvider>(context,
                                        listen: false)
                                    .editEvent(newEvent, oldEvent: event);

                                int eventIdx = Provider.of<EventProvider>(
                                            context,
                                            listen: false)
                                        .events
                                        .length -
                                    1;

                                bool isPassed = Provider.of<EventProvider>(
                                        context,
                                        listen: false)
                                    .checkDateTime(eventIdx);

                                if (isPassed) {
                                  EventHistory eventHistoryUpdate =
                                      EventHistory(
                                          inHistory: true,
                                          isPassed: isPassed,
                                          reason: "Passed");

                                  Provider.of<EventProvider>(context,
                                          listen: false)
                                      .updateHistoryState(
                                          eventIdx: eventIdx,
                                          eventHistoryUpdate:
                                              eventHistoryUpdate);
                                }

                                Provider.of<DateTimeProvider>(context,
                                        listen: false)
                                    .restartDate();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Event "${_titleController.text}" restored successfully')),
                                );
                              } else {
                                Navigator.pop(context);
                                Provider.of<DateTimeProvider>(context,
                                        listen: false)
                                    .restartDate();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Unfortunately, Event is not restored')),
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Title Field
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _titleController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "This field can't be Empty!";
                                  }
                                  return null;
                                },
                                maxLength: 32,
                                onChanged: (value) {
                                  setState(() {
                                    typingTitle = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Title",
                                  helperStyle: TextStyle(
                                    color: typingTitle.length < 32
                                        ? Colors.white
                                        : Colors.red,
                                  ),
                                  focusColor: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Set Date
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: DateTimeSetterWidget(isStart: true),
                      ),

                      // End Date
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Consumer<EventProvider>(
                            builder: (context, eventProvider, child) {
                          return Opacity(
                            opacity: event.needEndDate ? 1.0 : 0.5,
                            child: Column(
                              children: [
                                CheckboxListTile(
                                  value: event.needEndDate,
                                  checkColor: c,
                                  title: const Text(
                                    "Set End Date",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      event.needEndDate = value!;
                                       if(Provider.of<DateTimeProvider>(context,
                                                  listen: false)
                                              .endDateTime==null)
                                      {Provider.of<DateTimeProvider>(context,
                                                  listen: false)
                                              .endDateTime =
                                          Provider.of<DateTimeProvider>(context,
                                                  listen: false)
                                              .dateTime;}
                                    });
                                  },
                                ),
                                IgnorePointer(
                                  ignoring: !event.needEndDate,
                                  child: DateTimeSetterWidget(
                                    isStart: false,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      // Description Field
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextFormField(
                                controller: _descriptionController,
                                maxLines: 8,
                                decoration: const InputDecoration(
                                  hintText: "Write Event Details",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
