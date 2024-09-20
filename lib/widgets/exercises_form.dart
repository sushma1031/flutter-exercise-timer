import 'package:count_up/utils/validate_exercise.dart';
import 'package:count_up/widgets/exercise_form_field.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExercisesForm extends StatefulWidget {
  final Future<void> Function(int, List<Exercise>) addWorkoutExercises;
  final void Function() returnToStaticList;
  final int workoutIndex;
  final Future<bool> Function() onWillPop;
  const ExercisesForm(
      {Key? key,
      required this.addWorkoutExercises,
      required this.returnToStaticList,
      required this.onWillPop,
      required this.workoutIndex})
      : super(key: key);
  @override
  State<ExercisesForm> createState() => _ExercisesFormState();
}

class _ExercisesFormState extends State<ExercisesForm> {
  final _formKey = GlobalKey<FormState>();
  int _rows = 1;
  List<List<String>> _allData = [];

  void updateAllData(List<String> data, int index) {
    if (index < _allData.length) {
      _allData[index] = data;
    } else {
      _allData.add(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (_rows >= 1)
            return widget.onWillPop();
          else
            return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Form(
                key: _formKey,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListView.builder(
                                itemCount: _rows,
                                itemBuilder: (context, index) {
                                  return Row(
                                      key: UniqueKey(),
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: (_rows == 1)
                                                ? null
                                                : () {
                                                    setState(() {
                                                      if (index <
                                                          _allData.length)
                                                        _allData
                                                            .removeAt(index);
                                                      _rows--;
                                                    });
                                                  },
                                            icon: Icon(
                                              Icons.remove_circle,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground
                                                  .withOpacity(0.8),
                                            )),
                                        Expanded(
                                            child: ExerciseFormField(
                                          initialValue:
                                              (index < _allData.length)
                                                  ? _allData[index]
                                                  : ["", ""],
                                          onSaved: (newValue) {
                                            updateAllData(newValue!, index);
                                          },
                                          validator: validateExercise,
                                        )),
                                        SizedBox(
                                            width: 45,
                                            child: (index < _rows - 1)
                                                ? null
                                                : IconButton(
                                                    onPressed: () {
                                                      var valid = _formKey
                                                          .currentState!
                                                          .validate();
                                                      if (!valid) {
                                                        return;
                                                      }
                                                      _formKey.currentState!
                                                          .save();

                                                      setState(() {
                                                        _rows++;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.add_box,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      size: 20,
                                                    ),
                                                    tooltip:
                                                        'Add another exercise',
                                                  ))
                                      ]);
                                }),
                          ),
                          SizedBox(
                              width: 75,
                              child: ElevatedButton(
                                onPressed: () async {
                                  var valid = _formKey.currentState!.validate();
                                  if (!valid) {
                                    return;
                                  }
                                  _formKey.currentState!.save();
                                  List<Exercise> ex = _allData
                                      .map((e) =>
                                          Exercise(e[0], int.parse(e[1])))
                                      .toList();

                                  await widget.addWorkoutExercises(
                                      widget.workoutIndex, ex);
                                  widget.returnToStaticList();
                                },
                                child: const Text('Save'),
                              ))
                        ])))));
  }
}
