
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../provider/DateTimeProvider.dart';
import '../provider/EventProvider.dart';
import '../widgets/DateTimeSetterWidget.dart';
import '../widgets/NotificationWidget.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
    @override
  void initState() {
    super.initState();

    
  }

  final _formKey = GlobalKey<FormState>();

  Color c = Colors.purple;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String typingTitle = "";
  bool needEndDate = false;

  @override
  void dispose() {
    
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        boxShadow: [
          BoxShadow(color: Colors.purple, spreadRadius: 2, blurRadius: 5)
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
                    "Add Event",
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
                             
                              Event event = Event(
                                title: _titleController.text,
                                details: _descriptionController.text,
                                dateTime: Provider.of<DateTimeProvider>(
                                        context,
                                        listen: false)
                                    .dateTime,
                                needEndDate: needEndDate,
                                needNotify: true,
                                notifications: [],
                              );
                               Provider.of<EventProvider>(context, listen: false).addEvent(event);
                               

                              if (needEndDate) {
                                event.endDateTime =
                                    Provider.of<DateTimeProvider>(context,
                                            listen: false)
                                        .endDateTime;
                              }

                              if (Provider.of<DateTimeProvider>(context,
                                          listen: false)
                                      .isValidEndDate ||
                                  !needEndDate) {
                                Navigator.pop(context);
                                Provider.of<EventProvider>(context,
                                        listen: false)
                                    .addEvent(event);

                                int eventIdx = Provider.of<EventProvider>(
                                            context,
                                            listen: false)
                                        .events
                                        .length -
                                    1;

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.0)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.purple,
                                            spreadRadius: 2,
                                            blurRadius: 5)
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Spacer(),
                                              const Text(
                                                "Customize Notifications",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5.0,
                                                          top: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ButtonStyle(
                                                        shape: WidgetStateProperty
                                                            .all(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            WidgetStateProperty
                                                                .all(Colors
                                                                    .purple),
                                                      ),
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
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: NotificationWidget(
                                                eventIdx: eventIdx,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                                Provider.of<DateTimeProvider>(context,
                                        listen: false)
                                    .restartDate();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Event "${_titleController.text}" added successfully')),
                                );
                              } else {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Unfortunately, Event is not added')),
                                );
                              }
                            }
                          },
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.purple),
                          ),
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      needEndDate = value!;
                                      eventProvider
                                          .setNeedEndDate(needEndDate);
                                    });
                                  },
                                ),
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

Widget _buildTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey[400],
      fontSize: 10,
    ),
  );
}
