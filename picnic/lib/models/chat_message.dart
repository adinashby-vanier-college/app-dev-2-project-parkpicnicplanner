import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class ChatMessage {
  ChatMessage({
    required this.modelRef,
    required this.content,
    required this.senderUid
  });

  final DocumentReference modelRef;
  final String content;
  final String senderUid;

  factory ChatMessage.fromFirestore(Map<String, dynamic>? data, DocumentReference modelReference) {
    final errors = <String>[];

    final String? content = data?['content'] ?? _Valid.required(errors, 'content');
    final String? sender = data?['senderUid'] ?? _Valid.required(errors,'senderUid');

    if (errors.isNotEmpty) {
      throw DocumentFormatException("Missing required fields");
    }

    return ChatMessage(
      modelRef: modelReference,
      content: content!,
      senderUid: sender!,
    );
  }
}
