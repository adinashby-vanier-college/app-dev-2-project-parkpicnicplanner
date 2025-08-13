import 'package:flutter/material.dart';
import 'package:picnic/components/chat_list_item.dart';
import 'package:picnic/components/requested_items_list_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../exceptions/document_format_exception.dart';
import '../models/chat.dart';

final _firestore = FirebaseFirestore.instance;

class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.picnicId});
  final String picnicId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Widget _fetchChats(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chats').where("picnicUid", isEqualTo: widget.picnicId).snapshots(),
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
          final data = chat.data() as Map<String, dynamic>?;

          try {
            final listItem = ChatListItem(model: Chat.fromFirestore(data, chat.reference));
            chatListItems.add(listItem);
          } on DocumentFormatException catch( e) {
            print(e);
            print('Document data: ${data}');
          }

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
