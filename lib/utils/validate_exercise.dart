import 'package:flutter/widgets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

FormFieldValidator<List<String>> validateExercise(AppLocalizations l10n) {
  return (List<String>? value) {
    if (value == null || value[0].trim().isEmpty || value[1].isEmpty)
      return l10n.fieldsCannotBeEmpty;
    var num = int.tryParse(value[1]);
    if (num == null || num > 999 || num <= 0)
      return l10n.durationRangeError;

    return null;
  };
}
