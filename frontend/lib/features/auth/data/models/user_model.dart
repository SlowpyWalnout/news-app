import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:news_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.photoURL,
  });

  factory UserModel.fromFirebaseUser(fb_auth.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
    );
  }

  // Public profile doc (`users/{uid}`, see docs/DB_SCHEMA.md), written once at
  // sign-up. `createdAt` is fixed server-side and never sent from the client.
  Map<String, dynamic> toFirestoreProfile() {
    return {
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
