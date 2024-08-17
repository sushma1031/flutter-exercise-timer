import 'package:exercise_timer/widgets/exercise_input_field.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExercisesForm extends StatefulWidget {
  final Future<void> Function(int, List<Exercise>) addWorkoutExercises;
  final void Function() returnToStaticList;
  final int workoutIndex;
  const ExercisesForm(
      {Key? key,
      required this.addWorkoutExercises,
      required this.returnToStaticList,
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
    return Scaffold(
        body: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        key: UniqueKey(),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Add Exercises'),
                          IconButton(
                              onPressed: widget.returnToStaticList,
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ))
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: _rows,
                            itemBuilder: (context, index) {
                              return Row(
                                  key: UniqueKey(),
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: (_rows == 1)
                                            ? null
                                            : () {
                                                setState(() {
                                                  if (index < _allData.length)
                                                    _allData.removeAt(index);
                                                  _rows--;
                                                });
                                              },
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        )),
                                    Expanded(
                                        child: ExerciseFormField(
                                      initialValue: (index < _allData.length)
                                          ? _allData[index]
                                          : ["", ""],
                                      onSaved: (newValue) {
                                        updateAllData(newValue!, index);
                                      },
                                      validator: (value) {
                                        if (value == null ||
                                            value[0].isEmpty ||
                                            value[1].isEmpty)
                                          return 'Fields cannot be empty';
                                        var num = int.tryParse(value[1]);
                                        if (num == null || num > 99 || num <= 0)
                                          return 'Duration must be in range (0, 100)';

                                        return null;
                                      },
                                    )),
                                    Container(
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
                                                  _formKey.currentState!.save();

                                                  setState(() {
                                                    _rows++;
                                                  });
                                                },
                                                icon: Icon(Icons.add_box,
                                                    color: Colors.white),
                                                tooltip: 'Add another exercise',
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
                                  .map((e) => Exercise(e[0], int.parse(e[1])))
                                  .toList();

                              await widget.addWorkoutExercises(
                                  widget.workoutIndex, ex);
                              widget.returnToStaticList();
                            },
                            child: const Text('Save'),
                          ))
                    ]))));
  }
}
