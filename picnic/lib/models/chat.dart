import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef Valid = ModelValidators;

class Chat {
  Chat({
    required this.chatMessages,
    required this.picnicId,
    required this.topic,
  });

  final DocumentReference chatMessages;
  final String picnicId;
  final String topic;
  bool valid = true;

  factory Chat.fromFirestore(Map<String, dynamic>? data) {
    final errors = <String>[];

    final String? chatTopic = data?['topic'] ?? Valid.required(errors, 'topic');
    final String? picnicId =
        data?['picnic_id'] ?? "test"; //TODO: Remove in later testing
    final DocumentReference? messagesRef =
        data?['chat_messages'] ?? Valid.required(errors, 'chat_messages');

    if (errors.isNotEmpty) {
      throw DocumentFormatException("Missing required fields");
    }

    return Chat(
      chatMessages: messagesRef!,
      picnicId: picnicId!,
      topic: chatTopic!,
    );
  }
}
