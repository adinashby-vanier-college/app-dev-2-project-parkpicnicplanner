import 'package:flutter/material.dart';
import 'package:picnic/components/number_stepper.dart';
import 'package:picnic/mixins/overlay_mixin.dart';

import '../mixins/overlay_mixin.dart';
import 'arriving_items_detail_list.dart';
import 'number_stepper.dart';

class ArrivingItemsListItem extends StatefulWidget {
  const ArrivingItemsListItem({super.key});

  @override
  State<ArrivingItemsListItem> createState() => _ArrivingItemsListItemState();
}

class _ArrivingItemsListItemState extends State<ArrivingItemsListItem>
    with OverlayMixin {
  final ValueNotifier<int> _qtyArriving = ValueNotifier<int>(0);

  int _qtyNeeded = 10;
  bool _goalMet = false;

  Color? _defaultPillColor = Colors.blueGrey[500];
  Color? _pillColor = Colors.blueGrey[500];
  Color? _pillCompleteColor = Colors.green[400];
  double _defaultRightPillPadding = 16;
  double _rightPillPadding = 8;

  String _selectedItemName = "chips";

  @override
  void initState() {
    super.initState();

    //Add listener to observe changes
    _qtyArriving.addListener(() {
      toggleGoalMet();
    });

    toggleGoalMet();
  }

  void toggleGoalMet() {
    setState(() {
      _goalMet = (_qtyArriving.value >= _qtyNeeded);

      if (_goalMet) {
        _pillColor = _pillCompleteColor;
        _rightPillPadding = _defaultRightPillPadding;
      } else {
        _pillColor = _defaultPillColor;
        _rightPillPadding = 8;
      }
    });
  }

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ArrivingItemsDetailList(itemName: _selectedItemName);
      },
    );
  }

  void _showBringItemOverlay() {
    int newValue = 0;
    NumberStepper numberStepperField = NumberStepper(negativeAllowed: false,
        initialValue: 1,
        minValue: 1,
        maxValue: (_qtyNeeded-_qtyArriving.value),
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
                _qtyArriving.value+=newValue;
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _showDetails,
      leading: Icon(Icons.person_2_outlined, size: 32.0),
      title: Text("Name of Item"),
      trailing: Ink(
        decoration: BoxDecoration(
          color: _pillColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: GestureDetector(
          onTap: _showBringItemOverlay,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 8, _rightPillPadding, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_qtyArriving.value} / $_qtyNeeded",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                ...?!_goalMet
                    ? [
                      SizedBox(width: 4),
                      Icon(Icons.add, color: Colors.white, size: 14),
                    ]
                    : null,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
