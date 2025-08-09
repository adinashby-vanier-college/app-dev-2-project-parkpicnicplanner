import 'package:flutter/material.dart';
import 'package:picnic/mixins/overlay_mixin.dart';
import 'package:picnic/screens/chat_detail_screen.dart';

import 'number_stepper.dart';

class ChatListItem extends StatefulWidget {
  final int initialUnread;

  const ChatListItem({super.key, this.initialUnread = 0});

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
        builder: (context) => ChatDetailScreen(chatKey: "1337"),
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
      title: Text("Topic for Chat"),
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
