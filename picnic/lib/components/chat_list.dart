import 'package:flutter/material.dart';
import 'package:picnic/components/chat_list_item.dart';
import 'package:picnic/components/requested_items_list_items.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() =>
      _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ChatListItem(initialUnread: 2),
        ChatListItem(),
        ChatListItem(initialUnread: 3),
        ChatListItem(),
      ],
    );
  }
}