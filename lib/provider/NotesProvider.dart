// import 'package:flutter/material.dart';

// class NotesProvider with ChangeNotifier {
//   List<Map<String, dynamic>> activeNotes = [];

//   List<Map<String, dynamic>> historyNotes = [];

//   // Add a new note to the active notes
//   addNote(String title, String subtitle, DateTime dateTime) {
//     activeNotes.add({
//       'title': title,
//       'subtitle': subtitle,
//       'time': dateTime,
//       'completed': false,
//     });

//     notifyListeners();
//   }

//   // Delete a note and move it to history
//   void deleteNoteAt(int index) {
//     activeNotes[index]['completed'] = true;
//     activeNotes[index]['subtitle'] += "   Deleted";
//     historyNotes.add(activeNotes[index]);
//     activeNotes.removeAt(index);

//     notifyListeners();
//   }

//   deleteHistoryNoteAt(int index) {
//     historyNotes.removeAt(index);
//     notifyListeners();
//   }

//   // Edit a note
//   void editNoteAt(int index, String title, String subtitle, DateTime dateTime) {
//     activeNotes[index] = {
//       'title': title,
//       'subtitle': subtitle,
//       'time': dateTime,
//       'completed': false,
//     };
//     notifyListeners();
//   }

//   // Toggle completion status and move to history
//   void toggleCompletion(int index) {
//     activeNotes[index]['subtitle'] += "   Done";
//     historyNotes.add(activeNotes[index]);
//     activeNotes.removeAt(index);
//     notifyListeners();
//   }

//   // Restore a note from history to active notes
//   void restoreNoteAt(int index) {
//     var noteToRestore = historyNotes[index];
//     noteToRestore['subtitle'] = noteToRestore['subtitle']
//         .replaceAll("Not yet", "")
//         .replaceAll("Done", "")
//         .replaceAll("Deleted", "")
//         .trim();
//     activeNotes.add(noteToRestore);
//     historyNotes.removeAt(index);
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesProvider with ChangeNotifier {
  List<Map<String, dynamic>> activeNotes = [];
  List<Map<String, dynamic>> historyNotes = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new note to the active notes and Firestore
  Future<void> addNote(String title, String subtitle, DateTime dateTime) async {
    Map<String, dynamic> newNote = {
      'title': title,
      'subtitle': subtitle,
      'time': dateTime,
      'completed': false,
    };

    // Save note to Firestore
    await _firestore.collection('notes').add(newNote);

    activeNotes.add(newNote);
    notifyListeners();
  }

  // Delete a note and move it to history
  Future<void> deleteNoteAt(int index) async {
    var noteToDelete = activeNotes[index];
    noteToDelete['completed'] = true;
    noteToDelete['subtitle'] += "   Deleted";
    historyNotes.add(noteToDelete);

    
    var querySnapshot = await _firestore
        .collection('notes')
        .where('title', isEqualTo: noteToDelete['title'])
        .where('subtitle', isEqualTo: noteToDelete['subtitle'])
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    activeNotes.removeAt(index);
    notifyListeners();
  }

  deleteHistoryNoteAt(int index) async {
    var noteToDelete = historyNotes[index];
    var querySnapshot = await _firestore
        .collection('notes')
        .where('title', isEqualTo: noteToDelete['title'])
        .where('subtitle', isEqualTo: noteToDelete['subtitle'])
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();

      historyNotes.removeAt(index);
      notifyListeners();
    }
  }

  // Edit a note in Firestore
  Future<void> editNoteAt(
      int index, String title, String subtitle, DateTime dateTime) async {
    var noteToEdit = activeNotes[index];

    // Update Firestore
    var querySnapshot = await _firestore
        .collection('notes')
        .where('title',
            isEqualTo:
                noteToEdit['title']) // Update condition based on your needs
        .where('subtitle',
            isEqualTo:
                noteToEdit['subtitle']) // Update condition based on your needs
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'title': title,
        'subtitle': subtitle,
        'time': dateTime,
        'completed': false,
      });
    }

    // Update active notes
    activeNotes[index] = {
      'title': title,
      'subtitle': subtitle,
      'time': dateTime,
      'completed': false,
    };

    notifyListeners();
  }

  // Toggle completion status and move to history
  Future<void> toggleCompletion(int index) async {
    var noteToToggle = activeNotes[index];
    noteToToggle['subtitle'] += "   Done";
    historyNotes.add(noteToToggle);

    // Update Firestore
    var querySnapshot = await _firestore
        .collection('notes')
        .where('title',
            isEqualTo:
                noteToToggle['title']) // Update condition based on your needs
        .where('subtitle',
            isEqualTo: noteToToggle[
                'subtitle']) // Update condition based on your needs
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'completed': true});
    }

    activeNotes.removeAt(index);
    notifyListeners();
  }

  // Restore a note from history to active notes
  Future<void> restoreNoteAt(int index) async {
    var noteToRestore = historyNotes[index];
    noteToRestore['subtitle'] = noteToRestore['subtitle']
        .replaceAll("Not yet", "")
        .replaceAll("Done", "")
        .replaceAll("Deleted", "")
        .trim();

    // Save restored note to Firestore
    await _firestore.collection('notes').add(noteToRestore);

    activeNotes.add(noteToRestore);
    historyNotes.removeAt(index);
    notifyListeners();
  }

// Fetch notes from Firestore
  Future<void> fetchNotes() async {
    try {
      // Fetch active notes (where 'completed' is false)
      QuerySnapshot activeSnapshot = await _firestore
          .collection('notes')
          .where('completed', isEqualTo: false)
          .get();

      // Fetch history notes (where 'completed' is true)
      QuerySnapshot historySnapshot = await _firestore
          .collection('notes')
          .where('completed', isEqualTo: true)
          .get();

      // Clear existing notes before fetching new ones
      activeNotes.clear();
      historyNotes.clear();

      // Populate active notes
      for (var doc in activeSnapshot.docs) {
        activeNotes.add({
          'id': doc.id, // Include the document ID for updates/deletes
          'title': doc['title'],
          'subtitle': doc['subtitle'],
          'time': (doc['time'] as Timestamp).toDate(),
          'completed': doc['completed'],
        });
      }

      // Populate history notes
      for (var doc in historySnapshot.docs) {
        historyNotes.add({
          'id': doc.id,
          'title': doc['title'],
          'subtitle': doc['subtitle'],
          'time': (doc['time'] as Timestamp).toDate(),
          'completed': doc['completed'],
        });
      }

      notifyListeners(); // Notify listeners that the data has changed
    } catch (e) {
      print("Error fetching notes: $e");
    }
  }
}
