import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;


class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0)
    {
      throw CouldNotUpdateNote();
    }
    else
    {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {     
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable, 
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));

  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable, 
      limit: 1, 
      where: 'id = ?', 
      whereArgs: [id],
     );
     if (notes.isEmpty)
     {
      throw CouldNotFindNote();
     }
     else
     {
      return DatabaseNote.fromRow(notes.first);     // creates an instance of database note
     }

  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable, 
      where: 'id = ?', 
      whereArgs: [id],
    );
    if (deletedCount == 0)
    {
      throw CouldNotDeleteNote();     
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {    // returns database note and says who is the owner of it
    final db = _getDatabaseOrThrow();

    // make sure owner exists in database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    
    const text = '';
    // CREATE THE NOTE
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1
    });

    final note = DatabaseNote(
      id: noteId, 
      userId: 
      owner.id, 
      text: text, 
      isSyncedWithCloud: true,
      );
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable, 
      limit: 1,
      where: 'email = ?', whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty)
    {
      throw CouldNotFindUser();
    }
    else
    {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable, 
      limit: 1,
      where: 'email = ?', whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty)
    {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {        // gives user id back
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(            // returns id and email
      id: userId,
      email: email,
    );
  }


  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable, 
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1)
    {
      throw CouldNotDeleteUser();       // handles exception at the call site
    }
  }

  Database _getDatabaseOrThrow() {       // private function internal classes make use of 
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    }
    else
    {
      return db;
    }
  }

  Future<void> close() async {     // closes the database
  final db = _db;
  if (db == null) {
    throw DatabaseIsNotOpen();
  }
  else
  {
    await db.close();
    _db = null;
  }


  }
  
  Future<void> open() async {         // function that opens the database
  if(_db != null)
  {
    throw DatabaseAlreadyOpenException();
  }
  try {
    final docsPath = await getApplicationDocumentsDirectory();
    final dbPath = join(docsPath.path, dbName);
    final db = await openDatabase(dbPath);
    _db = db;

    // CREATE THE USER TABLE
    await db.execute(createUserTable);

    // CREATES NOTE TABLE
    await db.execute(createNoteTable);


  } on MissingPlatformDirectoryException {
    throw UnableToGetDocumentsDirectory();

  }


  }          
}



@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });



  DatabaseUser.fromRow(Map<String, Object?> map)     // reads the table for every row
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person ID = $id, email = $email';

  @override bool operator == (covariant DatabaseUser other) => id == other.id;     // covariant allows you to change behaviour of input param, so they do not conform to signature of that parameter in superclass

  @override
  int get hashCode => id.hashCode;
  
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud,});

  DatabaseNote.fromRow(Map<String, Object?> map)     // reads the table for every row
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = 
          (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;
  

  @override 
  String toString() => 
    'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud';

  @override 
  bool operator == (covariant DatabaseUser other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
  
}

const dbName = 'notes.db';     // the filename
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
      "id"	INTEGER NOT NULL,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
    ); ''';

const createNoteTable = ''' CREATE TABLE IF NOTE EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT,
      "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY("id" AUTOINCREMENT),
      FOREIGN KEY("user_id") REFERENCES "user"("id")
    ); ''';