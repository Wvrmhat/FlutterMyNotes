import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {

  DatabaseNote? _note;
  late final NotesService _notesService;

  // text editing controller to keep track of text changes 
  late final TextEditingController _textController;

  @override 
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  //takes current note if it exists, then takes current text editing controllers text then updates in database
  void _textControllerListener() async {
    final note = _note;
    if (note == null)
    {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note, 
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // create new note
  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {

    final widgetNote = context.getArgument<DatabaseNote>();
    // getArguements returns an optional database note
    if (widgetNote != null)     // if they tapped on an existing note
    {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    //checks if we have created note, otherwise we dont create it again
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

      final currentUser = AuthService.firebase().currentUser!;    // we expect a user to be there, app crashes if user does not exist..this is because they should not be there
      final email = currentUser.email;
      final owner = await _notesService.getUser(email: email);

      final newNote = await _notesService.createNote(owner: owner);  //sets the new note, store it and save the note
      _note = newNote;
      return newNote;

  }
  // if user adds but goes back, then notes will be full of empty cells if they dont populate it. This function checks if its empty
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null)
    {
      _notesService.deleteNote(id: note.id);
    }
  }
  // automatically saves current note  
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (note != null && text.isNotEmpty)
    {
      await _notesService.updateNote(
        note: note, 
        text: text,
      );
    }
  }

  // we delete note if text is empty, otherwise we save it and get rid of textcontrollers and dispose on.
  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),      // returns database note
        builder: (context, snapshot) {    // returns a widget
        // look for done state
        switch (snapshot.connectionState) {
          case ConnectionState.done:
          
            _setupTextControllerListener();
            return TextField( 
              controller: _textController,      // proxy to a text field
              keyboardType: TextInputType.multiline,      // "enter" key at bottom right of keyboard.
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Start typing your note...",
              ),
            );


          default:
            return const CircularProgressIndicator();
          }
        },
      ), 
    );
  }
}