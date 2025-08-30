import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:picnic/models/picnic.dart';
import 'package:picnic/services/picnic_participant_service.dart';
import 'package:picnic/services/service_locator.dart';

class PicnicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = auth.FirebaseAuth.instance;
  final picnicParticipantService = getIt<PicnicParticipantService>();

  // Create a picnic
  Future<void> createPicnic(Picnic picnic) async {
    Map<String,dynamic> modelMap = picnic.toMap();
    String userUID = _auth.currentUser!.uid;

    try {
      await _firestore.runTransaction((transaction) async {
        modelMap['ownerId'] ??= userUID;
        modelMap['createdAt'] ??= FieldValue.serverTimestamp();
        modelMap['updatedAt'] ??= FieldValue.serverTimestamp();
        modelMap['description'] ??= "";

        transaction.set(
            _firestore.collection('picnics').doc(modelMap['id']),
            modelMap
        );

      });
      picnicParticipantService.createPicnicParticipant(picnicUid: modelMap['id'], userUid: userUID );

    } catch (e) {
      throw Exception('Failed to save picnic: $e');
    }
  }

  // Get picnic participant by picnicUid and userUid
  Future<Picnic?> getPicnic(String picnicUid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('picnics')
          .doc(picnicUid)
          .get();

      if (doc.exists) {
        return Picnic.fromFirestore(doc.data() as Map<String, dynamic>, doc.reference);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chat: $e');
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
  Stream<List<Picnic>> getPicnicStream() {
    return _firestore
        .collection('picnics')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Picnic.fromFirestore(doc.data(), doc.reference);
      }).toList();
    });
  }

  // // Create initial Chat document
  // Future<void> createChat(Chat chat) async {
  //   try {
  //     final newChat = chat.copyWith(
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );
  //     await _firestore
  //         .collection('chats')
  //         .doc(chat.id)
  //         .set(newChat.toMap());
  //   } catch (e) {
  //     throw Exception('Failed to create chat: $e');
  //   }
  // }
}