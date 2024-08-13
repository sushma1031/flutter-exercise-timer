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
  String _name = '';
  int _duration = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Add Exercises'),
        // ),
        body: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                                width: 200,
                                // name
                                child: TextFormField(
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    filled: false,
                                    labelText: 'Name',
                                    labelStyle:
                                        TextStyle(color: Colors.white38),
                                  ),
                                  onSaved: (value) {
                                    _name = value!;
                                  },
                                )),
                            SizedBox(
                                width: 75,
                                // duration
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter duration';
                                    }
                                    var num = int.tryParse(value);
                                    if (num == null || num == 0) {
                                      return 'Please enter a numeric value greater than 0';
                                    }

                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    filled: false,
                                    labelText: 'Duration',
                                    labelStyle:
                                        TextStyle(color: Colors.white38),
                                  ),
                                  onSaved: (value) {
                                    _duration = int.parse(value!);
                                  },
                                )),
                          ]),
                      SizedBox(
                          width: 75,
                          child: ElevatedButton(
                            onPressed: () async {
                              var valid = _formKey.currentState!.validate();
                              if (!valid) {
                                return;
                              }
                              _formKey.currentState!.save();
                              Exercise ex = Exercise(_name, _duration);
                              await widget.addWorkoutExercises(
                                  widget.workoutIndex, [ex]);
                              widget.returnToStaticList();
                            },
                            child: const Text('Add'),
                          ))
                    ]))));
  }
}
