import 'package:flutter/widgets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

enum AppError {
  dbInitFailed,
  unknown,
}

String errorMessageFor(BuildContext context, AppError error) {
  final l10n = AppLocalizations.of(context);
  switch (error) {
    case AppError.dbInitFailed:
      return l10n.dbInitFailedError;
    case AppError.unknown:
      return l10n.unknownError;
  }
}

enum ExportError { empty, fs, platform, unknown }

enum ImportError { format, type, unknown }
