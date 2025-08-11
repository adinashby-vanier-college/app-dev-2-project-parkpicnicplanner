import 'package:flutter/material.dart';
import 'package:picnic/components/chat_list_item.dart';
import 'package:picnic/components/requested_items_list_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Widget _fetchChats(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final chats = snapshot.data!.docs;

        List<Widget> chatListItems = [];
        for (var chat in chats) {
          print('Document data: ${chat.data()}');

          final chatTopic = chat['topic'];
          final picnicId = chat['picnic_id'];

          final listItem = ChatListItem(topic: chatTopic);
          chatListItems.add(listItem);
        }
        return ListView(
          padding: EdgeInsets.all(8),
          children: chatListItems,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _fetchChats(context);
  }
}
