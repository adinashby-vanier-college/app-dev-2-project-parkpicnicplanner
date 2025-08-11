import 'package:flutter/material.dart';
import 'package:picnic/components/chat_list.dart';

class PicnicChatsScreen extends StatefulWidget {
  const PicnicChatsScreen({super.key});

  @override
  State<PicnicChatsScreen> createState() =>
      _PicnicChatsScreenState();
}

class _PicnicChatsScreenState extends State<PicnicChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                  text: "Topics",
                  icon: Icon(Icons.chat_bubble)
              ),
              Tab(
                  text: "Messages",
                  icon: Icon(Icons.inbox)
              ),
            ],
          ),
          title: const Text('Picnic Conversations'),
        ),
        body: TabBarView(
          children: [
            ChatList(picnicId:"test"),
            Container(),
          ],
        ),
      ),
    );
  }
}