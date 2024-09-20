import 'package:flutter/material.dart';
import 'package:count_up/widgets/scale_text_sequence.dart';

class CountdownScreen extends StatelessWidget {
  CountdownScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var duration = Duration(milliseconds: 2000);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      body: Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Awesome, let\'s go for another round!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Container(
                constraints: BoxConstraints(minHeight: 75),
                child: ScaleTextSequence(
                  ['Get', 'Set', 'Go!'],
                  textStyle: TextStyle(
                    fontSize: 40,
                    fontFamily: 'EthosNova',
                    fontWeight: FontWeight.bold,
                  ),
                  duration: duration,
                  onFinished: () => Navigator.pop(context, true),
                ),
              ),
            ]),
      ),
    );
  }
}
