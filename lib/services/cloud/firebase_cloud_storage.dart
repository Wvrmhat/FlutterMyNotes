import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');     // talks to the firestore

  Future<void> deleteNote({required String documentId}) async {
    try{
      notes.doc(documentId).delete();
    }
    catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId, 
    required String text,
    }) async {
      try{
        await notes.doc(documentId).update({textFieldName: text});    // uses the documentId path
      }
      catch (e) {
        throw CouldNotUpdateNoteException();
      }
    }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>    // grabs a stream of data as it is involving
    notes.snapshots().map((event) => event.docs                       // takes the stream of snapshots, snapshots mean we want to see all changes as they are happening live
      .map((doc) => CloudNote.fromSnapshot(doc))
      .where((note) => note.ownerUserId == ownerUserId));     // says we are only intereseted in notes whose owneruserId is the owneruserID provided     

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try{
      return await notes.where(
        ownerUserIdFieldName,
        isEqualTo: ownerUserId
      )
      .get()      // executes the query
      .then((value) => value.docs.map((doc) {     // maps all docs being read
        return CloudNote(
          documentId: doc.id, 
          ownerUserId: doc.data()[ownerUserIdFieldName] as String,
          text: doc.data()[textFieldName] as String,
          );
      }));

    }catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }
  // singleton
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();   // static final field calls private initializer
  FirebaseCloudStorage._sharedInstance();   // private constructor
  factory FirebaseCloudStorage() => _shared;      // factory contructor

}