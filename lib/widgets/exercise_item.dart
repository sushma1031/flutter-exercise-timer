import 'package:flutter/material.dart';

class ExerciseItem extends StatelessWidget {
  final String name, duration;
  const ExerciseItem({Key? key, required this.name, required this.duration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(fontSize: 16);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text(name, style: style), Text('${duration}s', style: style)],
    );
  }
}
