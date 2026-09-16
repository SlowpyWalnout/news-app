import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:news_app/features/auth/data/models/user_model.dart';

class FirebaseAuthDataSource {
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource(this._auth, this._firestore);

  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebaseUser(credential.user!);
  }

  Future<UserModel> signUp(String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(displayName);
    // updateDisplayName doesn't refresh the cached User instance in place.
    await credential.user!.reload();
    final user = UserModel.fromFirebaseUser(_auth.currentUser!);
    await _firestore.collection('users').doc(user.uid).set(user.toFirestoreProfile());
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : UserModel.fromFirebaseUser(user);
  }
}
