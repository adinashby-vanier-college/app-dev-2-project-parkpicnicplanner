import 'package:flutter/material.dart';
import 'package:picnic/screens/chat_detail_screen.dart';

import '../models/chat.dart';

class ChatListItem extends StatefulWidget {
  ChatListItem({
    super.key,
    required this.model,
    this.initialUnread = 0
  });

  final Chat model;
  final int initialUnread;

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  Color? _pillColor = Colors.blue[100];
  int _unreadMessages = 0;

  void viewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chatModel: widget.model),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _unreadMessages = widget.initialUnread;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: viewChat,
      leading: Icon(
        Icons.chat_rounded,
        size: 24.0,
        color: Colors.blueGrey.withAlpha(100),
      ),
      title: Text(widget.model.topic),
      trailing:
          (_unreadMessages <= 0)
              ? null
              : Container(
                margin: EdgeInsets.all(4),
                child: Ink(
                  decoration: BoxDecoration(
                    color: _pillColor,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$_unreadMessages",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
