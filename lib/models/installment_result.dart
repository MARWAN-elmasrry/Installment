import 'installment_type.dart';

/// Immutable result of one installment calculation. All values are raw
/// doubles; rounding happens only when displaying.
class InstallmentResult {
  const InstallmentResult({
    required this.type,
    required this.cashPrice,
    required this.adjustedPrice,
    required this.minimumDownPayment,
    required this.downPayment,
    required this.remainingBalance,
    required this.interest,
    required this.administrativeFees,
    required this.months,
    required this.monthlyInstallment,
    required this.totalAmount,
    required this.inquiryFee,
  });

  final InstallmentType type;
  final double cashPrice;

  /// Cash price after the system's automatic addition (equals cashPrice
  /// for system 3, which has no addition).
  final double adjustedPrice;
  final double minimumDownPayment;

  /// Agreed down payment (for system 2 this is the minimum down payment).
  final double downPayment;
  final double remainingBalance;
  final double interest;
  final double administrativeFees;
  final int months;
  final double monthlyInstallment;
  final double totalAmount;

  /// Inquiry fee shown separately. NEVER included in [totalAmount].
  final double inquiryFee;

  /// System 2 only: down payment + administrative fees (Excel cell C18).
  double get totalInitialPayment => downPayment + administrativeFees;

  /// True when the agreed down payment is lower than the minimum.
  bool get downPaymentBelowMinimum =>
      downPayment < minimumDownPayment - 0.000001;
}
