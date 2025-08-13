import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create or update user
  Future<void> saveUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toUpdateMap());
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  // Get user by ID
  Future<User?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      Reference ref = _storage.ref().child('profile_pictures/$userId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Delete old profile picture
  Future<void> deleteProfilePicture(String userId) async {
    try {
      Reference ref = _storage.ref().child('profile_pictures/$userId.jpg');
      await ref.delete();
    } catch (e) {
      // It's okay if the file doesn't exist
    }
  }

  // Stream user for real-time updates
  Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return User.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // Create initial user document (usually called after authentication)
  Future<void> createUser(User user) async {
    try {
      final newUser = user.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(newUser.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
}