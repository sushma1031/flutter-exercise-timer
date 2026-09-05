import 'package:flutter/material.dart';
import 'package:count_up/services/timer_audio_service.dart';
import 'package:count_up/widgets/volume_slider.dart';
import 'package:count_up/utils/assets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class VolumeSettings extends StatefulWidget {
  final double initial;
  final double min;
  final void Function(double) onChanged;

  const VolumeSettings({
    Key? key,
    required this.initial,
    required this.onChanged,
    this.min = 0.2,
  }) : super(key: key);

  @override
  State<VolumeSettings> createState() => _VolumeSettingsState();
}

class _VolumeSettingsState extends State<VolumeSettings> {
  late double _volume;
  final _previewPlayer = TimerAudioService(Assets.audioExerciseChange);
  bool _configured = false;
  bool _isPreviewing = false;

  @override
  void initState() {
    super.initState();
    _volume = widget.initial.clamp(widget.min, 1.0);
  }

  Future<void> _previewVolume() async {
    if (mounted) setState(() => _isPreviewing = true);
    setState(() {
      _isPreviewing = true;
    });

    try {
      if (!_configured) {
        await _previewPlayer.configure();
        _configured = true;
      }

      if (!mounted) return;

      // Stop any preview already in progress so repeated taps prevent playback overlap.
      await _previewPlayer.stop();
      await _previewPlayer.setVolume(_volume);
      await _previewPlayer.play();
    } catch (e) {
      debugPrint('Volume preview audio error: $e');
    } finally {
      if (mounted) {
        setState(() => _isPreviewing = false);
      }
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Timer', style: TextStyle(fontSize: 16)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: VolumeSlider(
                initial: _volume,
                min: widget.min,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                  widget.onChanged(value);
                },
              ),
            ),
            IconButton(
              onPressed: _isPreviewing ? null : _previewVolume,
              icon: Icon(Icons.volume_up),
              iconSize: 20,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }
}
