import 'package:flutter/material.dart';

class ArrivingItemsDetailListItem extends StatefulWidget {
  const ArrivingItemsDetailListItem({super.key});

  @override
  State<ArrivingItemsDetailListItem> createState() =>
      _ArrivingItemsDetailListItemState();
}

class _ArrivingItemsDetailListItemState extends State<ArrivingItemsDetailListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          radius: 18,
        ),
        title: Text("First LastName", style: TextStyle(fontSize: 14)),
        trailing: Text(
          "1",
          style: TextStyle(
            color: Colors.black, // or any visible color
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}