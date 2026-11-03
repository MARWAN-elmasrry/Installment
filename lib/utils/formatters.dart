/// Display and parsing helpers (no Flutter dependency).

const String currencyLabel = 'ج.م';

/// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits to 0-9.
String normalizeDigits(String input) {
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    var i = arabicIndic.indexOf(ch);
    if (i < 0) i = persian.indexOf(ch);
    buffer.write(i >= 0 ? i.toString() : ch);
  }
  return buffer.toString();
}

/// Parses a user-typed number. Accepts Arabic digits, "٫" as the decimal
/// point and "," / "٬" as thousands separators. Returns null if invalid.
double? parseAmount(String? text) {
  if (text == null) return null;
  var s = normalizeDigits(text.trim());
  s = s
      .replaceAll('٫', '.')
      .replaceAll('٬', '')
      .replaceAll(',', '')
      .replaceAll(' ', '');
  if (s.isEmpty) return null;
  final value = double.tryParse(s);
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value;
}

/// Parses a whole number (months). Returns null if not an integer.
int? parseWholeNumber(String? text) {
  final value = parseAmount(text);
  if (value == null || value != value.roundToDouble()) return null;
  return value.toInt();
}

/// 1234567.891 -> "1,234,567.89" (always two decimals).
String formatMoney(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  var integerPart = parts[0];
  final negative = integerPart.startsWith('-');
  if (negative) integerPart = integerPart.substring(1);

  final buffer = StringBuffer();
  for (var i = 0; i < integerPart.length; i++) {
    if (i > 0 && (integerPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(integerPart[i]);
  }
  return '${negative ? '-' : ''}${buffer.toString()}.${parts[1]}';
}

String formatCurrency(double value) => '${formatMoney(value)} $currencyLabel';

String _two(int n) => n.toString().padLeft(2, '0');

String formatDateTime(DateTime d) {
  return '${d.year}/${_two(d.month)}/${_two(d.day)}  ${_two(d.hour)}:${_two(d.minute)}';
}
