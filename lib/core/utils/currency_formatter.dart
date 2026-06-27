import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Extensible currency representation model.
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  /// Default currency initialized to Indian Rupee (₹)
  static const Currency defaultCurrency = Currency(
    code: AppConstants.defaultCurrencyCode,
    symbol: AppConstants.defaultCurrencySymbol,
    name: AppConstants.defaultCurrencyName,
  );
}

/// Helper utility for formatting prices with extensible currency support.
class CurrencyFormatter {
  static String format(double amount, {Currency currency = Currency.defaultCurrency}) {
    final NumberFormat formatter = NumberFormat.currency(
      name: currency.code,
      symbol: currency.symbol,
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }
}
