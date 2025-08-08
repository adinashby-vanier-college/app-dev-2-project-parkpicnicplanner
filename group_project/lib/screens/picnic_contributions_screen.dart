import 'package:flutter/material.dart';
import 'package:group_project/components/arriving_items_list.dart';

import '../components/requested_items_list.dart';

class PicnicContributionsScreen extends StatefulWidget {
  const PicnicContributionsScreen({Key? key}) : super(key: key);

  @override
  State<PicnicContributionsScreen> createState() =>
      _PicnicContributionsScreenState();
}

class _PicnicContributionsScreenState extends State<PicnicContributionsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                  text: "Arriving",
                  icon: Icon(Icons.backpack)
              ),
              Tab(
                  text: "Requested",
                  icon: Icon(Icons.shopping_basket)
              ),
            ],
          ),
          title: const Text('Picnic Contributions'),
        ),
        body: const TabBarView(
          children: [
            ArrivingItemsList(),
            RequestedItemsList(),
          ],
        ),
      ),
    );
  }
}
