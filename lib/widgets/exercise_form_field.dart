import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseInput extends StatefulWidget {
  const ExerciseInput(
      {Key? key,
      required this.state,
      this.onChanged,
      this.nameController,
      this.durationController})
      : super(key: key);
  final state;
  final onChanged;
  final nameController, durationController;

  @override
  State<ExerciseInput> createState() => _ExerciseInputState();
}

class _ExerciseInputState extends State<ExerciseInput> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Name',
                ),
                enableSuggestions: true,
                controller: widget.nameController,
                textAlign: TextAlign.left,
                onChanged: widget.onChanged,
              )),
          Expanded(
              child: TextField(
            decoration: InputDecoration(
              hintText: 'Duration',
            ),
            controller: widget.durationController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            onChanged: widget.onChanged,
          ))
        ],
      ),
      if (widget.state.hasError) ...[
        Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              widget.state.errorText,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ))
      ]
    ]);
  }
}

class ExerciseFormField extends FormField<List<String>> {
  ExerciseFormField({
    Key? key,
    required List<String> initialValue,
    required FormFieldSetter<List<String>> onSaved,
    required FormFieldValidator<List<String>> validator,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          onSaved: onSaved,
          builder: (FormFieldState<List<String>> field) {
            _ExerciseFormFieldState state = field as _ExerciseFormFieldState;
            return ExerciseInput(
              state: state,
              nameController: state._nameController,
              durationController: state._durationController,
            );
          },
        );

  @override
  FormFieldState<List<String>> createState() => _ExerciseFormFieldState();
}

class _ExerciseFormFieldState extends FormFieldState<List<String>> {
  late final TextEditingController _nameController, _durationController;
  late List<String> _ex;
  @override
  void initState() {
    super.initState();
    _ex = widget.initialValue!;
    _nameController = TextEditingController(text: _ex[0]);
    _durationController = TextEditingController(text: _ex[1]);
    _nameController.addListener(_nameControllerChanged);
    _durationController.addListener(_durationControllerChanged);
  }

  @override
  void reset() {
    super.reset();
    _nameController.text = "";
    _durationController.text = "";
    _ex = [_nameController.text, _durationController.text];
  }

  void _nameControllerChanged() {
    _ex[0] = _nameController.text;
    didChange(_ex);
  }

  void _durationControllerChanged() {
    _ex[1] = _durationController.text;
    didChange(_ex);
  }

  @override
  void dispose() {
    _nameController.removeListener(_nameControllerChanged);
    _durationController.removeListener(_durationControllerChanged);
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
