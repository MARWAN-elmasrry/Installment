import 'package:flutter_test/flutter_test.dart';
import 'package:installment_app/models/installment_type.dart';
import 'package:installment_app/services/installment_validator.dart';

void main() {
  group('cash price', () {
    test('rejects empty, zero, negative and non-numeric', () {
      expect(InstallmentValidator.cashPrice(''), isNotNull);
      expect(InstallmentValidator.cashPrice(null), isNotNull);
      expect(InstallmentValidator.cashPrice('0'), isNotNull);
      expect(InstallmentValidator.cashPrice('-5'), isNotNull);
      expect(InstallmentValidator.cashPrice('abc'), isNotNull);
    });
    test('accepts positive values, including Arabic digits', () {
      expect(InstallmentValidator.cashPrice('50000'), isNull);
      expect(InstallmentValidator.cashPrice('٥٠٠٠٠'), isNull);
      expect(InstallmentValidator.cashPrice('1,500.50'), isNull);
    });
  });

  group('down payment', () {
    const t1 = InstallmentType.thirdWithInterest;
    const t3 = InstallmentType.seventyFivePercentDown;

    test('rejects empty and negative', () {
      expect(
          InstallmentValidator.downPayment('', type: t1, cashText: '50000'),
          isNotNull);
      expect(
          InstallmentValidator.downPayment('-1', type: t1, cashText: '50000'),
          isNotNull);
    });
    test('system 1 limit is cash + 2000', () {
      expect(
          InstallmentValidator.downPayment('52000',
              type: t1, cashText: '50000'),
          isNull);
      expect(
          InstallmentValidator.downPayment('52001',
              type: t1, cashText: '50000'),
          isNotNull);
    });
    test('system 3 limit is the cash price', () {
      expect(
          InstallmentValidator.downPayment('50000',
              type: t3, cashText: '50000'),
          isNull);
      expect(
          InstallmentValidator.downPayment('50001',
              type: t3, cashText: '50000'),
          isNotNull);
    });
  });

  group('months', () {
    test('system 1 accepts only 12, 18, 24', () {
      const t = InstallmentType.thirdWithInterest;
      expect(InstallmentValidator.months('12', type: t), isNull);
      expect(InstallmentValidator.months('18', type: t), isNull);
      expect(InstallmentValidator.months('24', type: t), isNull);
      expect(InstallmentValidator.months('10', type: t), isNotNull);
    });
    test('system 3 accepts whole numbers 1..60', () {
      const t = InstallmentType.seventyFivePercentDown;
      expect(InstallmentValidator.months('6', type: t), isNull);
      expect(InstallmentValidator.months('0', type: t), isNotNull);
      expect(InstallmentValidator.months('61', type: t), isNotNull);
      expect(InstallmentValidator.months('2.5', type: t), isNotNull);
      expect(InstallmentValidator.months('', type: t), isNotNull);
    });
  });
}
