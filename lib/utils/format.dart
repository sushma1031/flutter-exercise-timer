// Utility functions to format and generate strings

import 'package:intl/intl.dart';

String formatDuration(Duration d) {
  if (d.inMinutes == 0) return d.inSeconds.toString();
  int seconds = d.inSeconds - (d.inMinutes * Duration.secondsPerMinute);
  return '${d.inMinutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
}

String generateBackupFilename(String name) {
  final illegalChars = RegExp(r'[\\/:*?"<>|]');
  final sanitisedSlug = name.toLowerCase()
                            .replaceAll(illegalChars, '')
                            .replaceAll(RegExp(r'\s+'), '-');
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return '$sanitisedSlug-$date.json';
}

String getUniqueWorkoutName(List<String> existingNames, String baseName) {
  if (!existingNames.contains(baseName)) return baseName;

  int suffix = 1;
  String newName;
  do {
    newName = '$baseName ($suffix)';
    suffix++;
  } while (existingNames.contains(newName));

  return newName;
}
