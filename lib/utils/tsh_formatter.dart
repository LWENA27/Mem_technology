import 'package:intl/intl.dart';

/// Utility class for handling Tanzanian Shilling (TSH) currency formatting
class TSHFormatter {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'sw_TZ', // Swahili (Tanzania) locale
    symbol: 'TSH ',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormatter = NumberFormat('#,##0.00');

  /// Format a number as TSH currency with proper thousand separators
  /// Example: 2400000.00 -> "TSH 2,400,000.00"
  static String formatCurrency(double amount) {
    try {
      return _currencyFormatter.format(amount);
    } catch (e) {
      // Fallback formatting if locale is not available
      return 'TSH ${_numberFormatter.format(amount)}';
    }
  }

  /// Format a number as TSH currency without the symbol
  /// Example: 2400000.00 -> "2,400,000.00"
  static String formatAmount(double amount) {
    return _numberFormatter.format(amount);
  }

  /// Format a compact version for small displays
  /// Example: 2400000.00 -> "TSH 2.4M"
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'TSH ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TSH ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'TSH ${amount.toStringAsFixed(2)}';
    }
  }

  /// Parse TSH formatted string back to double
  /// Example: "TSH 2,400,000.00" -> 2400000.00
  static double? parseAmount(String input) {
    try {
      // Remove TSH symbol and whitespace
      String cleanInput =
          input.replaceAll('TSH', '').replaceAll(' ', '').replaceAll(',', '');

      return double.tryParse(cleanInput);
    } catch (e) {
      return null;
    }
  }

  /// Validate if a string represents a valid TSH amount
  static bool isValidAmount(String input) {
    final amount = parseAmount(input);
    return amount != null && amount >= 0;
  }

  /// Format for input fields with TSH prefix
  /// Example: 2400000.00 -> "TSH 2,400,000.00"
  static String formatForInput(double amount) {
    return formatCurrency(amount);
  }

  /// Get currency symbol
  static String get currencySymbol => 'TSH';

  /// Get currency code for Tanzania
  static String get currencyCode => 'TZS';

  /// Get currency name
  static String get currencyName => 'Tanzanian Shilling';
}
