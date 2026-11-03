import '../models/installment_result.dart';
import '../models/installment_type.dart';

/// All financial formulas of the app. Pure Dart: no Flutter, no I/O.
///
/// Every formula below is a literal translation of the Excel file
/// "نظام التقسيط الجديد.xlsx". Nothing is rounded here; rounding is done only
/// when values are displayed.
class InstallmentCalculator {
  InstallmentCalculator._();

  /// Inquiry fee (EGP). Shown separately, never added to totals.
  static const double inquiryFee = 300;

  // System 1
  static const double system1Addition = 2000;
  static const double system1MonthlyRate = 0.03;

  // System 2
  static const double system2Addition = 1000;
  static const double system2AdminRate = 0.08;
  static const int system2Months = 6;

  // System 3
  static const double system3MinDownRate = 0.75;
  static const double system3MonthlyRate = 0.03;

  /// The price the agreed down payment may not exceed.
  static double adjustedPrice(InstallmentType type, double cashPrice) {
    switch (type) {
      case InstallmentType.thirdWithInterest:
        return cashPrice + system1Addition;
      case InstallmentType.sixMonthsNoInterest:
        return cashPrice + system2Addition;
      case InstallmentType.seventyFivePercentDown:
        return cashPrice;
    }
  }

  static InstallmentResult calculate({
    required InstallmentType type,
    required double cashPrice,
    double downPayment = 0,
    int months = 0,
  }) {
    switch (type) {
      case InstallmentType.thirdWithInterest:
        return thirdWithInterest(
          cashPrice: cashPrice,
          downPayment: downPayment,
          months: months,
        );
      case InstallmentType.sixMonthsNoInterest:
        return sixMonthsNoInterest(cashPrice: cashPrice);
      case InstallmentType.seventyFivePercentDown:
        return seventyFivePercentDown(
          cashPrice: cashPrice,
          downPayment: downPayment,
          months: months,
        );
    }
  }

  /// System 1 - Excel cells B4, E4, F4 (and E6/F6, E8/F8 for 18/24 months).
  static InstallmentResult thirdWithInterest({
    required double cashPrice,
    required double downPayment,
    required int months,
  }) {
    // Adjusted price = cash + 2000                      (A4+2000)
    final adjusted = cashPrice + system1Addition;
    // Minimum down payment = adjusted / 3               B4
    final minimumDown = adjusted / 3;
    // Remaining balance = adjusted - agreed down        (A4+2000)-C4
    final remaining = adjusted - downPayment;
    // Interest = remaining x (months x 0.03)
    final interest = remaining * (months * system1MonthlyRate);
    // Monthly installment = (remaining + interest) / months   E4
    final monthly = (remaining + interest) / months;
    // Total = monthly x months + agreed down            F4
    final total = (monthly * months) + downPayment;

    return InstallmentResult(
      type: InstallmentType.thirdWithInterest,
      cashPrice: cashPrice,
      adjustedPrice: adjusted,
      minimumDownPayment: minimumDown,
      downPayment: downPayment,
      remainingBalance: remaining,
      interest: interest,
      administrativeFees: 0,
      months: months,
      monthlyInstallment: monthly,
      totalAmount: total,
      inquiryFee: inquiryFee,
    );
  }

  /// System 2 - Excel cells B16, C16, D16, E16, C18.
  ///
  /// NOTE: the Excel formula is intentionally preserved even though it looks
  /// unusual: the monthly installment is (minimum down payment / 6), and the
  /// total is monthly x 6 + minimum down + admin fees.
  static InstallmentResult sixMonthsNoInterest({required double cashPrice}) {
    // Adjusted price = cash + 1000                      (A16+1000)
    final adjusted = cashPrice + system2Addition;
    // Minimum down payment = adjusted / 2               B16
    final minimumDown = adjusted / 2;
    // Administrative fees = adjusted x 8 / 100          C16
    final fees = (adjusted * 8) / 100;
    // Monthly installment = minimum down / 6            D16
    final monthly = minimumDown / system2Months;
    // Total = monthly x 6 + minimum down + fees         E16
    final total = (monthly * system2Months) + minimumDown + fees;

    return InstallmentResult(
      type: InstallmentType.sixMonthsNoInterest,
      cashPrice: cashPrice,
      adjustedPrice: adjusted,
      minimumDownPayment: minimumDown,
      downPayment: minimumDown,
      remainingBalance: minimumDown,
      interest: 0,
      administrativeFees: fees,
      months: system2Months,
      monthlyInstallment: monthly,
      totalAmount: total,
      inquiryFee: inquiryFee,
    );
  }

  /// System 3 - Excel cells B24, E24, F24.
  static InstallmentResult seventyFivePercentDown({
    required double cashPrice,
    required double downPayment,
    required int months,
  }) {
    // Minimum down payment = cash x 0.75                B24
    final minimumDown = cashPrice * system3MinDownRate;
    // Remaining balance = cash - agreed down            (A24-C24)
    final remaining = cashPrice - downPayment;
    // Interest = remaining x (months x 0.03)
    final interest = remaining * (months * system3MonthlyRate);
    // Monthly installment = (remaining + interest) / months   E24
    final monthly = (remaining + interest) / months;
    // Total = monthly x months + agreed down            F24
    final total = (monthly * months) + downPayment;

    return InstallmentResult(
      type: InstallmentType.seventyFivePercentDown,
      cashPrice: cashPrice,
      adjustedPrice: cashPrice,
      minimumDownPayment: minimumDown,
      downPayment: downPayment,
      remainingBalance: remaining,
      interest: interest,
      administrativeFees: 0,
      months: months,
      monthlyInstallment: monthly,
      totalAmount: total,
      inquiryFee: inquiryFee,
    );
  }
}
