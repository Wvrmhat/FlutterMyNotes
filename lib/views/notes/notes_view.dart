
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/main.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}


class _NotesViewState extends State<NotesView> {

  late final FirebaseCloudStorage _notesService;    // used to be NotesService 

  // make a call to create current user by getting the user email, so we expose the user email
  // String get userEmail => AuthService.firebase().currentUser!.email;       // ! is used to force unwrap optionals
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {      // have a notes service in our init state that is open
    _notesService = FirebaseCloudStorage();     // _noteservice is and instance of NoteService
    // _notesService.open();

    super.initState();
  }

  // @override
  // void dispose() {      // we close the database
  //   _notesService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add)
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);

                  if (shouldLogOut) {
                    // await AuthService.firebase().logOut();
                    context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
                    // Navigator.of(context).pushNamedAndRemoveUntil(
                    //   loginRoute, 
                    //   (_) => false,
                    // );
                  }   
                  // devtools.log(shouldLogOut.toString());
                  // break;
              }
            
          },
          itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, 
                  child:  Text("Log Out"),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(           // calculates notes and returns them from the notes
              stream: _notesService.allNotes(ownerUserId: userId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                                      
                  case ConnectionState.waiting:     // falls through to next state
                  case ConnectionState.active:
                    if (snapshot.hasData) 
                    {
                      final allNotes = snapshot.data as Iterable<CloudNote>;    //used to be List<DatabaseNote>
                      return NotesListView(
                        notes: allNotes, 
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(documentId: note.documentId);
                        },
                        onTap: (note) { 
                          Navigator.of(context).pushNamed(
                            createOrUpdateNoteRoute,
                            arguments: note,
                          );
                        },
                      );
                    }
                    else
                    {
                      return const CircularProgressIndicator();
                    }
                      
                  default:
                    return const CircularProgressIndicator();
                }
              },
            )
    );
  }
}

// Future<bool> showLogOutDialog(BuildContext context) {
//   return showDialog<bool>(
//     context: context, 
//     builder: (context) {
//       return AlertDialog(
//         title: const Text("Sign out"),
//         content: const Text("Are you sure you want to sign out?"),
//         actions: [
//           TextButton(onPressed: () {
//             Navigator.of(context).pop(false);
//           }, child: const Text("Cancel"),),
//           TextButton(onPressed: () {
//             Navigator.of(context).pop(true);
//           }, child: const Text("Log out"),),
//         ],
//       );
//     },
//   ).then((value) => value ?? false);
// }
