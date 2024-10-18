import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/NotesProvider.dart';

class AddTaskDialog extends StatefulWidget {
  AddTaskDialog({super.key});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  DateTime? selectedDateTime;
  final _formKey = GlobalKey<FormState>();
  bool isDateTimeSelected = true; // To track if the date is selected

  Future<void> _pickDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          isDateTimeSelected = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _createNote() {
      if (selectedDateTime == null) {
        setState(() {
          isDateTimeSelected = false;
        });
        return;
      }

      Provider.of<NotesProvider>(context, listen: false).addNote(
        _titleController.text,
        _subtitleController.text,
        selectedDateTime!,
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'New Note',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 23,
        ),
      ),
      shadowColor: Colors.purple,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field can't be Empty!";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtitle',
              ),
            ),
            ListTile(
              title: selectedDateTime != null
                  ? Text(
                      DateFormat('MMM d, y - hh:mm a')
                          .format(selectedDateTime!),
                      style: TextStyle(color: Colors.purple[400]),
                    )
                  : Text(
                      'Select Date & Time',
                      style: TextStyle(color: Colors.black),
                    ),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.purple[400]),
                onPressed: () => _pickDateTime(context),
              ),
            ),
            if (!isDateTimeSelected) // Conditionally show error text
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(
                    "Please select a date and time!",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (selectedDateTime == null) {
                setState(() {
                  isDateTimeSelected = false; // Show error if date is missing
                });
              } else {
                _createNote();
                Navigator.pop(context);
              }
            }
          },
          child: Text('Create', style: TextStyle(color: Colors.purple[400])),
        ),
      ],
    );
  }
}
