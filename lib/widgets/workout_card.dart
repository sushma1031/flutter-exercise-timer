import 'package:flutter/material.dart';
import 'package:count_up/models/workout_display.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutDisplay workout;
  final void Function() onTap;
  const WorkoutCard({Key? key, required this.workout, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).colorScheme.primary.withOpacity(0.08);
    Color darkSurface = Theme.of(context).colorScheme.surface;
    return Card(
      elevation: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(primary, darkSurface),
              Theme.of(context).colorScheme.primaryVariant.withOpacity(0.25)
            ],
            tileMode: TileMode.mirror,
          ),
        ),
        constraints: BoxConstraints(minHeight: 140),
        child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: onTap,
            child: Container(
                padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: TextStyle(fontSize: 25, fontFamily: "EthosNova"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Chip(
                              backgroundColor:
                                  Color.alphaBlend(primary, darkSurface),
                              label: Text(
                                "${workout.totalDuration} Min",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  borderRadius: BorderRadius.circular(5)),
                            )),
                        Chip(
                            elevation: 0,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            label: Text(
                              "${workout.noOfExercises} Sets",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                            ),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                borderRadius: BorderRadius.circular(5))),
                      ],
                    )
                  ],
                ))),
      ),
    );
  }
}
