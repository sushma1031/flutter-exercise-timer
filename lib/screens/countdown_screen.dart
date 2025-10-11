import 'package:flutter/material.dart';
import 'package:count_up/widgets/scale_text_sequence.dart';
import 'package:count_up/services/audio_service.dart';

class CountdownScreen extends StatelessWidget {
  final String? message;
  final double fontSize;
  final List<String> textSequence;
  final AudioService player;
  const CountdownScreen({
    Key? key, 
    required this.textSequence, 
    required this.player, 
    this.message, 
    this.fontSize = 36
  }) : super(key: key);

  Future<void> initAudioPlayer() async {
    await player.configure();
  }

  @override
  Widget build(BuildContext context) {
    initAudioPlayer();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: <Widget>[
            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            Container(
              constraints: BoxConstraints(minHeight: 75),
              child: ScaleTextSequence(
                textSequence,
                textStyle: TextStyle(
                  fontSize: fontSize,
                  fontFamily: 'EthosNova',
                  fontWeight: FontWeight.bold,
                ),
                duration: Duration(milliseconds: 1500),
                onFinished: () {
                  player.play().then((_) => Navigator.pop(context, true));
                },
              ),
            ),
        ]),
      ),
    );
  }
}
