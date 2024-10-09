import 'package:flutter/material.dart';

class NotesProvider with ChangeNotifier {
  List<Map<String, dynamic>> activeNotes = [
    {
      'title': 'Meeting Notes',
      'subtitle': 'Discuss project timeline',
      'time': DateTime.now(),
      'completed': false,
    },
    {
      'title': 'Grocery List',
      'subtitle': 'Milk, Bread, Eggs',
      'time': DateTime.now(),
      'completed': false,
    },
  ];

  List<Map<String, dynamic>> historyNotes = [];

  // Add a new note to the active notes
  void addNote(String title, String subtitle, DateTime dateTime) {
    activeNotes.add({
      'title': title,
      'subtitle': subtitle,
      'time': dateTime,
      'completed': false,
    });
    notifyListeners();
  }

  // Delete a note and move it to history
  void deleteNoteAt(int index) {
    activeNotes[index]['completed'] = true;
    activeNotes[index]['subtitle'] += "   Not yet";
    historyNotes.add(activeNotes[index]);
    activeNotes.removeAt(index);
    notifyListeners();
  }

  // Edit a note
  void editNoteAt(int index, String title, String subtitle, DateTime dateTime) {
    activeNotes[index] = {
      'title': title,
      'subtitle': subtitle,
      'time': dateTime,
      'completed': false,
    };
    notifyListeners();
  }

  // Toggle completion status and move to history
  void toggleCompletion(int index) {
    activeNotes[index]['subtitle'] += "   Done";
    historyNotes.add(activeNotes[index]);
    activeNotes.removeAt(index);
    notifyListeners();
  }

  // Restore a note from history to active notes
  void restoreNoteAt(int index) {
    var noteToRestore = historyNotes[index];
    noteToRestore['subtitle'] =
        noteToRestore['subtitle'].replaceAll("Not yet", "").replaceAll("Done", "").trim();
    activeNotes.add(noteToRestore);
    historyNotes.removeAt(index);
    notifyListeners();
  }
}