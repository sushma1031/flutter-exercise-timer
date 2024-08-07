import 'package:flutter/material.dart';

class WorkoutForm extends StatefulWidget {
  final Future<void> Function(String) addWorkout;
  const WorkoutForm({Key? key, required this.addWorkout}) : super(key: key);
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
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a workout name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        filled: false,
                        labelText: 'Workout Name',
                        fillColor: Colors.white70),
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
                      await widget.addWorkout(_name);
                      _formKey.currentState?.reset();
                    },
                    child: const Text('Add'),
                  )
                ])));
  }
}
