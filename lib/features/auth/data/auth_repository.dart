import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/app_user.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final credential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Authentication network request timed out. Check your connection or use Quick Demo Access below.',
            ),
          );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create authentication account.');
      }

      try {
        await firebaseUser.updateDisplayName(name).timeout(const Duration(seconds: 4));
      } catch (_) {}

      final appUser = AppUser(
        id: firebaseUser.uid,
        name: name,
        email: email,
        role: role,
        phone: phone,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(appUser.toMap())
            .timeout(const Duration(seconds: 6));
      } catch (_) {
      }

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication error during sign up.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Sign in request timed out. Please check connection or try Demo Mode.',
            ),
          );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('Sign in failed: Invalid credentials.');
      }

      try {
        final doc = await _firestore
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 6));
        if (doc.exists && doc.data() != null) {
          return AppUser.fromMap(doc.data()!, doc.id);
        }
      } catch (_) {}

      return AppUser(
        id: uid,
        name: credential.user?.displayName ?? email.split('@').first,
        email: email,
        role: UserRole.technician,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Invalid email or password.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 6));
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }

  Stream<AppUser?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return AppUser.fromMap(snapshot.data()!, snapshot.id);
    });
  }
}
