import 'package:flutter_test/flutter_test.dart';
import 'package:installment_app/utils/formatters.dart';

void main() {
  test('formatMoney always shows two decimals with separators', () {
    expect(formatMoney(3060), '3,060.00');
    expect(formatMoney(2458.3333333333), '2,458.33');
    expect(formatMoney(1234567.891), '1,234,567.89');
    expect(formatMoney(0), '0.00');
    expect(formatMoney(999.999), '1,000.00');
  });

  test('parseAmount handles Arabic digits and separators', () {
    expect(parseAmount('٥٠٠٠٠'), 50000);
    expect(parseAmount('1,500.5'), 1500.5);
    expect(parseAmount('٢٥٫٥'), 25.5);
    expect(parseAmount(''), isNull);
    expect(parseAmount('abc'), isNull);
    expect(parseAmount(null), isNull);
  });

  test('parseWholeNumber rejects decimals', () {
    expect(parseWholeNumber('12'), 12);
    expect(parseWholeNumber('12.5'), isNull);
  });
}
