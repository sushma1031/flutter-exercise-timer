import 'package:flutter/material.dart';

class IconTextItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const IconTextItem({Key? key, required this.icon, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              icon,
              size: 20,
            )),
        Text(text),
      ],
    );
  }
}
