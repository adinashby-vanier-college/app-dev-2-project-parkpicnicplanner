import 'package:flutter/material.dart';
import 'package:group_project/components/requested_items_list_items.dart';

class RequestedItemsList extends StatefulWidget {
  const RequestedItemsList({super.key});

  @override
  State<RequestedItemsList> createState() =>
      _RequestedItemsListState();
}

class _RequestedItemsListState extends State<RequestedItemsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        RequestedItemsListItem(),
        RequestedItemsListItem(),
        RequestedItemsListItem(),
        RequestedItemsListItem(),
      ],
    );
  }
}