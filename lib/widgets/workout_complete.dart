import 'dart:math';
import 'package:count_up/screens/countdown_screen.dart';
import 'package:flutter/material.dart';

class WorkoutComplete extends StatelessWidget {
  final void Function() restartWorkout;
  final bgImage = const AssetImage("assets/images/background_design_1.png");
  final messages = <String>[
    "You did something today that your future self will be thankful for!",
    "Keep doing what you have to do so you can do what you want to do.",
    "Some days you wish it would happen, today you made it happen!",
    "Your body is grateful to you for believing in it.",
  ];

  Future<void> countdownAndRestart(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountdownScreen(),
        )).then((value) {
      if (value == true) restartWorkout();
    });
  }

  WorkoutComplete({Key? key, required this.restartWorkout});
  @override
  Widget build(BuildContext context) {
    var index = Random().nextInt(4);
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(fit: BoxFit.fitWidth, image: bgImage),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('WORKOUT COMPLETE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 52,
                      fontFamily: "EthosNova",
                    ))),
            Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 25),
                child: Text(
                  messages[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                )),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      await countdownAndRestart(context);
                    },
                    child: const Text('Repeat'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                          context, (Route<dynamic> route) => route.isFirst);
                    },
                    child: const Text('Home'),
                  ),
                ]),
          ],
        ));
  }
}
