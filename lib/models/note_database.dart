import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_demo/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier{
  static late Isar isar;

  // Initialize DB
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema],
      directory: dir.path,
    );
  }

  // List of data
  List<Note> noteList = [];

  // Create
  Future<void> addNotes(String inputText) async {
    final newNote = Note()..text = inputText;

    await isar.writeTxn(() => isar.notes.put(newNote));

    // re-read
    fetchNotes();
  }

  // Read
  Future<void> fetchNotes() async {
    List<Note> lists = await isar.notes.where().findAll();
    noteList.clear();
    noteList.addAll(lists);
    notifyListeners();
  }

  // Update
  Future<void> updateNotes(int id, String inputText) async {
    final existingNote = await isar.notes.get(id);

    if (existingNote != null) {
      existingNote.text = inputText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  // Delete
  Future<void> deleteNotes(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}
