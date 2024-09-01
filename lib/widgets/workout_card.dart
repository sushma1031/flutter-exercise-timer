import 'package:flutter/material.dart';
import 'package:exercise_timer/models/workout_display.dart';

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
          borderRadius: BorderRadius.circular(10),
          //   image: DecorationImage(
          //       fit: BoxFit.fill,
          //       image: AssetImage("assets/images/background_design_1.png")),
        ),
        constraints: BoxConstraints(minHeight: 150),
        child: InkWell(
            onTap: onTap,
            child: Container(
                padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color.alphaBlend(primary, darkSurface),
                      Theme.of(context)
                          .colorScheme
                          .primaryVariant
                          .withOpacity(0.25)
                    ],
                    tileMode: TileMode.mirror,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: TextStyle(
                        fontSize: 25,
                      ),
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
