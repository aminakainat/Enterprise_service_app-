import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;
  Future<String?> uploadFieldProofImage({
    required String jobId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('jobs/$jobId/proofs/$fileName');
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      ).timeout(const Duration(seconds: 15));

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (_) {
      return null;
    }
  }
  Future<String?> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      ).timeout(const Duration(seconds: 15));

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (_) {
      return null;
    }
  }
}

final storageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});
