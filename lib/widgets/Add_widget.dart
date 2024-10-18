import 'package:countdown_event/widgets/AddTaskDialog.dart';
import 'package:flutter/material.dart';

import '../pages/EventForm.dart';

class AddWidget extends StatelessWidget {
  const AddWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Choose an option",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EventForm());
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.purple[400])),
              child: const Text("Add Event",
                  style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context, builder: (context) => AddTaskDialog());
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.purple[400])),
              child: const Text(
                "Add Task",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }
}
