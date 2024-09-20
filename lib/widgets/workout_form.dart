import 'package:flutter/material.dart';

class WorkoutForm extends StatefulWidget {
  final Future<int> Function(String) addWorkout;
  final bool Function(String) isUnique;
  const WorkoutForm({
    Key? key,
    required this.addWorkout,
    required this.isUnique,
  }) : super(key: key);
  @override
  State<WorkoutForm> createState() => _WorkoutFormState();
}

class _WorkoutFormState extends State<WorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            // padding: EdgeInsets.all(15),
            height: 150,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: TextFormField(
                    enableSuggestions: true,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      if (!widget.isUnique(value)) {
                        return 'Name already in use';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'New Workout',
                    ),
                    onSaved: (value) {
                      _name = value!;
                    },
                  )),
                  ElevatedButton(
                    onPressed: () async {
                      var valid = _formKey.currentState!.validate();
                      if (!valid) {
                        return;
                      }
                      _formKey.currentState!.save();
                      int wIdx = await widget.addWorkout(_name);
                      _formKey.currentState?.reset();
                      Navigator.pop(context, wIdx);
                    },
                    child: const Text('Add'),
                  )
                ])));
  }
}
