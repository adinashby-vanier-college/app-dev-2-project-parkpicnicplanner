import 'package:flutter/material.dart';

import 'arriving_items_detail_list_item.dart';

class ArrivingItemsDetailList extends StatefulWidget {
  final String itemName;

  const ArrivingItemsDetailList({
    super.key,
    required this.itemName
  });

  @override
  State<ArrivingItemsDetailList> createState() =>
      _ArrivingItemsDetailListState();
}

class _ArrivingItemsDetailListState extends State<ArrivingItemsDetailList> {
  late String _selectedItemName;

  @override
  void initState() {
    super.initState();
    _selectedItemName = widget.itemName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Individuals Bringing',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          Text(
            _selectedItemName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey[400]!),
                  bottom: BorderSide(color: Colors.grey[400]!)
                ),
            ),
            child: Row(
              children: [
                SizedBox(width: 56),
                Expanded(child: Text("Person", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 64, child: Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              clipBehavior: Clip.antiAlias,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                ArrivingItemsDetailListItem(),
                ArrivingItemsDetailListItem(),
                ArrivingItemsDetailListItem(),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
