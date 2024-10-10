import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../provider/DateTimeProvider.dart';
import '../provider/EventProvider.dart';
import '../provider/NotificationProvider.dart';
import '../widgets/DateTimeSetterWidget.dart';
import '../widgets/NotificationWidget.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();

  final dateTimeNow = DateTime.now();

  Color c = Colors.purple;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String typingTitle = "";

  bool needEndDate = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          boxShadow: [
            BoxShadow(color: Colors.purple, spreadRadius: 2, blurRadius: 5)
          ]),
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
                    "Add Event",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            Event event = Event(
                                title: _titleController.text,
                                details: _descriptionController.text,
                                dateTime: Provider.of<DateTimeProvider>(context,
                                        listen: false)
                                    .dateTime,
                                needEndDate: needEndDate,
                                needNotify: true);

                            if (needEndDate) {
                              event.endDateTime = Provider.of<DateTimeProvider>(
                                      context,
                                      listen: false)
                                  .endDateTime;
                            }
                            event.notifications =
                                Provider.of<NotificationProvider>(context,
                                        listen: false)
                                    .notifications;

                            if (Provider.of<DateTimeProvider>(context,
                                        listen: false)
                                    .isValidEndDate ||
                                !needEndDate) {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                Provider.of<EventProvider>(context,
                                        listen: false)
                                    .addEvent(event);

                                Provider.of<NotificationProvider>(context,
                                        listen: false)
                                    .notifications = [];

                                    Provider.of<DateTimeProvider>(context,
                                        listen: false)
                                    .restartDate();

                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Event is added successfully')));
                              }
                            } else {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text('Unfortunatlly,Event is not added'),
                              ));
                            }
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.purple)),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),

              //title
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(20)),
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
                                } else if (!Provider.of<EventProvider>(context,
                                        listen: false)
                                    .checkTitle(value)) {
                                  return "Title must be Unique!";
                                }
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
                                        : Colors.red),
                                focusColor: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //set date
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DateTimeSetterWidget(isStart: true),
                    ),

                    //end date
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Consumer<EventProvider>(
                          builder: (context, eventProvider, child) {
                        return Opacity(
                          opacity: needEndDate ? 1.0 : 0.5,
                          child: Column(
                            children: [
                              CheckboxListTile(
                                  value: needEndDate,
                                  checkColor: c,
                                  title: const Text(
                                    "Set End Date",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onChanged: (value) {
                                    needEndDate = value!;
                                    eventProvider.setNeedEndDate();
                                  }),
                              IgnorePointer(
                                ignoring: !needEndDate,
                                child: DateTimeSetterWidget(
                                  isStart: false,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    //description
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextFormField(
                              controller: _descriptionController,
                              maxLines: 8,
                              decoration: const InputDecoration(
                                hintText: "Write Event Details",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    //notification
                    NotificationWidget()
                  ],
                )),
              ),
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
