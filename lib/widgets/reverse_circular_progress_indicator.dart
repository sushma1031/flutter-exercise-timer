import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class ReverseCircularProgressIndicator extends StatelessWidget {
  final AnimationController controller;
  const ReverseCircularProgressIndicator({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color secondary =
        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15);
    Color darkSurface = Theme.of(context).colorScheme.surface;
    return Container(
        width: 275,
        height: 275,
        child: CircularProgressIndicator(
          backgroundColor: Color.alphaBlend(secondary, darkSurface),
          color: Theme.of(context).colorScheme.secondary,
          strokeWidth: 8,
          value: 1 - controller.value,
          semanticsLabel: AppLocalizations.of(context).timeLeftSemanticLabel,
        ));
  }
}
