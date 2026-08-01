import 'package:flutter/material.dart';

class VolumeSlider extends StatefulWidget {
  final double initial;
  final double min;
  final double max;
  final int divisions;
  final void Function(double) onChanged;

  const VolumeSlider(
      {Key? key,
      this.initial = 0.5,
      this.min = 0.0,
      this.max = 1.0,
      this.divisions = 10,
      required this.onChanged})
      : super(key: key);

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
        });
      },
      onChangeEnd: (double value) {
        widget.onChanged(value.roundToDouble().clamp(widget.min, 1.0));
      },
    );
  }
}
