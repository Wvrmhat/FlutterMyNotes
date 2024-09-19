import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';


@immutable      // means that internals are never changed upon initialization
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}

