
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

    try {
      // Save note to Firestore
      DocumentReference docRef = await _firestore.collection('notes').add(newNote);
      newNote['id'] = docRef.id; // Store the document ID for future reference
      activeNotes.add(newNote);
      notifyListeners();
    } catch (e) {
      print("Error adding note to Firestore: $e");
    }
  }

  // Delete a note and move it to history
  Future<void> deleteNoteAt(int index) async {
    var noteToDelete = activeNotes[index];
    noteToDelete['completed'] = true;
    noteToDelete['subtitle'] += "   Deleted";
    historyNotes.add(noteToDelete);

    try {
      // Delete the note from Firestore
      await _firestore.collection('notes').doc(noteToDelete['id']).delete();
      activeNotes.removeAt(index);
      notifyListeners();
    } catch (e) {
      print("Error deleting note from Firestore: $e");
    }
  }

  // Delete a history note at the specified index
  Future<void> deleteHistoryNoteAt(int index) async {
    // Ensure the index is valid
    if (index < 0 || index >= historyNotes.length) {
      throw RangeError('Index out of range: $index');
    }

    var noteToDelete = historyNotes[index];
    
    try {
      // Delete the document from Firestore using the document ID
      await _firestore.collection('notes').doc(noteToDelete['id']).delete();

      // Remove the note from the local historyNotes list
      historyNotes.removeAt(index);
      notifyListeners();
    } catch (e) {
      print("Error deleting history note from Firestore: $e");
    }
  }

  // Edit a note in Firestore
  Future<void> editNoteAt(int index, String title, String subtitle, DateTime dateTime) async {
    var noteToEdit = activeNotes[index];

    try {
      // Update Firestore
      await _firestore.collection('notes').doc(noteToEdit['id']).update({
        'title': title,
        'subtitle': subtitle,
        'time': dateTime,
        'completed': false,
      });

      // Update active notes
      activeNotes[index] = {
        'id': noteToEdit['id'], // Keep the ID intact
        'title': title,
        'subtitle': subtitle,
        'time': dateTime,
        'completed': false,
      };

      notifyListeners();
    } catch (e) {
      print("Error updating note in Firestore: $e");
    }
  }

  // Toggle completion status and move to history
  Future<void> toggleCompletion(int index) async {
    var noteToToggle = activeNotes[index];
    noteToToggle['subtitle'] += "   Done";
    historyNotes.add(noteToToggle);

    try {
      // Update Firestore
      await _firestore.collection('notes').doc(noteToToggle['id']).update({'completed': true});
      activeNotes.removeAt(index);
      notifyListeners();
    } catch (e) {
      print("Error toggling completion in Firestore: $e");
    }
  }

  // Restore a note from history to active notes
  Future<void> restoreNoteAt(int index) async {
    var noteToRestore = historyNotes[index];
    noteToRestore['subtitle'] = noteToRestore['subtitle']
        .replaceAll("Not yet", "")
        .replaceAll("Done", "")
        .replaceAll("Deleted", "")
        .trim();

    try {
      // Save restored note to Firestore
      DocumentReference docRef = await _firestore.collection('notes').add(noteToRestore);
      noteToRestore['id'] = docRef.id; // Store the document ID for the restored note

      activeNotes.add(noteToRestore);
      historyNotes.removeAt(index);
      notifyListeners();
    } catch (e) {
      print("Error restoring note to Firestore: $e");
    }
  }

  // Fetch notes from Firestore
  Future<void> fetchNotes() async {
    try {
      // Fetch active notes (where 'completed' is false)
      QuerySnapshot activeSnapshot = await _firestore.collection('notes').where('completed', isEqualTo: false).get();

      // Fetch history notes (where 'completed' is true)
      QuerySnapshot historySnapshot = await _firestore.collection('notes').where('completed', isEqualTo: true).get();

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
