import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Listen to authentication state
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // REGISTER USER
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Registration failed.');
    }

    await user.updateDisplayName(name.trim());

    // Store profile information in Firestore.
    // Passwords are never stored here.
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim(),
      'department': department.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LOGIN USER
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // LOGOUT USER
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // GET CURRENT USER PROFILE
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid).get();
  }

  // SEND PASSWORD RESET EMAIL
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }
}