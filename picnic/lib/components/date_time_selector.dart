import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatefulWidget {
  const DateTimeSelector({required super.key, required this.onDateTimeChanged});

  final Function onDateTimeChanged;

  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateFormat dateFormat = DateFormat('MM/dd/yyyy');

  DateTime getSelectedDate(){
    return selectedDate;
  }

  TimeOfDay getSelectedTime(){
    return selectedTime;
  }

  //Combined DateTime
  DateTime? get combinedDateTime {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime presentDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(presentDate.year+2),
      helpText: 'Select a date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateTimeChanged.call(combinedDateTime);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      helpText: 'Select a time',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
      widget.onDateTimeChanged.call(combinedDateTime);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.onDateTimeChanged.call(combinedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Selected Date'),
            subtitle: Text(
              dateFormat.format(selectedDate),
            ),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => _selectDate(context),
          ),
        ),
        SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: Icon(Icons.access_time),
            title: Text('Selected Time'),
            subtitle: Text('${selectedTime.format(context)}'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => _selectTime(context),
          ),
        ),
      ],
    );
  }
}
