import 'package:flutter/material.dart';

mixin OverlayMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? overlay;

  void showOverlay({Widget? content, Color? backdropColor}) {
    if (overlay != null) return;

    overlay = OverlayEntry(
      builder:
          (BuildContext context) => Material(
            color: backdropColor,
            elevation: 4,
            child: GestureDetector(
              onTap: hideOverlay,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black54,
                child: Center(

                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.fromLTRB(80,20,80,20),
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: content,
                      ),
                    ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context)?.insert(overlay!);
  }

  void hideOverlay() {
    overlay?.remove();
    overlay = null;
    onOverlayDismissed();
  }

  // Override to handle dismissal of overlay
  void onOverlayDismissed() {}

  @override
  void dispose() {
    overlay?.remove();
    super.dispose();
  }
}
