enum AppError {
  dbInitFailed,
  unknown,
}

final errorMessages = {
  AppError.dbInitFailed: "Could not load workout data.",
  AppError.unknown: "Oops! Something went wrong.",
};

enum ExportError { empty, fs, platform, unknown }

enum ImportError { format, type, unknown }
