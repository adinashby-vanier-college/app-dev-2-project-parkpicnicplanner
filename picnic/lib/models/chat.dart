import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class Chat {
  static String get modelName => 'Chat';

  Chat({
    required this.modelRef,
    required this.picnicId,
    required this.topic,
    required this.participants
  });

  final DocumentReference modelRef;
  final String picnicId;
  final String topic;
  final CollectionReference participants;

  factory Chat.fromFirestore(Map<String, dynamic>? data, DocumentReference modelReference) {
    final errors = <String>[];

    final String? chatTopic = data?['topic'] ?? _Valid.required(errors, 'topic');
    final String? picnicId =
        data?['picnicUid'] ?? "test"; //TODO: Remove in later testing

    //subcollections are not retrieved automatically, request them if required (will generate another query)
    final CollectionReference participants = modelReference.collection("participants");

    if (errors.isNotEmpty) {
      throw DocumentFormatException("Missing [${errors.length}] required field(s) for model <${Chat.modelName}>:\n\t ${errors.join("\n\t")}");
    }

    return Chat(
      modelRef: modelReference,
      picnicId: picnicId!,
      topic: chatTopic!,
      participants: participants,
    );
  }
}
