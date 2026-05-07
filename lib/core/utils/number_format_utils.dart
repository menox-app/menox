import 'package:intl/intl.dart';

class NumberFormatUtils {
  const NumberFormatUtils._();

  static String compactCount(
    num? value, {
    String? locale,
    bool hideZero = true,
  }) {
    if (value == null) return '';
    if (hideZero && value == 0) return '';

    final formatter = NumberFormat.compact(locale: locale);
    return formatter.format(value);
  }
}
