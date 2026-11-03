import 'package:flutter/material.dart';

import '../models/history_record.dart';
import '../models/installment_result.dart';
import '../models/installment_type.dart';
import '../services/history_database.dart';
import '../services/installment_calculator.dart';
import '../services/installment_validator.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/amount_field.dart';
import '../widgets/app_card.dart';
import '../widgets/result_summary.dart';
import '../widgets/system_selector.dart';

/// Calculator tab: choose a system, enter values, see the results.
class CalculatorTab extends StatefulWidget {
  const CalculatorTab({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.onSaved,
  });

  final InstallmentType type;
  final ValueChanged<InstallmentType> onTypeChanged;
  final VoidCallback onSaved;

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  final _formKey = GlobalKey<FormState>();
  final _resultKey = GlobalKey();
  final _scrollController = ScrollController();
  final _cashController = TextEditingController();
  final _downController = TextEditingController();
  final _monthsController = TextEditingController(text: '6');

  int _chosenMonths = 12;
  InstallmentResult? _result;
  bool _saved = false;

  @override
  void didUpdateWidget(CalculatorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      // Reset after this frame so we never modify widgets while building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(_resetForm);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cashController.dispose();
    _downController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _cashController.clear();
    _downController.clear();
    _monthsController.text = '${widget.type.defaultMonths}';
    _chosenMonths = widget.type.defaultMonths;
    _result = null;
    _saved = false;
    _formKey.currentState?.reset();
  }

  /// Any edit invalidates the displayed result so a stale one is never saved.
  void _onInputChanged(String _) {
    if (_result != null) {
      setState(() {
        _result = null;
        _saved = false;
      });
    }
  }

  int _selectedMonths() {
    final type = widget.type;
    if (!type.usesMonths) return InstallmentCalculator.system2Months;
    if (type.monthChoices.isNotEmpty) return _chosenMonths;
    return parseWholeNumber(_monthsController.text) ?? type.defaultMonths;
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _result = null;
        _saved = false;
      });
      return;
    }
    final type = widget.type;
    final cash = parseAmount(_cashController.text)!;
    final down =
        type.usesAgreedDownPayment ? parseAmount(_downController.text)! : 0.0;

    setState(() {
      _result = InstallmentCalculator.calculate(
        type: type,
        cashPrice: cash,
        downPayment: down,
        months: _selectedMonths(),
      );
      _saved = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 250));
      }
    });
  }

  void _clear() {
    FocusScope.of(context).unfocus();
    setState(_resetForm);
  }

  void _newCalculation() {
    setState(_resetForm);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _save() async {
    final result = _result;
    if (result == null || _saved) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await HistoryDatabase.instance
          .insert(HistoryRecord.fromResult(result));
      if (!mounted) return;
      setState(() => _saved = true);
      widget.onSaved();
      messenger.showSnackBar(
          const SnackBar(content: Text('تم حفظ العملية في السجل')));
    } catch (_) {
      messenger.showSnackBar(
          const SnackBar(content: Text('تعذر حفظ العملية، حاول مرة أخرى')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final result = _result;

    return SingleChildScrollView(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'نظام التقسيط',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal),
          ),
          const SizedBox(height: 8),
          SystemSelector(
            selected: type,
            onSelected: widget.onTypeChanged,
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AmountField(
                    controller: _cashController,
                    label: 'سعر الكاش',
                    suffix: currencyLabel,
                    validator: InstallmentValidator.cashPrice,
                    onChanged: _onInputChanged,
                  ),
                  if (type.usesAgreedDownPayment) ...[
                    const SizedBox(height: 14),
                    AmountField(
                      controller: _downController,
                      label: 'المقدم المتفق عليه',
                      suffix: currencyLabel,
                      textInputAction: type.usesMonths &&
                              type.monthChoices.isEmpty
                          ? TextInputAction.next
                          : TextInputAction.done,
                      validator: (v) => InstallmentValidator.downPayment(
                        v,
                        type: type,
                        cashText: _cashController.text,
                      ),
                      onChanged: _onInputChanged,
                    ),
                  ],
                  if (type.monthChoices.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('عدد الأشهر',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.mutedText)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        for (final m in type.monthChoices)
                          ChoiceChip(
                            label: Text('$m شهرًا',
                                style: const TextStyle(fontSize: 16)),
                            selected: _chosenMonths == m,
                            selectedColor: AppColors.greenLight,
                            onSelected: (_) {
                              setState(() {
                                _chosenMonths = m;
                                _result = null;
                                _saved = false;
                              });
                            },
                          ),
                      ],
                    ),
                  ] else if (type.usesMonths) ...[
                    const SizedBox(height: 14),
                    AmountField(
                      controller: _monthsController,
                      label: 'عدد الأشهر',
                      allowDecimal: false,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          InstallmentValidator.months(v, type: type),
                      onChanged: _onInputChanged,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'رسوم الاستعلام ${formatMoney(InstallmentCalculator.inquiryFee)} $currencyLabel تُدفع بشكل منفصل ولا تدخل في الإجمالي.',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('حساب التقسيط'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.charcoal,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('مسح البيانات'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.charcoal,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: const TextStyle(fontSize: 16),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _resultKey,
              child: ResultSummary(result: result),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saved ? null : _save,
              icon: Icon(_saved ? Icons.check : Icons.save_alt),
              label: Text(_saved ? 'تم الحفظ' : 'حفظ العملية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(52),
                textStyle:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _newCalculation,
              icon: const Icon(Icons.add),
              label: const Text('عملية جديدة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.charcoal,
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(fontSize: 16),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
