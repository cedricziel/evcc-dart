/// System-related models.
library;

/// Log level.
enum LogLevel {
  /// Fatal log level.
  fatal,

  /// Error log level.
  error,

  /// Warning log level.
  warn,

  /// Info log level.
  info,

  /// Debug log level.
  debug,

  /// Trace log level.
  trace,
}

/// Log area.
class LogArea {
  /// Area name.
  final String name;

  /// Creates a new log area.
  LogArea(this.name);

  /// Creates a log area from JSON.
  factory LogArea.fromJson(String json) {
    return LogArea(json);
  }

  @override
  String toString() => name;
}
