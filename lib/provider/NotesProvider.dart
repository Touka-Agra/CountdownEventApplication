import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotesProvider with ChangeNotifier {
  List<Map<String, dynamic>> activeNotes = [];
  List<Map<String, dynamic>> historyNotes = [];

  CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(String title, String subtitle, DateTime dateTime) async {
    var newNote = {
      'title': title,
      'subtitle': subtitle,
      'time': dateTime.toIso8601String(),
      'completed': false,
    };

    activeNotes.add(newNote);
    notifyListeners();

    await notesCollection.add(newNote).then((value) {
      print("Note added to Firestore");
    }).catchError((error) {
      print("Failed to add note: $error");
    });
  }

  Future<void> deleteNoteAt(int index) async {
    activeNotes[index]['completed'] = true;
    activeNotes[index]['subtitle'] += "   Deleted";

    historyNotes.add(activeNotes[index]);
    notifyListeners();

    var noteToDelete = activeNotes[index];
    activeNotes.removeAt(index);

    QuerySnapshot snapshot = await notesCollection
        .where('title', isEqualTo: noteToDelete['title'])
        .where('subtitle', isEqualTo: noteToDelete['subtitle'])
        .get();

    snapshot.docs.first.reference.delete().then((_) {
      print("Note deleted from Firestore");
    }).catchError((error) {
      print("Failed to delete note: $error");
    });

    notifyListeners();
  }

  Future<void> deleteHistoryNoteAt(int index) async {
    var noteToDelete = historyNotes[index];

    historyNotes.removeAt(index);
    notifyListeners();

    QuerySnapshot snapshot = await notesCollection
        .where('title', isEqualTo: noteToDelete['title'])
        .where('subtitle', isEqualTo: noteToDelete['subtitle'])
        .get();

    snapshot.docs.first.reference.delete().then((_) {
      print("History note deleted from Firestore");
    }).catchError((error) {
      print("Failed to delete history note: $error");
    });
  }

  Future<void> editNoteAt(
      int index, String title, String subtitle, DateTime dateTime) async {
    var oldNote = activeNotes[index];

    activeNotes[index] = {
      'title': title,
      'subtitle': subtitle,
      'time': dateTime.toIso8601String(),
      'completed': false,
    };

    notifyListeners();

    QuerySnapshot snapshot = await notesCollection
        .where('title', isEqualTo: oldNote['title'])
        .where('subtitle', isEqualTo: oldNote['subtitle'])
        .get();

    snapshot.docs.first.reference.update({
      'title': title,
      'subtitle': subtitle,
      'time': dateTime.toIso8601String(),
      'completed': false,
    }).then((_) {
      print("Note updated in Firestore");
    }).catchError((error) {
      print("Failed to update note: $error");
    });
  }

  Future<void> toggleCompletion(int index) async {
    var note = activeNotes[index];

    activeNotes[index]['subtitle'] += "   Done";
    historyNotes.add(activeNotes[index]);
    notifyListeners();

    activeNotes.removeAt(index);

    QuerySnapshot snapshot = await notesCollection
        .where('title', isEqualTo: note['title'])
        .where('subtitle', isEqualTo: note['subtitle'])
        .get();

    snapshot.docs.first.reference.update({
      'completed': true,
      'subtitle': note['subtitle'] + "   Done",
    }).then((_) {
      print("Note marked as completed in Firestore");
    }).catchError((error) {
      print("Failed to update completion status: $error");
    });
  }

  Future<void> restoreNoteAt(int index) async {
    var noteToRestore = historyNotes[index];

    noteToRestore['subtitle'] = noteToRestore['subtitle']
        .replaceAll("Not yet", "")
        .replaceAll("Done", "")
        .replaceAll("Deleted", "")
        .trim();

    activeNotes.add(noteToRestore);
    historyNotes.removeAt(index);
    notifyListeners();

    await notesCollection.add(noteToRestore).then((value) {
      print("Note restored in Firestore");
    }).catchError((error) {
      print("Failed to restore note: $error");
    });
  }
}
