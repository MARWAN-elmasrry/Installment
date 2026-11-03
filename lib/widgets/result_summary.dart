import 'package:flutter/material.dart';

import '../models/installment_result.dart';
import '../models/installment_type.dart';
import '../services/installment_calculator.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';

class _Row {
  const _Row(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;
}

/// Clean summary of one calculation. Highlights: minimum down payment,
/// agreed down payment, monthly installment, admin fees and total.
class ResultSummary extends StatelessWidget {
  const ResultSummary({super.key, required this.result});

  final InstallmentResult result;

  List<_Row> _rows() {
    final r = result;
    switch (r.type) {
      case InstallmentType.thirdWithInterest:
        return [
          _Row('سعر الكاش', formatCurrency(r.cashPrice)),
          _Row(
            'السعر بعد إضافة ${formatMoney(InstallmentCalculator.system1Addition)}',
            formatCurrency(r.adjustedPrice),
          ),
          _Row('أقل مقدم', formatCurrency(r.minimumDownPayment),
              highlight: true),
          _Row('المقدم المتفق عليه', formatCurrency(r.downPayment),
              highlight: true),
          _Row('المبلغ المتبقي', formatCurrency(r.remainingBalance)),
          _Row('الفوائد (${r.months * 3}%)', formatCurrency(r.interest)),
          _Row('عدد الأشهر', '${r.months}'),
          _Row('القسط الشهري', formatCurrency(r.monthlyInstallment),
              highlight: true),
          _Row('الإجمالي', formatCurrency(r.totalAmount), highlight: true),
        ];
      case InstallmentType.sixMonthsNoInterest:
        return [
          _Row('سعر الكاش', formatCurrency(r.cashPrice)),
          _Row(
            'السعر بعد إضافة ${formatMoney(InstallmentCalculator.system2Addition)}',
            formatCurrency(r.adjustedPrice),
          ),
          _Row('أقل مقدم', formatCurrency(r.minimumDownPayment),
              highlight: true),
          _Row('المصاريف الإدارية (8%) - تدفع مع المقدم',
              formatCurrency(r.administrativeFees),
              highlight: true),
          _Row('القسط الشهري', formatCurrency(r.monthlyInstallment),
              highlight: true),
          _Row('عدد الأقساط', '${r.months}'),
          _Row('الإجمالي', formatCurrency(r.totalAmount), highlight: true),
          _Row('إجمالي المدفوع مبدئيًا (مقدم + مصاريف إدارية)',
              formatCurrency(r.totalInitialPayment),
              highlight: true),
        ];
      case InstallmentType.seventyFivePercentDown:
        return [
          _Row('سعر الكاش', formatCurrency(r.cashPrice)),
          _Row('أقل مقدم (75%)', formatCurrency(r.minimumDownPayment),
              highlight: true),
          _Row('المقدم المتفق عليه', formatCurrency(r.downPayment),
              highlight: true),
          _Row('المبلغ المتبقي', formatCurrency(r.remainingBalance)),
          _Row('الفوائد (${r.months * 3}%)', formatCurrency(r.interest)),
          _Row('عدد الأشهر', '${r.months}'),
          _Row('القسط الشهري', formatCurrency(r.monthlyInstallment),
              highlight: true),
          _Row('الإجمالي', formatCurrency(r.totalAmount), highlight: true),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Headline: monthly installment + total.
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'القسط الشهري',
                style: TextStyle(color: AppColors.white, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(result.monthlyInstallment),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'الإجمالي: ${formatCurrency(result.totalAmount)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (result.type != InstallmentType.sixMonthsNoInterest &&
            result.downPaymentBelowMinimum) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تنبيه: المقدم المتفق عليه أقل من أقل مقدم (${formatMoney(result.minimumDownPayment)}).',
                    style: const TextStyle(
                        color: AppColors.warning, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                _ResultLine(row: rows[i]),
                if (i != rows.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Inquiry fee: shown separately, NOT included in the total.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'رسوم الاستعلام: ${formatCurrency(result.inquiryFee)} (تُدفع بشكل منفصل وغير مضافة إلى الإجمالي)',
            style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.row});

  final _Row row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              row.label,
              style: TextStyle(
                fontSize: 15,
                color: row.highlight ? AppColors.charcoal : AppColors.mutedText,
                fontWeight: row.highlight ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              row.value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: row.highlight ? AppColors.green : AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
