import 'package:flutter_test/flutter_test.dart';
import 'package:installment_app/models/installment_type.dart';
import 'package:installment_app/services/installment_calculator.dart';

/// Expected values are the results stored in "نظام التقسيط الجديد.xlsx"
/// for its sample inputs (cash price 50000).
void main() {
  const tolerance = 1e-9;

  group('System 1 - third down payment, 36% interest', () {
    // Excel: A4=50000, C4=25000
    test('12 months matches Excel (B4, E4, F4)', () {
      final r = InstallmentCalculator.thirdWithInterest(
          cashPrice: 50000, downPayment: 25000, months: 12);
      expect(r.adjustedPrice, closeTo(52000, tolerance));
      expect(r.minimumDownPayment, closeTo(17333.3333333333, 1e-6));
      expect(r.remainingBalance, closeTo(27000, tolerance));
      expect(r.interest, closeTo(9720, tolerance));
      expect(r.monthlyInstallment, closeTo(3060, tolerance));
      expect(r.totalAmount, closeTo(61720, tolerance));
    });

    test('18 months matches Excel (E6, F6)', () {
      final r = InstallmentCalculator.thirdWithInterest(
          cashPrice: 50000, downPayment: 25000, months: 18);
      expect(r.monthlyInstallment, closeTo(2310, tolerance));
      expect(r.totalAmount, closeTo(66580, tolerance));
    });

    test('24 months matches Excel (E8, F8)', () {
      final r = InstallmentCalculator.thirdWithInterest(
          cashPrice: 50000, downPayment: 25000, months: 24);
      expect(r.monthlyInstallment, closeTo(1935, tolerance));
      expect(r.totalAmount, closeTo(71440, tolerance));
    });

    test('inquiry fee is separate and not in the total', () {
      final r = InstallmentCalculator.thirdWithInterest(
          cashPrice: 50000, downPayment: 25000, months: 12);
      expect(r.inquiryFee, 300);
      expect(r.totalAmount, closeTo(61720, tolerance));
    });

    test('flags a down payment below the minimum', () {
      final low = InstallmentCalculator.thirdWithInterest(
          cashPrice: 50000, downPayment: 10000, months: 12);
      final ok = InstallmentCalculator.thirdWithInterest(
          cashPrice: 50000, downPayment: 25000, months: 12);
      expect(low.downPaymentBelowMinimum, isTrue);
      expect(ok.downPaymentBelowMinimum, isFalse);
    });
  });

  group('System 2 - no interest, 6 months', () {
    // Excel: A16=50000
    test('matches Excel (B16, C16, D16, E16, C18)', () {
      final r = InstallmentCalculator.sixMonthsNoInterest(cashPrice: 50000);
      expect(r.adjustedPrice, closeTo(51000, tolerance));
      expect(r.minimumDownPayment, closeTo(25500, tolerance));
      expect(r.administrativeFees, closeTo(4080, tolerance));
      expect(r.monthlyInstallment, closeTo(4250, tolerance));
      expect(r.months, 6);
      expect(r.totalAmount, closeTo(55080, tolerance));
      expect(r.totalInitialPayment, closeTo(29580, tolerance));
    });
  });

  group('System 3 - 75% down payment', () {
    // Excel: A24=50000, C24=37500, D24=6
    test('matches Excel (B24, E24, F24)', () {
      final r = InstallmentCalculator.seventyFivePercentDown(
          cashPrice: 50000, downPayment: 37500, months: 6);
      expect(r.minimumDownPayment, closeTo(37500, tolerance));
      expect(r.remainingBalance, closeTo(12500, tolerance));
      expect(r.interest, closeTo(2250, tolerance));
      expect(r.monthlyInstallment, closeTo(2458.33333333333, 1e-6));
      expect(r.totalAmount, closeTo(52250, tolerance));
    });

    test('has no price addition', () {
      expect(
          InstallmentCalculator.adjustedPrice(
              InstallmentType.seventyFivePercentDown, 50000),
          50000);
    });
  });

  test('calculate() dispatches to the right system', () {
    final r = InstallmentCalculator.calculate(
        type: InstallmentType.sixMonthsNoInterest, cashPrice: 50000);
    expect(r.totalAmount, closeTo(55080, tolerance));
  });
}
