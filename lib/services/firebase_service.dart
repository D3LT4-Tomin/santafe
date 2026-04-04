import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static FirebaseFirestore get db => _db;
  static FirebaseAuth get auth => _auth;

  static String? get currentUserId => _auth.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      _db.collection('users');

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersCollection.doc(uid);

  static CollectionReference<Map<String, dynamic>> userTransactionsRef(
    String uid,
  ) => usersCollection.doc(uid).collection('transactions');

  static CollectionReference<Map<String, dynamic>> userAccountsRef(
    String uid,
  ) => usersCollection.doc(uid).collection('accounts');
}
