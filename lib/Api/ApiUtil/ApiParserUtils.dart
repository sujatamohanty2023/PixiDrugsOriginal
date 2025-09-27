class ApiParserUtils {
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == 'yes' || lower == '1') return true;
      if (lower == 'false' || lower == 'no' || lower == '0') return false;
    }
    return defaultValue;
  }

  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static List<T> parseList<T>(dynamic value, T Function(dynamic item) fromJson) {
    if (value == null || value is! List) return [];
    return parseListSafe(value, fromJson);
  }

  static Map<String, dynamic> parseMap(dynamic value) {
    if (value == null || value is! Map) return {};
    return Map<String, dynamic>.from(value);
  }

  /// Parse decimal values that might come as int, double, or string from API
  static double parseDecimal(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Handle empty strings
      if (value.trim().isEmpty) return defaultValue;
      // Remove any commas that might be used as thousand separators
      final cleanValue = value.replaceAll(',', '');
      return double.tryParse(cleanValue) ?? defaultValue;
    }
    // Handle unexpected types gracefully
    return double.tryParse(value.toString()) ?? defaultValue;
  }

  /// Parse integer values with enhanced error handling
  static int parseIntEnhanced(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) {
      // Check if it's a whole number
      if (value % 1 == 0) return value.toInt();
      // Round down for decimals
      return value.floor();
    }
    if (value is String) {
      if (value.trim().isEmpty) return defaultValue;
      // Try parsing as double first in case it has decimal places
      final doubleValue = double.tryParse(value.trim());
      if (doubleValue != null) return doubleValue.floor();
    }
    // Last resort: try parsing as string
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  /// Safe list parsing with type checking for each element
  static List<T> parseListSafe<T>(dynamic value, T Function(dynamic item) fromJson, {List<T> defaultValue = const []}) {
    if (value == null || value is! List) return defaultValue;
    
    List<T> result = [];
    for (var item in value) {
      try {
        result.add(fromJson(item));
      } catch (e) {
        // Log the error but continue parsing other items
        print('Error parsing list item: $e');
        // Optionally add a default item or skip
        continue;
      }
    }
    return result;
  }

  /// Parse price/amount strings that might have currency symbols or formatting
  static double parsePrice(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    
    String stringValue = value.toString().trim();
    if (stringValue.isEmpty) return defaultValue;
    
    // Remove common currency symbols and formatting
    stringValue = stringValue
        .replaceAll(RegExp(r'[₹$€£,]'), '') // Remove currency symbols and commas
        .replaceAll(RegExp(r'\s+'), '') // Remove whitespace
        .trim();
    
    return double.tryParse(stringValue) ?? defaultValue;
  }

  /// Parse percentage values that might come with % symbol
  static double parsePercentage(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    
    String stringValue = value.toString().trim();
    if (stringValue.isEmpty) return defaultValue;
    
    // Remove % symbol if present
    stringValue = stringValue.replaceAll('%', '').trim();
    
    return double.tryParse(stringValue) ?? defaultValue;
  }
}
