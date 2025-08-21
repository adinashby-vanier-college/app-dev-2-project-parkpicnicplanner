import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picnic/components/chat_bubble.dart';

import '../components/dropdown_icon_button.dart';
import '../exceptions/document_format_exception.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

User? _loggedInUser;

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.chatModel});
  final Chat chatModel;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool hasNoMessageText = true;
  bool initialLoad = true;

  //Shared styles
  ButtonStyle iconBtnStyle = IconButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        _loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      if (!initialLoad) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(
          scrollController.position.maxScrollExtent,
        );
        setState(() {
          initialLoad = false;
        });
      }
    }
  }

  Widget _fetchChatMessages(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.chatModel.modelRef.collection("messages").orderBy("timestamp").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final chatMessages = snapshot.data!.docs.reversed;

        List<ChatMessage> messageList = [];

        for (var chatMessage in chatMessages) {
          final data = chatMessage.data() as Map<String, dynamic>?;

          //in the case of no data, skip iteration
          if (data == null) continue;

          //Lookup additional data and add it to the chat message

          data['senderName'] = "hello";

          try {
            final listItem = ChatMessage.fromMap(
              data,
              modelRef: chatMessage.reference,
            );
            messageList.add(listItem);
          } on DocumentFormatException catch (e) {
            print(e);
            print('Document data: $data');
          }
        }

        //Create a ChatBubble for each ChatMessage
        List<Widget> messageWidgetList = messageList.map((ChatMessage msg) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ChatBubble(
              content: msg.content,
              senderName: "none",
              userBubble: ( msg.senderUid == _loggedInUser?.uid),
            ),
          );
        }).toList();

        // Scroll to bottom after the frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView(
          shrinkWrap: true,
          reverse: true,
          children: messageWidgetList,
        );
      },
    );
  }

  void _sendMessage() {
    String messageContent = messageController.text;

    widget.chatModel.modelRef.collection("messages").add({
      "content": messageContent,
      'timestamp': FieldValue.serverTimestamp(),
      "senderUid": _loggedInUser!.uid,
    });

    messageController.text = "";
    hasNoMessageText = true;
  }

  void _onMessageChange(String msg) {
    setState(() {
      hasNoMessageText = msg.isEmpty;
    });
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
                onEditingComplete: (hasNoMessageText) ? null : _sendMessage,
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

  Widget _buildChatBody(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: 200),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: AnimatedOpacity(
            opacity: initialLoad ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: _fetchChatMessages(context)
          ),
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
          Container(child: _buildChatBody(context)),
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