import 'package:flutter/material.dart';
import 'package:group_project/components/chat_bubble.dart';

import '../components/dropdown_icon_button.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatKey;

  ChatDetailScreen({super.key, required this.chatKey});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();


  bool hasNoMessageText = true;

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //Shared styles
  ButtonStyle iconBtnStyle = IconButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  //TODO: replace with real chat... for now, use mockup
  final List<ChatMessage> fakeMessages = [
    const ChatMessage(
      content: "Hello there?",
      senderId: "1",
      senderName: "Fred",
    ),
    const ChatMessage(content: "Sup!", senderId: "2", senderName: "Tony"),
    const ChatMessage(content: "Hi Guys!", senderId: "3", senderName: "Kekoa"),
  ];

  void _sendMessage() {
    String messageContent = messageController.text;

    setState(() {
      fakeMessages.add(
        ChatMessage(
          content: messageContent,
          senderName: "Kekoa",
          senderId: "3",
        ),
      );
      messageController.text = "";
      hasNoMessageText = true;
    });
    _scrollToBottom();
  }

  void _onMessageChange(String msg){
    setState(() {
      hasNoMessageText = msg.isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    //TODO: load actual chat
  }

  Widget _buildChatActionBar() {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(), color: Colors.grey[200]),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: OverflowBar(
          spacing: 8,
          children: [
            DropdownIconButton(
              icon: Icon(Icons.people_alt_outlined),
              buttonStyle: iconBtnStyle,
              child: Container(),
            ),
            // IconButton(
            //   onPressed: () {},
            //   icon: Icon(Icons.abc),
            //   style: iconBtnStyle,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessageBar() {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(), color: Colors.amber[400]),
      child: Container(
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.all(8),
        child: Row(
          spacing: 12,
          children: [
            Icon(Icons.message_outlined),
            Expanded(
              child: TextField(
                onEditingComplete:  (hasNoMessageText) ? null : _sendMessage,
                onChanged: _onMessageChange,
                controller: messageController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (hasNoMessageText) ? null : _sendMessage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.send), const Text("Send")],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMessageList() {
    List<Widget> messageList = [];
    messageList =
        fakeMessages.map((ChatMessage msg) {
          return ChatBubble(
            userBubble: (msg.senderId == "3"),
            content: msg.content,
            senderName: msg.senderName,
          );
        }).toList();
    return messageList;
  }

  Widget _buildChatBody() {
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: 200),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(spacing: 12, children: _buildMessageList()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Topic of Chat')),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildChatActionBar(),
          _buildChatBody(),
          _buildChatMessageBar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

//Code below is just for mockup
class ChatMessage {
  final String content;
  final String senderId;
  final String senderName;

  const ChatMessage({
    required this.content,
    required this.senderId,
    required this.senderName,
  });

  bool isUsersMessage({senderId}) {
    return (this.senderId == senderId);
  }
}
