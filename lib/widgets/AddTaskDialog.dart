import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/NotesProvider.dart';

class AddTaskDialog extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  DateTime? selectedDateTime;

  AddTaskDialog({super.key});

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
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    void _createNote() {
    if (_titleController.text.isNotEmpty &&
        _subtitleController.text.isNotEmpty &&
        selectedDateTime != null) {
      Provider.of<NotesProvider>(context, listen: false).addNote(
        _titleController.text,
        _subtitleController.text,
        selectedDateTime!,
      );
      _titleController.clear();
      _subtitleController.clear();
      selectedDateTime = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C1C),
      title: const Text(
        'New Note',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            cursorColor: Colors.blue,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          TextField(
            controller: _subtitleController,
            cursorColor: Colors.blue,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Subtitle',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          ListTile(
            title: Text(
              selectedDateTime != null
                  ? DateFormat('yyyy-MM-dd – HH:mm').format(selectedDateTime!)
                  : 'Select Date & Time',
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed: () => _pickDateTime(context),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            _createNote();
            Navigator.pop(context);
          },
          child: const Text('Create', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
