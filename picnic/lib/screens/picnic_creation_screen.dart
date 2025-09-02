import 'package:flutter/material.dart';
import 'package:picnic/components/date_time_selector.dart';
import 'package:picnic/services/picnic_service.dart';

import '../components/basic_map.dart';
import '../models/picnic.dart';
import '../services/service_locator.dart';

class PicnicCreationScreen extends StatefulWidget {
  const PicnicCreationScreen({super.key});

  @override
  State<PicnicCreationScreen> createState() => _PicnicCreationScreenState();
}

class _PicnicCreationScreenState extends State<PicnicCreationScreen> {
  ValueNotifier<bool> _isFixedSchedule = ValueNotifier<bool>(true);
  final GlobalKey _dateTimeSelectorKey = GlobalKey();
  final TextEditingController _picnicNameTextController =
      TextEditingController();
  final TextEditingController _picnicDescriptionTextController =
      TextEditingController();

  final picnicService = getIt<PicnicService>();

  String _scheduleType = "fixed";
  DateTime? scheduledDateTime;

  void _handleDateSelectorChange(DateTime newDateTime) {
    setState(() {
      scheduledDateTime = newDateTime;
    });
  }

  @override
  void initState() {
    _isFixedSchedule.addListener(() {
      setState(() {
        if (_isFixedSchedule.value) {
          _scheduleType = "fixed";
        } else {
          _scheduleType = "poll";
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Picnic')),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  // Placeholder(
                  //   color: Colors.blueGrey,
                  //   strokeWidth: 2.0,
                  //   fallbackHeight: 100.0,
                  //   fallbackWidth: 100.0,
                  // ),
                  DecoratedBox(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    child: Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: TextField(
                          controller: _picnicNameTextController,
                          decoration: const InputDecoration(
                            labelText: 'Picnic Name',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PreferredSize(
                    preferredSize: Size.fromHeight(30),
                    child: TabBar(
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      indicatorPadding: EdgeInsets.symmetric(horizontal: 4),
                      tabs: [
                        Tab(text: "Schedule", icon: Icon(Icons.calendar_month)),
                        Tab(text: "Description", icon: Icon(Icons.edit)),
                        Tab(text: "Location", icon: Icon(Icons.location_pin)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TabBarView(
                  children: [
                    _buildSchedulePane(),
                    _buildDescriptionPane(),
                    _buildLocationPane(),
                  ],
                ),
              ),
            ),
          ],
        ),
        persistentFooterButtons: [
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _createPicnic,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  void _createPicnic() {
    //TODO: apply validation rules to determine if picnic information is present
    String? picnicName = _picnicNameTextController.text;

    Map<String, String> errors = <String, String>{};

    if (picnicName.isEmpty) errors['picnic'] = "Picnic name required";

    if (errors.isNotEmpty) {
      String errorStringList = errors.entries
          .map((entry) => " - ${entry.value}")
          .join("\n");

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
          content: Text('Errors found:\n $errorStringList'),
        ),
      );

      //Exit early to allow corrections
      return;
    }

    Picnic newPicnic = Picnic(
      name: picnicName,
      description: _picnicDescriptionTextController.text,
      scheduledAt: scheduledDateTime,
    );
    picnicService.createPicnic(newPicnic);

    if (Navigator.canPop(context)) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Picnic Created Successfully!'),
      ),
    );
  }

  Widget _buildSchedulePane() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: ListView(children: [_buildFixedSchedule()])),
      ],
    );
  }

  Widget _buildFixedSchedule() {
    return Column(
      children: [
        Text(
          'Select Date and Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        DateTimeSelector(
          showDayOfWeek: true,
          key: _dateTimeSelectorKey,
          onDateTimeChanged: _handleDateSelectorChange,
        ),
      ],
    );
  }

  Widget _buildSchedulePoll() {
    return Text("Poll");
  }

  Widget _buildLocationPane() {
    return BasicMap();
  }

  Widget _buildDescriptionPane() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
        Expanded(
          child: TextField(
            controller: _picnicDescriptionTextController,
            expands: true,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.top,
            maxLines: null,
            // Allows unlimited lines
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Enter picnic description...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
