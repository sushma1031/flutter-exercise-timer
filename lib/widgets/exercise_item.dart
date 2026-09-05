import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class ExerciseItem extends StatelessWidget {
  final String name;
  final int duration;
  const ExerciseItem({Key? key, required this.name, required this.duration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(fontSize: 16);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: Text(name, style: style, overflow: TextOverflow.ellipsis)),
        Text(AppLocalizations.of(context).exerciseDurationSec(duration),
            style: style)
      ],
    );
  }
}
