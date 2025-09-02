import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

import '../helpers/DateUtils.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class Chat {
  static String get modelName => 'Chat';

  Chat({
    this.modelRef,
    required this.picnicId,
    required this.topic,
    this.participantsRef,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final DocumentReference? modelRef;
  final String picnicId;
  final String topic;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  final CollectionReference? participantsRef;

  factory Chat.fromFirestore(
    Map<String, dynamic>? data,
    DocumentReference modelReference,
  ) {
    final errors = <String>[];

    final DateTime? createdAt = DateUtils.parseDateTime(data?['createdAt']);
    final DateTime? updatedAt = DateUtils.parseDateTime(data?['updatedAt']);
    final DateTime? deletedAt = DateUtils.parseDateTime(data?['deletedAt']);

    final String? chatTopic =
        data?['topic'] ?? _Valid.required(errors, 'topic');
    final String? picnicId =
        data?['picnicUid'] ?? "test"; //TODO: Remove in later testing

    //subcollections are not retrieved automatically, request them if required (will generate another query)
    final CollectionReference participants = modelReference.collection(
      "participants",
    );

    if (errors.isNotEmpty) {
      throw DocumentFormatException(
        "Missing [${errors.length}] required field(s) for model <${Chat.modelName}>:\n\t ${errors.join("\n\t")}",
      );
    }

    return Chat(
      modelRef: modelReference,
      picnicId: picnicId!,
      topic: chatTopic!,
      participantsRef: participants,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Chat copyWith({
    DocumentReference? modelRef,
    String? picnicId,
    String? topic,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    CollectionReference? participantsRef,
  }) {
    return Chat(
      modelRef: modelRef ?? this.modelRef,
      picnicId: picnicId ?? this.picnicId,
      topic: topic ?? this.topic,
      participantsRef: participantsRef ?? this.participantsRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? deletedAt,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    String id =
        modelRef?.id ??
        (FirebaseFirestore.instance.collection('chats').doc().id); //Generate one on the server and retrieve

    return {
      'picnicUid': picnicId,
      'topic': topic,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      if (participantsRef != null) 'participants': participantsRef,
    };
  }
}
