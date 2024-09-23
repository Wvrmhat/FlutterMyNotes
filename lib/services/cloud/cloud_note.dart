import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote({
    required this.documentId, 
    required this.ownerUserId, 
    required this.text,
    });

  // allow firestore to give a snapshot of our cloudnote, then we create an instance of our cloudnote from that
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  ownerUserId = snapshot.data()[ownerUserIdFieldName],
  text = snapshot.data()[textFieldName] as String;
  
}
