import 'package:flutter/material.dart';

class DropdownIconButton extends StatefulWidget {
  DropdownIconButton({super.key, required this.icon, required this.buttonStyle, required this.child});

  final GlobalKey _buttonKey = GlobalKey();
  final Icon icon;
  final ButtonStyle buttonStyle;
  final Widget child;

  @override
  State<DropdownIconButton> createState() => _DropdownIconButtonState();
}

class _DropdownIconButtonState extends State<DropdownIconButton> {
  ButtonStyle? buttonStyle;
  Widget? childWidget;

  @override
  void initState() {
    super.initState();
    buttonStyle = widget.buttonStyle;
    childWidget = widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        key: widget._buttonKey,
        icon: widget.icon,
        style: buttonStyle,
        onPressed: () {
          final RenderBox renderBox = widget._buttonKey.currentContext?.findRenderObject() as RenderBox;
          final widgetPosition = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;

          showMenu(
            context: context,
            popUpAnimationStyle: AnimationStyle(
              curve: Curves.easeIn,
              duration: Duration(milliseconds:400),
            ),
            position: RelativeRect.fromLTRB(
              widgetPosition.dx,
              widgetPosition.dy,
              widgetPosition.dx + 200,
              widgetPosition.dy + size.height + 200,
            ),
            items: [
              PopupMenuItem(
                enabled: false,
                child: SizedBox(width: 100, height: 100),
              ),
            ],
          );
        },

    );
  }
}