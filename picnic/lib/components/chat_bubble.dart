import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  ChatBubble({
    super.key,
    required this.userBubble,
    required this.content,
    required this.senderName,
  });

  final GlobalKey _bubbleKey = GlobalKey();
  final bool userBubble;
  final String content;
  final String senderName;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Build flag tab for bubble

    return Row(
      mainAxisAlignment: widget.userBubble
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, // Max 70% width
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              color: (widget.userBubble)
                  ? Colors.amberAccent
                  : Colors.blueGrey[100],
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  if (!widget.userBubble) Text(widget.senderName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(widget.content, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
