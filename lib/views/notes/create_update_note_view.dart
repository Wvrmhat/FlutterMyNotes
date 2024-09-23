import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/generics/get_arguments.dart';
// import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {

  CloudNote? _note;   // used to be DatabaseNote
  late final FirebaseCloudStorage _notesService;

  // text editing controller to keep track of text changes 
  late final TextEditingController _textController;

  @override 
  void initState() {
    _notesService = FirebaseCloudStorage();
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
      documentId: note.documentId, 
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // create new note
  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {   // used to return DatabaseNote

    final widgetNote = context.getArgument<CloudNote>();
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
      // final email = currentUser.email;
      // final owner = await _notesService.getUser(email: email);
      final userId = currentUser.id;
      final newNote = await _notesService.createNewNote(ownerUserId: userId);  //sets the new note, store it and save the note
      _note = newNote;
      return newNote;

  }
  // if user adds but goes back, then notes will be full of empty cells if they dont populate it. This function checks if its empty
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null)
    {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }
  // automatically saves current note  
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (note != null && text.isNotEmpty)
    {
      await _notesService.updateNote(
        documentId: note.documentId, 
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
        actions: [
            IconButton(onPressed: () async {
              final text = _textController.text;
              if (_note != null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              }
              else
              {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
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