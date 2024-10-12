import 'package:flutter/material.dart';

class NotesProvider with ChangeNotifier {
  List<Map<String, dynamic>> activeNotes = [];

  List<Map<String, dynamic>> historyNotes = [];

  // Add a new note to the active notes
  addNote(String title, String subtitle, DateTime dateTime) {
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
    activeNotes[index]['subtitle'] += "   Deleted";
    historyNotes.add(activeNotes[index]);
    activeNotes.removeAt(index);

    notifyListeners();
  }

  deleteHistoryNoteAt(int index) {
    historyNotes.removeAt(index);
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
    noteToRestore['subtitle'] = noteToRestore['subtitle']
        .replaceAll("Not yet", "")
        .replaceAll("Done", "")
        .replaceAll("Deleted", "")
        .trim();
    activeNotes.add(noteToRestore);
    historyNotes.removeAt(index);
    notifyListeners();
  }
}
