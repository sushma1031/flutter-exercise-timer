import 'package:exercise_timer/models/exercise.dart';
import 'package:exercise_timer/models/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final List<String> workoutNames;
  final int index;
  final Future<Workout?> Function(int index, String name) updateWorkoutName;
  final Future<Workout?> Function(int index, List<Exercise> newExercises)
      updateWorkoutExercises;
  final void Function() returnToStaticList;
  final Future<bool> Function() onWillPop;

  const EditWorkoutScreen(
      {Key? key,
      required this.workout,
      required this.workoutNames,
      required this.index,
      required this.updateWorkoutName,
      required this.updateWorkoutExercises,
      required this.returnToStaticList,
      required this.onWillPop})
      : super(key: key);

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final List<Exercise> _ex;
  String _name = '';

  @override
  void initState() {
    super.initState();
    _name = widget.workout.name;
    _ex = <Exercise>[...widget.workout.exercises];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (widget.workout.name != _name ||
              !listEquals(widget.workout.exercises, _ex))
            return widget.onWillPop();
          else
            return Future.value(true);
        },
        child: Scaffold(
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              SizedBox(
                  height: 100,
                  //seperate this as a component that can be reused
                  child: Form(
                      key: _formKey,
                      child: Padding(
                          padding:
                              EdgeInsets.only(left: 25, right: 25, top: 10),
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            initialValue: widget.workout.name,
                            enableSuggestions: true,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a workout name';
                              }
                              if (value != widget.workout.name &&
                                  widget.workoutNames.contains(value)) {
                                return 'Name already in use';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                filled: false,
                                labelText: 'Workout Name',
                                fillColor: Colors.white70),
                            onChanged: (value) {
                              _name = value;
                            },
                            onSaved: (value) {
                              _name = value!;
                            },
                          )))),
              Expanded(
                  flex: 2,
                  child: ReorderableListView(
                      buildDefaultDragHandles: true,
                      children: <Widget>[
                        for (int index = 0; index < _ex.length; index++)
                          ListTile(
                            key: Key('$index'),
                            leading: IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _ex.removeAt(index);
                                });
                              },
                            ),
                            title: Text(
                                '${_ex[index].name}: ${_ex[index].duration}s'),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle,
                                color: Colors.white,
                              ),
                            ),
                          )
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final Exercise item = _ex.removeAt(oldIndex);
                          _ex.insert(newIndex, item);
                        });
                      })),
              ElevatedButton(
                  onPressed: () async {
                    var valid = _formKey.currentState!.validate();
                    if (!valid) {
                      return;
                    }
                    _formKey.currentState!.save();
                    if (widget.workout.name != _name) {
                      await widget.updateWorkoutName(widget.index, _name);
                    }
                    if (!listEquals(widget.workout.exercises, _ex))
                      await widget.updateWorkoutExercises(widget.index, _ex);
                    widget.returnToStaticList();
                  },
                  child: Text('Save'))
            ])));
  }
}
