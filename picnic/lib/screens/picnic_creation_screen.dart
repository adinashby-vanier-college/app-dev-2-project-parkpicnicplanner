import 'package:flutter/material.dart';

class PicnicCreationScreen extends StatefulWidget {
  const PicnicCreationScreen({super.key});

  @override
  State<PicnicCreationScreen> createState() => _PicnicCreationScreenState();
}

class _PicnicCreationScreenState extends State<PicnicCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Picnic')),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Placeholder(
                    color: Colors.blueGrey,
                    strokeWidth: 2.0,
                    fallbackHeight: 100.0,
                    fallbackWidth: 100.0,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade200,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          "Picnic Name",
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
            Flexible(
              flex: 7,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TabBarView(
                  children: [
                    Text("SCHEDULE PANE"),
                    _buildDescriptionPane(),
                    Text("LOCATION"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        Expanded(
          child: TextField(
            expands: true,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.top,
            maxLines: null, // Allows unlimited lines
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Enter picnic description...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
