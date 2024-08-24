String? validateExercise(List<String>? value) {
  if (value == null || value[0].trim().isEmpty || value[1].isEmpty)
    return 'Fields cannot be empty';
  var re = RegExp(r'^[\w\s\.\/-]+$');
  if (!re.hasMatch(value[0])) return 'Use only alphanumeric, spaces, ./-';
  var num = int.tryParse(value[1]);
  if (num == null || num > 99 || num <= 0)
    return 'Duration must be in range [1, 99]';

  return null;
}
