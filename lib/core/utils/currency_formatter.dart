/// Utility for formatting monetary values consistently across the app.
abstract final class CurrencyFormatter {
  /// Formats [amount] as USD with 2 decimal places.
  /// e.g. 1234567.89 → "\$1,234,567.89"
  static String usd(double amount) {
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = _groupThousands(parts[0]);
    return '$sign\$$intPart.${parts[1]}';
  }

  /// Formats [percent] with sign and one decimal place.
  /// e.g. 12.3 → "+12.3%"   -5.6 → "-5.6%"
  static String percent(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(1)}%';
  }

  static String _groupThousands(String s) {
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      // Insert comma before every group of 3 digits counted from the right.
      // (s.length - i) is the number of digits remaining including current.
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
