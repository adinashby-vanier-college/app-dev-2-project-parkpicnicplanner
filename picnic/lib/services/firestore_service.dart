import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'dart:io';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // Delete user account completely
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user's profile picture from Storage (if exists)
      try {
        await deleteProfilePicture(userId);
      } catch (e) {
        // Continue even if profile picture deletion fails
      }

      // Delete user document from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .delete();

      // Delete user from Firebase Auth (if current user)
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
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

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  // Delete all user-related data (for complete cleanup)
  Future<void> deleteUserCompletely(String userId) async {
    try {
      // You can expand this method to delete user data from other collections
      // For example, if you have posts, comments, likes, etc. associated with the user

      // Delete from any other collections where user data might exist
      // Example:
      // await _deleteUserPosts(userId);
      // await _deleteUserComments(userId);
      // await _deleteUserLikes(userId);

      // Delete the main user document, profile picture, and Firebase Auth account
      await deleteUser(userId);
    } catch (e) {
      throw Exception('Failed to completely delete user: $e');
    }
  }

  // Alternative method that requires re-authentication for sensitive operations
  Future<void> deleteUserWithReauth(String userId, String email, String password) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        // Re-authenticate user before deletion (required for sensitive operations)
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(credential);
      }

      // Now proceed with deletion
      await deleteUser(userId);
    } catch (e) {
      throw Exception('Failed to delete user with re-authentication: $e');
    }
  }

// Helper method to delete user posts (example - implement based on your data structure)
// Future<void> _deleteUserPosts(String userId) async {
//   try {
//     QuerySnapshot posts = await _firestore
//         .collection('posts')
//         .where('userId', isEqualTo: userId)
//         .get();
//
//     for (DocumentSnapshot post in posts.docs) {
//       await post.reference.delete();
//     }
//   } catch (e) {
//     // Handle error
//   }
// }
}