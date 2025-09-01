import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picnic/components/basic_dialog.dart';
import 'package:picnic/components/chat_list.dart';
import 'package:picnic/services/picnic_participant_service.dart';
import '../mixins/overlay_mixin.dart';

import 'package:picnic/services/service_locator.dart';

class PicnicChatsScreen extends StatefulWidget {
  const PicnicChatsScreen({super.key});

  @override
  State<PicnicChatsScreen> createState() => _PicnicChatsScreenState();
}

class _PicnicChatsScreenState extends State<PicnicChatsScreen>
    with OverlayMixin {
  final GlobalKey _fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Topics", icon: Icon(Icons.chat_bubble)),
              Tab(text: "Messages", icon: Icon(Icons.inbox)),
            ],
          ),
          title: const Text('Picnic Conversations'),
        ),
        body: TabBarView(
          children: [
            ChatList(picnicId: "test"),
            Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          key: _fabKey,
          onPressed: () {
            final RenderBox renderBox =
                _fabKey.currentContext!.findRenderObject() as RenderBox;
            final position = renderBox.localToGlobal(Offset.zero);

            showMenu<String>(
              context: context,
              popUpAnimationStyle: AnimationStyle.noAnimation,
              position: RelativeRect.fromLTRB(
                position.dx,
                position.dy -
                    150, // Adjust this value to position menu above FAB
                position.dx + renderBox.size.width,
                position.dy,
              ),
              items: [
                PopupMenuItem(value: 'new_chat', child: Text('New Chat')),
                PopupMenuItem(value: 'dbg2', child: Text('DBG 2')),
                PopupMenuItem(value: 'dbg3', child: Text('DBG 3')),
              ],
            ).then((value) {
              if (value != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Selected: $value')));

                switch (value) {
                  case "new_chat":
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return BasicDialog(content:Text("Blah"), actionLabel:"Create",
                        );
                      },
                    );
                    break;
                  default:
                }
              }
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _updatePicnicParticipantTest() {
    final _auth = FirebaseAuth.instance;
    print("I am authorized as user-id:  ${_auth.currentUser!.uid}");

    final picnicParticipantService = getIt<PicnicParticipantService>();
    picnicParticipantService.updatePicnicParticipant(
      picnicUid: 'test',
      userUid: 'XHORUfmAvGSSDV3xPYxBA34jblN2',
      fields: {
        "participantNickname": "Mr. Potato Head Sr.",
        "participantBlurb": "I like to fall into pieces.",
      },
    );
  }
}
