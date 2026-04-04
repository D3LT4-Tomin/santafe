import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  static Future<UserModel?> signIn(String email, String password) async {
    final credential = await FirebaseService.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final uid = credential.user!.uid;

      final userDoc = await FirebaseService.userDoc(uid).get();
      if (!userDoc.exists) {
        final newUser = UserModel(
          id: uid,
          email: email,
          createdAt: DateTime.now(),
        );
        await FirebaseService.userDoc(uid).set(newUser.toFirestore());
      }

      return getUserData(uid);
    }
    return null;
  }

  static Future<UserModel?> signUp(
    String email,
    String password,
    String? displayName,
  ) async {
    final credential = await FirebaseService.auth
        .createUserWithEmailAndPassword(email: email, password: password);

    if (credential.user != null) {
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await FirebaseService.userDoc(
        credential.user!.uid,
      ).set(user.toFirestore());
      return user;
    }
    return null;
  }

  static Future<void> signOut() async {
    await FirebaseService.auth.signOut();
  }

  static Future<UserModel?> getUserData(String uid) async {
    final doc = await FirebaseService.userDoc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  static Future<void> updateUser(String uid, UserModel user) async {
    await FirebaseService.userDoc(uid).update(user.toFirestore());
  }

  static User? get currentUser => FirebaseService.auth.currentUser;

  static Stream<User?> authStateChanges() =>
      FirebaseService.auth.authStateChanges();
}
