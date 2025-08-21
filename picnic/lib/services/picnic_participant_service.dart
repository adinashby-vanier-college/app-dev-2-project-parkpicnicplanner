import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:picnic/models/picnic_participant.dart';

class PicnicParticipantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;

  // // Create or update user
  // Future<void> saveUser(User user) async {
  //   try {
  //     await _firestore
  //         .collection('users')
  //         .doc(user.id)
  //         .update(user.toUpdateMap());
  //   } catch (e) {
  //     throw Exception('Failed to save user: $e');
  //   }
  // }

  // Get picnic participant from reference by userUid
  Future<PicnicParticipant?> getPicnicParticipant(CollectionReference participants, String userUid) async {
    try {
      DocumentSnapshot doc = await participants
          .doc(userUid)
          .get();

      if (doc.exists) {
        return PicnicParticipant.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get picnic participant: $e');
    }
  }

  // // Delete old profile picture
  // Future<void> deleteProfilePicture(String userId) async {
  //   try {
  //     Reference ref = _storage.ref().child('profile_pictures/$userId.jpg');
  //     await ref.delete();
  //   } catch (e) {
  //     // It's okay if the file doesn't exist
  //   }
  // }

  // Stream picnic participants for real-time updates
  Stream<List<PicnicParticipant>> getPicnicParticipantStream(String picnicUid) {
    return _firestore
        .collection('picnics')
        .doc(picnicUid)
        .collection('participants')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return PicnicParticipant.fromFirestore(doc);
      }).toList();
    });
  }

  // Create initial user document (usually called after authentication)
  Future<void> createPicnicParticipant({required String picnicUid, String? userUid}) async {
    try {
      userUid = userUid ?? _auth.currentUser!.uid;

      await _firestore.runTransaction( (transaction) async {
        final picnicRef = _firestore.collection('picnics').doc(picnicUid);
        final participantRef = picnicRef.collection('participants').doc(userUid);

        final picnicSnapshot = await picnicRef.get();

        if (picnicSnapshot.exists) {
          // Add participant
          transaction.set(participantRef, { "test": "example"});
        }
      });
    } catch (e) {
      throw Exception('Failed to create picnic participant: $e');
    }
  }

  Future<void> updatePicnicParticipant({required Map<String, dynamic> fields, required String picnicUid, String? userUid}) async {
    try {
      //If empty field map provided, exit early
      if (fields.isEmpty ) return;

      userUid = userUid ?? _auth.currentUser?.uid;

      // Validate that we have a user ID
      if (userUid == null || userUid.isEmpty) {
        throw Exception('User not authenticated');
      }

      //Priority field values override those present in the passed fields map
      final priorityFields = {"userUid":userUid};

      final combinedFields = {...fields, ...priorityFields};

      await _firestore.runTransaction( (transaction) async {
        final picnicRef = _firestore.collection('picnics').doc(picnicUid);
        final participantRef = picnicRef.collection('participants').doc(userUid);

        final picnicSnapshot = await picnicRef.get();

        if (picnicSnapshot.exists) {
          PicnicParticipant newParticipant = PicnicParticipant.fromMap(combinedFields);
          transaction.update(participantRef, newParticipant.toMap());
        }
      });
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        print('Security rule violation detected!');
      }
    }
  }

}