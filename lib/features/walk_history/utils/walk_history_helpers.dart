String? stringValue(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value == null) {
    return null;
  }

  final text = value.toString().trim();

  return text.isEmpty ? null : text;
}

String firstNonEmpty(
  List<String?> values,
  String fallback,
) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }

  return fallback;
}

double? doubleValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

int? intValue(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

bool? boolValue(
  Map<String, dynamic> data,
  String key,
) {
  final value = data[key];

  if (value is bool) {
    return value;
  }

  if (value is String) {
    return value.toLowerCase() == 'true';
  }

  return null;
}

String formatElapsed(int seconds) {
  if (seconds < 0) {
    seconds = 0;
  }

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${secs.toString().padLeft(2, '0')}';
}
