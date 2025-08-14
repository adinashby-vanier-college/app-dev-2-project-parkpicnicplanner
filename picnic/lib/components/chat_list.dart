import 'package:flutter/material.dart';
import 'package:picnic/components/chat_list_item.dart';
import 'package:picnic/services/chat_service.dart';

import '../exceptions/document_format_exception.dart';
import '../models/chat.dart';
import 'package:picnic/services/service_locator.dart';


class ChatList extends StatelessWidget {
  const ChatList({super.key, required this.picnicId});
  final String picnicId;

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<List<Chat>> snapshot,
  ) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
        ),
      );
    }

    if (snapshot.hasError) {
      //TODO: report an error if it occurred
      // return _buildErrorState(snapshot.error.toString());
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //TODO: return something more meaningful than an empty container
      return Container();
    }

    return _buildChatList(snapshot.data!);
  }

  Widget _buildChatList(List<Chat> chats) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatListItem(model: chat);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatService = getIt<ChatService>();

    return StreamBuilder<List<Chat>>(
      stream: chatService.getChatStream(picnicId),
      builder: (context, snapshot) => _buildContent(context, snapshot),
    );
  }
}
