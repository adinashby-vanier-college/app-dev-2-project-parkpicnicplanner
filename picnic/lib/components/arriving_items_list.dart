import 'package:flutter/material.dart';
import 'package:picnic/components/arriving_items_list_item.dart';

class ArrivingItemsList extends StatefulWidget {
  const ArrivingItemsList({super.key});

  @override
  State<ArrivingItemsList> createState() =>
      _ArrivingItemsListState();
}

class _ArrivingItemsListState extends State<ArrivingItemsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ArrivingItemsListItem(),
        ArrivingItemsListItem(),
        ArrivingItemsListItem(),
      ],
    );
  }
}