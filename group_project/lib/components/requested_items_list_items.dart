import 'package:flutter/material.dart';
import 'package:group_project/mixins/overlay_mixin.dart';

import 'number_stepper.dart';

class RequestedItemsListItem extends StatefulWidget {
  const RequestedItemsListItem({super.key});

  @override
  State<RequestedItemsListItem> createState() => _RequestedItemsListItemState();
}

class _RequestedItemsListItemState extends State<RequestedItemsListItem> with OverlayMixin {
  int _qtyRemaining = 10;
  Color? _pillColor = Colors.grey[350];
  Color? _pillDefaultColor = Colors.grey[350];
  String _selectedItemName = "chips";

  @override
  void initState() {
    super.initState();

  }

  void _showBringItemOverlay() {
    int newValue = 0;
    NumberStepper numberStepperField = NumberStepper(negativeAllowed: false,
      initialValue: 1,
      minValue: 1,
      maxValue: (_qtyRemaining),
      fetchValueCallback: (value){ newValue=value;},
    );

    showOverlay(
      backdropColor: Colors.amber.withAlpha(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("$_selectedItemName",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:18,
              )
          ),
          SizedBox(height:20),
          Text("I will bring..."),
          numberStepperField,
          ElevatedButton(
            onPressed: () {
              setState(() {
                _qtyRemaining-=newValue;
              });
              hideOverlay();
            },
            child: Text("Contribute"),
          ),
          SizedBox(height:10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle:  TextStyle(
                  color: Colors.grey
              ),
            ),
            onPressed: () {
              hideOverlay();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _bringItem() {
    //TODO: complete bringItem
  }

  void adjustRemaining(int remaining){
    setState(() {
      _qtyRemaining = remaining;
    });
  }

  @override
  Widget build(BuildContext context) {

    //Remove from list if empty
    if (_qtyRemaining<=0) return Container();

    return ListTile(
      onTap: _showBringItemOverlay,
      leading: Icon(Icons.person_2_outlined, size: 32.0),
      title: Text("Name of Item"),
      trailing: Ink(
        decoration: BoxDecoration(
          color: _pillColor,
          borderRadius: BorderRadius.circular(16),
        ),

          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$_qtyRemaining",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),

                ),
              ],
            ),
          ),
      ),
    );
  }
}
