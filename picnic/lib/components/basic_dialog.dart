import 'package:flutter/material.dart';

class BasicDialog extends StatefulWidget {
  const BasicDialog({
    super.key,
    required this.content,
    this.actionLabel = "Okay",
    this.actionCallback,
    this.cancelCallback,
  });

  final Widget content;
  final String actionLabel;
  final Function? actionCallback;
  final Function? cancelCallback;

  @override
  State<BasicDialog> createState() => _BasicDialogState();
}

class _BasicDialogState extends State<BasicDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Form(child: widget.content),
            SizedBox(height: 10),
            OverflowBar(
              spacing: 10,
              alignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.cancelCallback?.call();
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.actionCallback?.call();
                    Navigator.pop(context);
                  },
                  child: Text(widget.actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
