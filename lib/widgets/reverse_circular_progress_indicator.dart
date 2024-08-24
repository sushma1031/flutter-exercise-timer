import 'package:flutter/material.dart';

class ReverseCircularProgressIndicator extends StatelessWidget {
  final AnimationController controller;
  const ReverseCircularProgressIndicator({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 250,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black,
          strokeWidth: 8,
          value: 1 - controller.value,
          semanticsLabel: 'Time left for current exercise',
        ));
  }
}
