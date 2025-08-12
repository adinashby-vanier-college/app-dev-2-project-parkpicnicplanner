import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class ChatMessage {
  ChatMessage({
    required this.modelRef,
    required this.content
  });

  final DocumentReference modelRef;
  final String content;

  factory ChatMessage.fromFirestore(Map<String, dynamic>? data, DocumentReference modelReference) {
    final errors = <String>[];

    final String? content = data?['content'] ?? _Valid.required(errors, 'content');

    if (errors.isNotEmpty) {
      throw DocumentFormatException("Missing required fields");
    }

    return ChatMessage(
      modelRef: modelReference,
      content: content!,
    );
  }
}
