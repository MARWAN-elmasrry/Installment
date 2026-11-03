import 'installment_result.dart';
import 'installment_type.dart';

/// One saved calculation, stored in the local SQLite database.
class HistoryRecord {
  const HistoryRecord({
    this.id,
    required this.createdAt,
    required this.type,
    required this.cashPrice,
    required this.downPayment,
    required this.months,
    required this.monthlyInstallment,
    required this.totalAmount,
  });

  factory HistoryRecord.fromResult(InstallmentResult r) {
    return HistoryRecord(
      createdAt: DateTime.now(),
      type: r.type,
      cashPrice: r.cashPrice,
      downPayment: r.downPayment,
      months: r.months,
      monthlyInstallment: r.monthlyInstallment,
      totalAmount: r.totalAmount,
    );
  }

  factory HistoryRecord.fromMap(Map<String, Object?> map) {
    return HistoryRecord(
      id: map['id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      type: InstallmentType.fromKey(map['type'] as String),
      cashPrice: (map['cash_price'] as num).toDouble(),
      downPayment: (map['down_payment'] as num).toDouble(),
      months: (map['months'] as num).toInt(),
      monthlyInstallment: (map['monthly_installment'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
    );
  }

  final int? id;
  final DateTime createdAt;
  final InstallmentType type;
  final double cashPrice;
  final double downPayment;
  final int months;
  final double monthlyInstallment;
  final double totalAmount;

  Map<String, Object?> toMap() {
    return {
      'created_at': createdAt.toIso8601String(),
      'type': type.key,
      'cash_price': cashPrice,
      'down_payment': downPayment,
      'months': months,
      'monthly_installment': monthlyInstallment,
      'total_amount': totalAmount,
    };
  }
}
