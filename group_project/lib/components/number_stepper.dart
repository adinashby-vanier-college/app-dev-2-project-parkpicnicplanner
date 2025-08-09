import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberStepper extends StatefulWidget {
  const NumberStepper({
    super.key,
    this.initialValue = 0,
    this.negativeAllowed = true,
    this.maxValue,
    this.minValue,
    required this.fetchValueCallback
  });

  final int initialValue;
  final int? minValue;
  final int? maxValue;
  final bool negativeAllowed;
  final Function fetchValueCallback;

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late int value;
  late int? _lastValidValue;
  late Function fetchValueCallback;

  //Controllers
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    fetchValueCallback = widget.fetchValueCallback;

    fetchValueCallback(value);
    controller.text = value.toString();
    //TODO: throw an exception if initial value does not fall within valid range
  }

  void changeValueWithField(String newText) {
    String numberText = newText;
    int newValue = value;
    int parsedValue = int.parse(numberText);

    setState(() {
      if (numberText.isEmpty || parsedValue.isNaN ) {
          controller.text = widget.initialValue.toString();
          value = _lastValidValue ?? widget.initialValue;
      } else {
        newValue = parsedValue;
        if (isValid(newValue)) {
          value = newValue;
        } else {
          value = _lastValidValue ?? widget.initialValue;
          controller.text = value.toString();
        }
      }
    });

    //Value may have changed, invoke callback
    fetchValueCallback(value);
  }

  bool isValid(int newValue){
    //Return true, no binding constraints
    if (widget.negativeAllowed && (widget.minValue==null) && (widget.maxValue==null)) return true;

    //newValue is negative, which is not allowed
    if (!widget.negativeAllowed && (newValue < 0) ) return false;

    //Check if newValue is less than minValue
    if ( (widget.minValue!=null) && (newValue < widget.minValue!)) return false;

    //Check if newValue is greater than maxValue
    if ( (widget.maxValue!=null) && (newValue > widget.maxValue!)) return false;

    //it has passed all checks, it is in range
    _lastValidValue = newValue;
    return true;
  }

  void decrementValue() {
    int newValue = value-1;

    if (isValid(newValue)) {
      setState(() {
        value = newValue;
        controller.text = value.toString();
      });

      //Value changed, invoke callback
      fetchValueCallback(value);
    }
  }

  void incrementValue() {
    int newValue = value + 1;

    if (isValid(newValue)) {
      setState(() {
        value = newValue;
        controller.text = value.toString();
      });

      //Value changed, invoke callback
      fetchValueCallback(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filled(iconSize:16,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[600], // Dark background
                foregroundColor: Colors.white,     // White icon
              ),
              onPressed: decrementValue,
              icon: Icon(Icons.remove)),
          Container(
            width:60,
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: changeValueWithField,
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(
                fontSize:12,
              )
            ),
          ),
          IconButton.filled(iconSize:16,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[600], // Dark background
                foregroundColor: Colors.white,     // White icon
              ),
              onPressed: incrementValue,
              icon: Icon(Icons.add)),
        ],
      ),
    );
  }
}
